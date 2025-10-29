// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/hooks/LimitOrderHook.sol";
import "../src/interfaces/IPoolManager.sol";

contract MockPoolManager is IPoolManager {
    // Match IPoolManager.getSlot0 return order: (uint160 sqrtPriceX96, int24 tick, uint128 liquidity)
    struct Slot0 { uint160 sqrtPriceX96; int24 tick; uint128 liquidity; }
    mapping(bytes32 => Slot0) public slots;

    function getPoolId(PoolKey memory key) external pure override returns (bytes32) {
        return keccak256(abi.encode(key));
    }

    function getSlot0(bytes32 poolId) external view override returns (uint160 sqrtPriceX96, int24 tick, uint128 liquidity) {
        Slot0 memory s = slots[poolId];
        return (s.sqrtPriceX96, s.tick, s.liquidity);
    }

    function swap(PoolKey memory, bool, int256, uint160, bytes calldata) external pure override returns (int256, int256) {
        // simple simulation
        return (1, 1);
    }

    function setSlot(bytes32 poolId, int24 tick, uint160 sqrtPriceX96, uint128 liquidity) external {
        slots[poolId] = Slot0(sqrtPriceX96, tick, liquidity);
    }
}

contract LimitOrderHookTest is Test {
    MockPoolManager poolManager;
    LimitOrderHook hook;

    IPoolManager.PoolKey poolKey;

    function setUp() public {
        poolManager = new MockPoolManager();
        hook = new LimitOrderHook(address(poolManager));

        poolKey = IPoolManager.PoolKey({
            currency0: address(0x1),
            currency1: address(0x2),
            fee: 3000,
            tickSpacing: 60,
            hooks: address(hook)
        });

        // initialize mock pool state: current tick = 1000
        bytes32 poolId = poolManager.getPoolId(poolKey);
        poolManager.setSlot(poolId, 1000, 0, 1000);
    }

    /// @notice 1 Single Order (Happy Path)
    function testSingleOrderExec() public {
        bytes32 orderId = hook.createLimitOrder(address(0x1), address(0x2), 100, 900);
        console.log("Created Limit Order ID:", uint256(orderId));

        bytes32 poolId = poolManager.getPoolId(poolKey);
        hook.afterSwap(address(this), poolId, 0, 0, abi.encode(orderId));

        (, bool executed, , , , ) = hook.orders(orderId);
        console.log("Order executed?", executed ? 1 : 0);
        assertTrue(executed);
    }

    /// @notice 2 Price Not Reached Yet
    function testPriceNotReachedYet() public {
        bytes32 orderId = hook.createLimitOrder(address(0x1), address(0x2), 100, 1100);
        bytes32 poolId = poolManager.getPoolId(poolKey);

        hook.afterSwap(address(this), poolId, 0, 0, abi.encode(orderId));
        (, bool executed, , , , ) = hook.orders(orderId);
        console.log("Order executed?", executed ? 1 : 0);
        assertFalse(executed);
    }

    /// @notice 3 Multiple Orders in One Pool
    function testMultipleOrdersInOnePool() public {
        bytes32 order1 = hook.createLimitOrder(address(0x1), address(0x2), 100, 1100);
        bytes32 order2 = hook.createLimitOrder(address(0x1), address(0x2), 100, 900);
        bytes32 poolId = poolManager.getPoolId(poolKey);

        hook.afterSwap(address(this), poolId, 0, 0, abi.encode(order1));
        hook.afterSwap(address(this), poolId, 0, 0, abi.encode(order2));

        (, bool executed1, , , , ) = hook.orders(order1);
        (, bool executed2, , , , ) = hook.orders(order2);

        console.log("Triggering afterSwap with tick=1000...");
        console.log("Order1 executed?", executed1 ? 1 : 0);
        console.log("Order2 executed?", executed2 ? 1 : 0);

        assertFalse(executed1);
        assertTrue(executed2);
    }

    /// @notice 4 Already Executed Order (no double execution)
    function testAlreadyExecutedOrderDoesNotDoubleExecute() public {
        bytes32 orderId = hook.createLimitOrder(address(0x1), address(0x2), 100, 900);
        bytes32 poolId = poolManager.getPoolId(poolKey);

        hook.afterSwap(address(this), poolId, 0, 0, abi.encode(orderId));
        (, bool executedFirst, , , , ) = hook.orders(orderId);
        assertTrue(executedFirst);

        // second call should not change execution state or revert
        hook.afterSwap(address(this), poolId, 0, 0, abi.encode(orderId));
        (, bool executedSecond, , , , ) = hook.orders(orderId);
        assertTrue(executedSecond);
    }

    /// @notice 5 Edge cases
    function testEdgeCases() public {
        bytes32 poolId = poolManager.getPoolId(poolKey);

        // amountIn = 0 => should NOT execute even if tick reached
        bytes32 orderZero = hook.createLimitOrder(address(0x1), address(0x2), 0, 900);
        hook.afterSwap(address(this), poolId, 0, 0, abi.encode(orderZero));
        (, bool executedZero, , , , ) = hook.orders(orderZero);
        console.log("Order with 0 amount executed?", executedZero ? 1 : 0);
        assertFalse(executedZero);

        // order far from target tick => no execute
        bytes32 orderFar = hook.createLimitOrder(address(0x1), address(0x2), 100, 10000);
        hook.afterSwap(address(this), poolId, 0, 0, abi.encode(orderFar));
        (, bool executedFar, , , , ) = hook.orders(orderFar);
        assertFalse(executedFar);

        // negative tick handling: set current tick negative and ensure no revert
        bytes32 negativePoolId = poolManager.getPoolId(poolKey);
        poolManager.setSlot(negativePoolId, -200, 0, 1000);
        bytes32 negOrder = hook.createLimitOrder(address(0x1), address(0x2), 100, -300);
        hook.afterSwap(address(this), negativePoolId, 0, 0, abi.encode(negOrder));
        (, bool executedNeg, , , , ) = hook.orders(negOrder);
        // target -300, current -200 -> executed
        assertTrue(executedNeg);
    }
}

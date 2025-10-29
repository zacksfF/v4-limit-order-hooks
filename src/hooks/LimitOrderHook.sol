// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IHooks.sol";
import "../interfaces/IPoolManager.sol";

/// @title LimitOrderHook - Minimal example hook for limit orders (compilable)
/// @notice Simple implementation: create orders and mark them executed in afterSwap when tick >= target
contract LimitOrderHook is IHooks {
    IPoolManager public immutable poolManager;

    struct LimitOrder {
        address owner;
        bool executed;
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        int24 targetTick;
    }

    mapping(bytes32 => LimitOrder) public orders;
    uint256 public nextOrderNonce;

    event LimitOrderCreated(bytes32 indexed orderId, address indexed owner, int24 targetTick);
    event LimitOrderExecuted(bytes32 indexed orderId, int24 currentTick);

    constructor(address _poolManager) {
        poolManager = IPoolManager(_poolManager);
    }

    /// @notice Create a new limit order
    function createLimitOrder(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        int24 targetTick
    ) external returns (bytes32) {
        // include an ever-increasing nonce to ensure uniqueness when multiple orders are created in the same block/tx
        bytes32 orderId = keccak256(abi.encodePacked(msg.sender, tokenIn, tokenOut, amountIn, block.timestamp, nextOrderNonce++));
        orders[orderId] = LimitOrder({
            owner: msg.sender,
            executed: false,
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            amountIn: amountIn,
            targetTick: targetTick
        });
        emit LimitOrderCreated(orderId, msg.sender, targetTick);
        return orderId;
    }

    // ============================================================
    // Hooks
    // ============================================================
    function beforeSwap(address, bytes32, bytes calldata) external override {
        // no-op
    }

    function afterSwap(
        address,
        bytes32 poolId,
        int256,
        int256,
        bytes calldata data
    ) external override {
        // Expect optional encoded orderId in data; if not present, do nothing
        if (data.length == 32) {
            bytes32 orderId = abi.decode(data, (bytes32));
            LimitOrder storage order = orders[orderId];
            if (order.owner == address(0) || order.executed) return;

            (, int24 currentTick, ) = poolManager.getSlot0(poolId);
            // Do not execute orders with zero amount
            if (order.amountIn == 0) return;

            if (currentTick >= order.targetTick) {
                order.executed = true;
                emit LimitOrderExecuted(orderId, currentTick);
            }
        }
    }

    function beforeModifyPosition(address, bytes32, bytes calldata) external override {}
    function afterModifyPosition(address, bytes32, bytes calldata) external override {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


/// @title IPoolManager - minimal interface for Uni V4 PoolManger
/// @notice used by hooks to read and interact with pools
interface IPoolManager {
    struct PoolKey {
        address currency0;
        address currency1;
        uint24 fee;
        int24 tickSpacing;
        address hooks;
    }

    /// @notice Returns the poolId for a given PoolKey
    function getPoolId(PoolKey memory key) external pure returns (bytes32);

    /// @notice Returns core state variables (tick, sqrtPrice, liquidity)
    function getSlot0(bytes32 poolId)
        external
        view
        returns (uint160 sqrtPriceX96, int24 tick, uint128 liquidity);

    /// @notice Executes a swap within the pool
    /// @param key The pool key
    /// @param zeroForOne True if swapping currency0 for currency1
    /// @param amountSpecified Amount of token in/out (positive = exactIn, negative = exactOut)
    /// @param sqrtPriceLimitX96 Price boundary for the swap
    /// @param data Extra data passed to hook callbacks
    /// @return amount0 Signed amount of currency0 swapped
    /// @return amount1 Signed amount of currency1 swapped
    function swap(
        PoolKey memory key,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);
}
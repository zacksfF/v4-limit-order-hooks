// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


/// @title IHooks - Interface for Uniswap V4 Hook contracts
/// @notice Defines callback functions that hooks can implement

interface IHooks {
    /// @notice Called before a swap happens
    /// @param sender The address calling the swap
    /// @param poolId The pool identifier
    /// @param data Arbitrary data (often encoded limit order info)
    function beforeSwap(
        address sender,
        bytes32 poolId,
        bytes calldata data
    ) external;

    /// @notice Called after a swap happens
    /// @param sender The address calling the swap
    /// @param poolId The pool identifier
    /// @param amount0Delta The amount of currency0 swapped 
    /// @param amount1Delta The amount of currency1 swapped 
    /// @param data Arbitrary data (used for validation or follow-up)
    function afterSwap(
        address sender,
        bytes32 poolId,
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data 
    ) external;

    /// @notice Called before adding liquidity
    function beforeModifyPosition(address sender, bytes32 poolId, bytes calldata data) external;

    /// @notice Called after adding liquidity
    function afterModifyPosition(address sender, bytes32 poolId, bytes calldata data) external;


}

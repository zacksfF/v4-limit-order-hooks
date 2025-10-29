// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IHooks.sol";
import "../interfaces/IPoolManager.sol";
import "../utils/Constants.sol";

/// @title DynamicFeeHook - Example Hook dynamically adjusting swap fees
/// @notice Demonstrates custom fee logic per pool state

contract DynamicFeeHook is IHooks {
    IPoolManager public immutable poolManager;

    mapping(bytes32 => uint24) public poolFees; // poolId => fee in hundredths of a bip
    event FeeAdjusted(bytes32 indexed poolId, uint24 newFee);

    constructor(address _poolManager) {
        poolManager = IPoolManager(_poolManager);
    }

    /// @notice adjust fee before each swap 
    function beforeSwap(address, bytes32 poolId, bytes calldata) external override {
        (, , uint128 liquidity) = poolManager.getSlot0(poolId);

        uint24 newFee;
        if (liquidity < 1e18) newFee = Constants.FEE_TIER_HIGH;
        else if (liquidity < 1e20) newFee = Constants.FEE_TIER_MEDIUM;
        else newFee = Constants.FEE_TIER_LOW;

        poolFees[poolId] = newFee;
        emit FeeAdjusted(poolId, newFee);
    }

    /// @notice Empty post hooks
    function afterSwap(address, bytes32, int256, int256, bytes calldata) external override {}
    function beforeModifyPosition(address, bytes32, bytes calldata) external override {}
    function afterModifyPosition(address, bytes32, bytes calldata) external override {}
}
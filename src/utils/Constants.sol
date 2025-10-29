// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Constants - Common constants for Uniswap V4 Hook Lab
/// @notice Stores reusable values across hooks
library Constants {
    // ============================================================
    // Math Constants
    // ============================================================

    /// @dev Fixed-point Q96 format (used in Uniswap price math)
    uint256 internal constant Q96 = 2 ** 96;

    // ============================================================
    // Fee Tiers
    // ============================================================

    /// @dev Common Uniswap V4 fee tiers (in hundredths of a bip, e.g., 500 = 0.05%)
    uint24 internal constant FEE_TIER_LOW = 500;     // 0.05%
    uint24 internal constant FEE_TIER_MEDIUM = 3000; // 0.3%
    uint24 internal constant FEE_TIER_HIGH = 10000;  // 1%

    // ============================================================
    // Tick Spacing
    // ============================================================

    /// @dev Recommended tick spacing values for each fee tier
    int24 internal constant TICK_SPACING_LOW = 10;
    int24 internal constant TICK_SPACING_MEDIUM = 60;
    int24 internal constant TICK_SPACING_HIGH = 200;

    // ============================================================
    // Default Limits
    // ============================================================

    /// @dev Default sqrt price limit (no limit)
    uint160 internal constant SQRT_PRICE_LIMIT_NONE = 0;

    // ============================================================
    // Placeholder Addresses (for local testing)
    // ============================================================

    // Use zero address placeholders for local testing (avoids address-literal checksum issues)
    address internal constant MOCK_TOKEN_A = address(0);
    address internal constant MOCK_TOKEN_B = address(0);

    // ============================================================
    // Default Hook Flags (example)
    // ============================================================

    /// @dev Bitmask flags used for encoding hook permissions
    uint8 internal constant BEFORE_SWAP_FLAG = 1 << 0;
    uint8 internal constant AFTER_SWAP_FLAG = 1 << 1;
    uint8 internal constant BEFORE_MODIFY_POSITION_FLAG = 1 << 2;
    uint8 internal constant AFTER_MODIFY_POSITION_FLAG = 1 << 3;
}

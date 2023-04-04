// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {OwnableImpl} from "src/OwnableImpl.sol";

/// @title PausableImpl
/// @author 0xSplits
/// @notice Pausable clone-implementation
abstract contract PausableImpl is OwnableImpl {
    error Paused();

    event SetPaused(bool paused);

    /// -----------------------------------------------------------------------
    /// storage - mutables
    /// -----------------------------------------------------------------------

    /// slot 0 - 11 bytes free

    /// OwnableImpl storage
    /// address public $owner;
    /// 20 bytes

    bool public $paused;
    /// 1 byte

    /// -----------------------------------------------------------------------
    /// constructor & initializer
    /// -----------------------------------------------------------------------

    constructor() {}

    function __initPausable(address owner_, bool paused_) internal {
        OwnableImpl.__initOwnable(owner_);
        $paused = paused_;
    }

    /// -----------------------------------------------------------------------
    /// modifiers
    /// -----------------------------------------------------------------------

    /// makes function pausable
    modifier pausable() {
        if ($paused) revert Paused();
        _;
    }

    /// -----------------------------------------------------------------------
    /// functions - public & external - onlyOwner
    /// -----------------------------------------------------------------------

    /// set paused
    function setPaused(bool paused_) external onlyOwner {
        $paused = paused_;
        emit SetPaused(paused_);
    }
}

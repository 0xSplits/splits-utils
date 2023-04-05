// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {AbstractOwnable} from "src/Ownable/AbstractOwnable.sol";

/// @title PausableImpl
/// @author 0xSplits
/// @notice Pausable clone-implementation
abstract contract PausableImpl is AbstractOwnable {
    error Paused();

    event SetPaused(bool paused);

    /// -----------------------------------------------------------------------
    /// storage - mutables
    /// -----------------------------------------------------------------------

    bool public $paused;

    /// -----------------------------------------------------------------------
    /// constructor & initializer
    /// -----------------------------------------------------------------------

    constructor() {}

    function __initPausable(address owner_, bool paused_) internal {
        AbstractOwnable.__initOwnable(owner_);
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

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {AbstractOwnable} from "src/Ownable/AbstractOwnable.sol";

/// @title OwnableImpl
/// @author 0xSplits
/// @notice Bare bones ownable contract
abstract contract OwnableImpl is AbstractOwnable {
    /// -----------------------------------------------------------------------
    /// storage - mutables
    /// -----------------------------------------------------------------------

    /// slot 0 - 12 bytes free

    address internal $owner;
    /// 20 bytes

    /// -----------------------------------------------------------------------
    /// constructor & initializer
    /// -----------------------------------------------------------------------

    constructor() {}

    /// -----------------------------------------------------------------------
    /// functions - public & external - onlyOwner
    /// -----------------------------------------------------------------------

    function owner() public virtual override returns (address) {
        return $owner;
    }

    /// -----------------------------------------------------------------------
    /// functions - private & internal
    /// -----------------------------------------------------------------------

    function _setOwner(address newOwner_) internal virtual override {
        $owner = newOwner_;
    }
}

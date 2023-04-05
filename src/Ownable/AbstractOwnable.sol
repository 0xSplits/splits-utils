// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

/// @title AbstractOwnable
/// @author 0xSplits
/// @notice Bare bones ownable abstract contract
abstract contract AbstractOwnable {
    error Unauthorized();

    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    /// -----------------------------------------------------------------------
    /// constructor & initializer
    /// -----------------------------------------------------------------------

    constructor() {}

    function __initOwnable(address owner_) internal virtual {
        _setOwner(owner_);
        emit OwnershipTransferred(address(0), owner_);
    }

    /// -----------------------------------------------------------------------
    /// modifiers
    /// -----------------------------------------------------------------------

    modifier onlyOwner() virtual {
        if (msg.sender != owner()) revert Unauthorized();
        _;
    }

    /// -----------------------------------------------------------------------
    /// functions - public & external
    /// -----------------------------------------------------------------------

    function owner() public virtual returns (address);

    function transferOwnership(address newOwner_) public virtual onlyOwner {
        _setOwner(newOwner_);
        emit OwnershipTransferred(msg.sender, newOwner_);
    }

    /// -----------------------------------------------------------------------
    /// functions - private & internal
    /// -----------------------------------------------------------------------

    function _setOwner(address newOwner_) internal virtual;
}

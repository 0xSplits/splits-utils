// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {ERC721} from "solmate/tokens/ERC721.sol";

import {AbstractOwnable} from "src/Ownable/AbstractOwnable.sol";

/// @title NFTOwnableImpl
/// @author 0xSplits
/// @notice Bare bones nft ownable contract
abstract contract NFTOwnableImpl is AbstractOwnable {
    error InvalidFunction();

    /// -----------------------------------------------------------------------
    /// constructor & initializer
    /// -----------------------------------------------------------------------

    constructor() {}

    function __initOwnable(address owner_) internal virtual override {}

    /// -----------------------------------------------------------------------
    /// functions - public & external - onlyOwner
    /// -----------------------------------------------------------------------

    function nftContract() public view virtual returns (ERC721);
    function tokenId() public view virtual returns (uint256);

    function owner() public virtual override returns (address) {
        return nftContract().ownerOf(tokenId());
    }

    /// -----------------------------------------------------------------------
    /// functions - private & internal
    /// -----------------------------------------------------------------------

    function _setOwner(address) internal virtual override {
        revert InvalidFunction();
    }
}

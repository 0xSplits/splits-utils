// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {ERC721} from "solmate/tokens/ERC721.sol";

contract MockERC721 is ERC721 {
    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function tokenURI(uint256) public pure override returns (string memory) {
        return "tokenURI";
    }

    function safeMint(address account, uint256 amount) external {
        _safeMint(account, amount);
    }
}

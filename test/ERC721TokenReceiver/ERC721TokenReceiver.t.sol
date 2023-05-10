// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {ERC721TokenReceiverBase} from "./ERC721TokenReceiverBase.t.sol";
import {MockERC721} from "../mocks/MockERC721.sol";

abstract contract ERC721TokenReceiverTest is ERC721TokenReceiverBase {
    function test_canReceive721s() public {
        MockERC721(mockERC721).safeMint($erc721TokenReceiver, $erc721Amount);
    }

    function testFuzz_canReceive721s(uint256 amount_) public {
        _setUpERC721TokenReceiverTest({erc721TokenReceiver_: $erc721TokenReceiver, amount_: amount_});

        test_canReceive721s();
    }
}

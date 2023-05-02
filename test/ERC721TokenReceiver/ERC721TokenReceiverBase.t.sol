// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "../Base.t.sol";

abstract contract ERC721TokenReceiverBase is BaseTest {
    address $erc721TokenReceiver;
    uint256 $erc721Amount;

    function setUp() public virtual override {
        BaseTest.setUp();
        _setUpERC721TokenReceiverTest({erc721TokenReceiver_: $erc721TokenReceiver, amount_: 1});
    }

    function _setUpERC721TokenReceiverTest(address erc721TokenReceiver_, uint256 amount_) internal {
        $erc721TokenReceiver = erc721TokenReceiver_;
        $erc721Amount = amount_;
    }
}

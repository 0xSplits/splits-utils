// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "../Base.t.sol";

abstract contract ERC1155TokenReceiverBase is BaseTest {
    address $erc1155TokenReceiver;

    uint256 $erc1155Id;
    uint256 $erc1155Amount;
    bytes $erc1155Data;

    uint256[] $erc1155Ids;
    uint256[] $erc1155Amounts;

    function setUp() public virtual override {
        BaseTest.setUp();

        $erc1155Ids.push(0);
        $erc1155Ids.push(1);
        $erc1155Amounts.push(1);
        $erc1155Amounts.push(2);

        _setUpERC1155TokenReceiverTest({
            erc1155TokenReceiver_: $erc1155TokenReceiver,
            id_: 0,
            amount_: 1,
            data_: "",
            ids_: $erc1155Ids,
            amounts_: $erc1155Amounts
        });
    }

    function _setUpERC1155TokenReceiverTest(
        address erc1155TokenReceiver_,
        uint256 id_,
        uint256 amount_,
        bytes memory data_,
        uint256[] memory ids_,
        uint256[] memory amounts_
    ) internal {
        $erc1155TokenReceiver = erc1155TokenReceiver_;
        $erc1155Id = id_;
        $erc1155Amount = amount_;
        $erc1155Data = data_;

        delete $erc1155Ids;
        for (uint256 i = 0; i < ids_.length; i++) {
            $erc1155Ids.push(ids_[i]);
        }

        delete $erc1155Amounts;
        for (uint256 i = 0; i < amounts_.length; i++) {
            $erc1155Amounts.push(amounts_[i]);
        }
    }
}

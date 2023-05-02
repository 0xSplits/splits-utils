// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {ERC1155TokenReceiverBase} from "./ERC1155TokenReceiverBase.t.sol";
import {MockERC1155} from "../mocks/MockERC1155.sol";

abstract contract ERC1155TokenReceiverTest is ERC1155TokenReceiverBase {
    function test_canReceive1155s() public {
        MockERC1155(mockERC1155).safeMint($erc1155TokenReceiver, $erc1155Id, $erc1155Amount, $erc1155Data);
    }

    function testFuzz_canReceive1155s(uint256 id_, uint256 amount_, bytes memory data_) public {
        _setUpERC1155TokenReceiverTest({
            erc1155TokenReceiver_: $erc1155TokenReceiver,
            id_: id_,
            amount_: amount_,
            data_: data_,
            ids_: $erc1155Ids,
            amounts_: $erc1155Amounts
        });

        test_canReceive1155s();
    }

    function test_canBatchReceive1155s() public {
        MockERC1155(mockERC1155).safeBatchMint($erc1155TokenReceiver, $erc1155Ids, $erc1155Amounts, $erc1155Data);
    }

    function testFuzz_canBatchReceive1155s(uint256[] calldata ids_, uint256[] calldata amounts_, bytes memory data_)
        public
    {
        _setUpERC1155TokenReceiverTest({
            erc1155TokenReceiver_: $erc1155TokenReceiver,
            id_: $erc1155Id,
            amount_: $erc1155Amount,
            data_: data_,
            ids_: ids_,
            amounts_: amounts_
        });

        test_canReceive1155s();
    }
}

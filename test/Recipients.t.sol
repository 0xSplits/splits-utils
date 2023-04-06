// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {BaseTest, MockERC20} from "test/base.t.sol";

import "src/Recipients.sol";

contract RecipientsTest is BaseTest {
    struct Recipient {
        address account;
        uint32 percentAllocation;
    }

    function setUp() public virtual override {
        super.setUp();
    }

    /// -----------------------------------------------------------------------
    /// tests - fuzz
    /// -----------------------------------------------------------------------

    function testFuzz_sortRecipients(Recipient[] memory recipients_) public {
        // pack sort
        (address[] memory packSortAccounts, uint32[] memory packSortPercentAllocations) = _unzipStruct(recipients_);
        (packSortAccounts, packSortPercentAllocations) = _sortRecipients(packSortAccounts, packSortPercentAllocations);

        // struct sort
        (address[] memory structSortAccounts, uint32[] memory structSortPercentAllocations) = _unzipStruct(_sortStruct(recipients_));

        assertEq(packSortAccounts, structSortAccounts);
        assertEq(packSortPercentAllocations, structSortPercentAllocations);
    }

    /// -----------------------------------------------------------------------
    /// internal
    /// -----------------------------------------------------------------------

    /// @dev simple in-place struct sort
    function _sortStruct(Recipient[] memory recipients_) internal pure returns (Recipient[] memory) {
        uint256 length = recipients_.length;
        for (uint256 i; i < length; i++) {
            for (uint256 j = i + 1; j < length; j++) {
                if (recipients_[i].account > recipients_[j].account)
                    (recipients_[i], recipients_[j]) = (recipients_[j], recipients_[i]);
                else if (recipients_[i].account == recipients_[j].account && recipients_[i].percentAllocation > recipients_[j].percentAllocation)
                    (recipients_[i], recipients_[j]) = (recipients_[j], recipients_[i]);
            }
        }
        return recipients_;
    }

    function _unzipStruct(Recipient[] memory recipients_) internal pure returns (address[] memory accounts, uint32[] memory percentAllocations) {
        uint256 length = recipients_.length;
        accounts = new address[](length);
        percentAllocations = new uint32[](length);
        for (uint256 i; i < length; i++) {
            (accounts[i], percentAllocations[i]) = (recipients_[i].account, recipients_[i].percentAllocation);
        }
    }
}

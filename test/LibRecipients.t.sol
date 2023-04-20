// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "./Base.t.sol";

import {LibRecipients, PackedRecipient} from "../src/LibRecipients.sol";

contract LibRecipientsTest is BaseTest {
    struct Recipient {
        address account;
        uint32 percentAllocation;
    }

    LibRecipientsHarness libRecipientsHarness;

    function setUp() public virtual override {
        super.setUp();

        libRecipientsHarness = new LibRecipientsHarness();
    }

    /// -----------------------------------------------------------------------
    /// tests - basic
    /// -----------------------------------------------------------------------

    function test_pack_full() public {
        assertEq(
            type(uint256).max - type(uint96).max + type(uint32).max,
            PackedRecipient.unwrap(LibRecipients._pack(address(type(uint160).max), type(uint32).max))
        );
    }

    function test_pack_empty() public {
        assertEq(0, PackedRecipient.unwrap(LibRecipients._pack(address(0), 0)));
    }

    function test_unpack_full() public {
        PackedRecipient packedRecipient = PackedRecipient.wrap(type(uint256).max);
        (address account, uint32 percentAllocation) = LibRecipients._unpack(packedRecipient);
        assertEq(account, address(type(uint160).max));
        assertEq(percentAllocation, type(uint32).max);
    }

    function test_unpack_empty() public {
        PackedRecipient packedRecipient = PackedRecipient.wrap(0);
        (address account, uint32 percentAllocation) = LibRecipients._unpack(packedRecipient);
        assertEq(account, address(0));
        assertEq(percentAllocation, 0);
    }

    /// -----------------------------------------------------------------------
    /// tests - fuzz
    /// -----------------------------------------------------------------------

    function testFuzz_sortRecipients(Recipient[] memory recipients_) public {
        // pack sort
        (address[] memory accounts, uint32[] memory percentAllocations) = _unzipStruct(recipients_);
        (address[] memory packSortAccounts, uint32[] memory packSortPercentAllocations) =
            libRecipientsHarness.exposed_sortRecipients(accounts, percentAllocations);

        // struct sort
        (address[] memory structSortAccounts, uint32[] memory structSortPercentAllocations) =
            _unzipStruct(_sortStruct(recipients_));

        assertEq(packSortAccounts, structSortAccounts);
        assertEq(packSortPercentAllocations, structSortPercentAllocations);
    }

    function testFuzz_sortRecipientsInPlace(Recipient[] memory recipients_) public {
        // pack sort
        (address[] memory packSortAccounts, uint32[] memory packSortPercentAllocations) = _unzipStruct(recipients_);
        LibRecipients._sortRecipientsInPlace(packSortAccounts, packSortPercentAllocations);

        // struct sort
        (address[] memory structSortAccounts, uint32[] memory structSortPercentAllocations) =
            _unzipStruct(_sortStruct(recipients_));

        assertEq(packSortAccounts, structSortAccounts);
        assertEq(packSortPercentAllocations, structSortPercentAllocations);
    }

    function testFuzz_pack_unpack(Recipient calldata recipient_) public {
        (address account, uint32 percentAllocation) = _unzipStruct(recipient_);

        (address packUnpackAccount, uint32 packUnpackPercentAllocation) =
            LibRecipients._unpack(LibRecipients._pack(account, percentAllocation));
        assertEq(account, packUnpackAccount);
        assertEq(percentAllocation, packUnpackPercentAllocation);
    }

    /// -----------------------------------------------------------------------
    /// internal
    /// -----------------------------------------------------------------------

    /// @dev simple in-place struct sort
    function _sortStruct(Recipient[] memory recipients_) internal pure returns (Recipient[] memory) {
        uint256 length = recipients_.length;
        for (uint256 i; i < length; i++) {
            for (uint256 j = i + 1; j < length; j++) {
                if (recipients_[i].account > recipients_[j].account) {
                    (recipients_[i], recipients_[j]) = (recipients_[j], recipients_[i]);
                } else if (
                    recipients_[i].account == recipients_[j].account
                        && recipients_[i].percentAllocation > recipients_[j].percentAllocation
                ) {
                    (recipients_[i], recipients_[j]) = (recipients_[j], recipients_[i]);
                }
            }
        }
        return recipients_;
    }

    function _unzipStruct(Recipient[] memory recipients_)
        internal
        pure
        returns (address[] memory accounts, uint32[] memory percentAllocations)
    {
        uint256 length = recipients_.length;
        accounts = new address[](length);
        percentAllocations = new uint32[](length);
        for (uint256 i; i < length; i++) {
            (accounts[i], percentAllocations[i]) = _unzipStruct(recipients_[i]);
        }
    }

    function _unzipStruct(Recipient memory recipient_)
        internal
        pure
        returns (address account, uint32 percentAllocation)
    {
        (account, percentAllocation) = (recipient_.account, recipient_.percentAllocation);
    }
}

contract LibRecipientsHarness {
    function exposed_sortRecipients(address[] calldata accounts_, uint32[] calldata percentAllocations_)
        external
        pure
        returns (address[] memory, uint32[] memory)
    {
        return LibRecipients._sortRecipients(accounts_, percentAllocations_);
    }
}

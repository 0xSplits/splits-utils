// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {LibSort} from "solady/utils/LibSort.sol";

using LibSort for uint256[];

type PackedRecipient is uint256;

error InvalidRecipients_ArrayLengthMismatch();

uint256 constant UINT96_BITS = 96;

function _sortRecipients(address[] memory accounts_, uint32[] memory percentAllocations_) pure returns (address[] memory, uint32[] memory) {
    PackedRecipient[] memory packedRecipients = _packRecipients(accounts_, percentAllocations_);
    _sort( packedRecipients );
    return _unpack(packedRecipients);
}

function _packRecipients(address[] memory accounts_, uint32[] memory percentAllocations_) pure returns (PackedRecipient[] memory packedRecipients) {
    if (accounts_.length != percentAllocations_.length) revert InvalidRecipients_ArrayLengthMismatch();

    uint256 length = accounts_.length;
    packedRecipients = new PackedRecipient[](length);
    for (uint256 i; i < length;) {
        packedRecipients[i] = PackedRecipient.wrap((uint256(uint160(accounts_[i])) << UINT96_BITS) | percentAllocations_[i]);

        unchecked {
            ++i;
        }
    }
}

/// @dev sorts in-place
function _sort(PackedRecipient[] memory packedRecipients_) pure {
    uint256[] memory uintPackedRecipients;
    /// @solidity memory-safe-assembly
    assembly {
        uintPackedRecipients := packedRecipients_
    }
    uintPackedRecipients.sort();
}

function _unpack(PackedRecipient[] memory packedRecipients_) pure returns  (address[] memory accounts, uint32[] memory percentAllocations) {
    uint256 length = packedRecipients_.length;
    accounts = new address[](length);
    percentAllocations = new uint32[](length);
    for (uint256 i; i < length;) {
        (accounts[i], percentAllocations[i]) = _unpack(packedRecipients_[i]);

        unchecked {
            ++i;
        }
    }
}

function _unpack(PackedRecipient packedRecipient_) pure returns  (address account, uint32 percentAllocation) {
    uint256 packedRecipient = PackedRecipient.unwrap(packedRecipient_);
    percentAllocation = uint32(packedRecipient);
    account = address(uint160(packedRecipient >> UINT96_BITS));
}
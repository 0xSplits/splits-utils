// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {AbstractOwnable} from "src/Ownable/AbstractOwnable.sol";

// TODO: open q: add exec via sig ?

/// @title WalletImpl
/// @author 0xSplits
/// @notice Minimal smart wallet clone-implementation
abstract contract WalletImpl is AbstractOwnable {
    struct Call {
        address to;
        uint256 value;
        bytes data;
    }

    event ExecCalls(Call[] calls);

    /// -----------------------------------------------------------------------
    /// storage - mutables
    /// -----------------------------------------------------------------------

    /// slot 0 - 12 bytes free

    /// OwnableImpl storage
    /// address public $owner;
    /// 20 bytes

    /// -----------------------------------------------------------------------
    /// constructor & initializer
    /// -----------------------------------------------------------------------

    constructor() {}

    function __initWallet(address owner_) internal {
        AbstractOwnable.__initOwnable(owner_);
    }

    /// -----------------------------------------------------------------------
    /// functions - external & public - onlyOwner
    /// -----------------------------------------------------------------------

    /// allow owner to execute arbitrary calls
    function execCalls(Call[] calldata calls_)
        external
        payable
        onlyOwner
        returns (uint256 blockNumber, bytes[] memory returnData)
    {
        blockNumber = block.number;
        uint256 length = calls_.length;
        returnData = new bytes[](length);

        bool success;
        for (uint256 i; i < length;) {
            Call calldata calli = calls_[i];
            (success, returnData[i]) = calli.to.call{value: calli.value}(calli.data);
            require(success, string(returnData[i]));

            unchecked {
                ++i;
            }
        }

        emit ExecCalls(calls_);
    }
}

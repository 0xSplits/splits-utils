// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "../base.t.sol";

import {
    Initialized_OwnableImplBase,
    OwnableImplHarness,
    Uninitialized_OwnableImplBase
} from "../OwnableImpl/OwnableImplStateTree.sol";

import {WalletImpl} from "../../src/WalletImpl.sol";

/// State tree
///  Uninitialized
///  Initialized

abstract contract Uninitialized_WalletImplBase is Uninitialized_OwnableImplBase {
    // if you crank these values up too much, forge will stack overflow
    uint256 constant FUZZ_CALLS_MAX_LENGTH = 4;
    uint256 constant FUZZ_CALL_MAX_VALUE = 1e18;
    uint256 constant FUZZ_CALL_MAX_DATA_LENGTH_IN_WORDS = 4;
    uint256 constant FUZZ_CALL_MAX_DATA_LENGTH = FUZZ_CALL_MAX_DATA_LENGTH_IN_WORDS * 32;

    struct FuzzCallsParams {
        uint8 callsLength;
        WalletImpl.Call[FUZZ_CALLS_MAX_LENGTH] calls;
        FuzzCall[FUZZ_CALLS_MAX_LENGTH] fuzzCalls;
    }

    struct FuzzCall {
        address to;
        uint256 value;
        uint16 dataLength;
        bytes32[FUZZ_CALL_MAX_DATA_LENGTH_IN_WORDS] data;
    }

    WalletImplHarness $wallet;
    WalletImpl.Call[] $calls;

    event ExecCalls(WalletImpl.Call[] calls);

    function setUp() public virtual override {
        super.setUp();
        _setUp();
    }

    function _setUp() internal virtual {
        $wallet = new WalletImplHarness();
        _deal({account: address($wallet)});
        vm.deal({account: address($wallet), newBalance: 1 << 96});

        $calls.push(WalletImpl.Call({to: users.alice, value: 1 ether, data: "0x123456789"}));

        $ownable = OwnableImplHarness((address($wallet)));
    }

    function _initialize() internal virtual override {
        $wallet.exposed_initWallet($owner);
    }

    /// -----------------------------------------------------------------------
    /// internal
    /// -----------------------------------------------------------------------

    function cleanFuzzCalls(FuzzCallsParams calldata params_) internal returns (WalletImpl.Call[] memory calls) {
        uint256 boundedCallsLength = bound(params_.callsLength, 0, FUZZ_CALLS_MAX_LENGTH);

        calls = new WalletImpl.Call[](boundedCallsLength);
        for (uint256 i; i < boundedCallsLength; i++) {
            FuzzCall calldata fuzzCall = params_.fuzzCalls[i];
            assumeNoPrecompiles(fuzzCall.to);
            assumePayable(fuzzCall.to);
            vm.assume(fuzzCall.to != address($wallet));

            uint256 boundedValue = bound(fuzzCall.value, 0, FUZZ_CALL_MAX_VALUE);
            uint256 boundedDataLength = bound(fuzzCall.dataLength, 0, FUZZ_CALL_MAX_DATA_LENGTH);
            bytes memory boundedData = boundedBytes(fuzzCall.data, boundedDataLength);
            calls[i] = WalletImpl.Call({to: fuzzCall.to, value: boundedValue, data: boundedData});
        }
    }

    function boundedBytes(bytes32[FUZZ_CALL_MAX_DATA_LENGTH_IN_WORDS] calldata data_, uint256 boundedDataLength_)
        internal
        pure
        returns (bytes memory boundedData)
    {
        boundedData = abi.encodePacked(data_);
        assembly ("memory-safe") {
            mstore(boundedData, boundedDataLength_)
        }
    }
}

abstract contract Initialized_WalletImplBase is Uninitialized_WalletImplBase, Initialized_OwnableImplBase {
    function setUp() public virtual override(Uninitialized_WalletImplBase, Initialized_OwnableImplBase) {
        Uninitialized_WalletImplBase.setUp();
    }

    function _setUp() internal virtual override(Uninitialized_WalletImplBase, Initialized_OwnableImplBase) {
        Uninitialized_WalletImplBase._setUp();
        _initialize();
    }

    function _initialize() internal virtual override(Uninitialized_OwnableImplBase, Uninitialized_WalletImplBase) {
        Uninitialized_WalletImplBase._initialize();
    }
}

contract WalletImplHarness is WalletImpl {
    function exposed_initWallet(address owner_) external {
        __initWallet(owner_);
    }
}

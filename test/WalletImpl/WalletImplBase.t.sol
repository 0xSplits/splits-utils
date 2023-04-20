// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "../Base.t.sol";

import {
    Initialized_OwnableImplBase,
    OwnableImplHarness,
    Uninitialized_OwnableImplBase
} from "../OwnableImpl/OwnableImplBase.t.sol";

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
        // using super calls out to Initialized_OwnableImplBase.setUp() from Initialized_WalletImplTest
        /* super.setUp(); */
        Uninitialized_OwnableImplBase.setUp();
        WalletImpl.Call[] memory calls = new WalletImpl.Call[](1);
        calls[0] = WalletImpl.Call({to: users.alice, value: 1 ether, data: "0x123456789"});
        _setUpWalletImplState({wallet_: address(new WalletImplHarness()), calls_: calls});
    }

    function _setUpWalletImplState(address wallet_, WalletImpl.Call[] memory calls_) internal virtual {
        $wallet = WalletImplHarness(wallet_);
        $ownable = OwnableImplHarness(wallet_);

        delete $calls;
        uint256 length = calls_.length;
        for (uint256 i; i < length; i++) {
            $calls.push(calls_[i]);
        }

        deal({token: address(mockERC20), to: wallet_, give: 1 << 96});
        vm.deal({account: wallet_, newBalance: 1 << 96});
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

abstract contract Initialized_WalletImplBase is Initialized_OwnableImplBase, Uninitialized_WalletImplBase {
    function setUp() public virtual override(Initialized_OwnableImplBase, Uninitialized_WalletImplBase) {
        super.setUp();
        _initialize();
    }

    function _initialize() internal virtual override(Uninitialized_OwnableImplBase, Uninitialized_WalletImplBase) {
        super._initialize();
    }
}

contract WalletImplHarness is WalletImpl {
    function exposed_initWallet(address owner_) external {
        __initWallet(owner_);
    }
}

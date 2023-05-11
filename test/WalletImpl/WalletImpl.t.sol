// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "../Base.t.sol";

import {ERC1155TokenReceiverBase, ERC1155TokenReceiverTest} from "../ERC1155TokenReceiver/ERC1155TokenReceiver.t.sol";
import {ERC721TokenReceiverBase, ERC721TokenReceiverTest} from "../ERC721TokenReceiver/ERC721TokenReceiver.t.sol";
import {
    Initialized_OwnableImplBase,
    Initialized_OwnableImplTest,
    Uninitialized_OwnableImplBase,
    Uninitialized_OwnableImplTest
} from "../OwnableImpl/OwnableImpl.t.sol";
import {Initialized_WalletImplBase, WalletImplHarness, Uninitialized_WalletImplBase} from "./WalletImplBase.t.sol";
import {WalletImpl} from "../../src/WalletImpl.sol";

contract Uninitialized_WalletImplTest is
    Uninitialized_OwnableImplTest,
    ERC721TokenReceiverTest,
    ERC1155TokenReceiverTest,
    Uninitialized_WalletImplBase
{
    function setUp()
        public
        virtual
        override(
            Uninitialized_OwnableImplBase, ERC721TokenReceiverBase, ERC1155TokenReceiverBase, Uninitialized_WalletImplBase
        )
    {
        Uninitialized_WalletImplBase.setUp();
    }

    function _initialize() internal virtual override(Uninitialized_OwnableImplBase, Uninitialized_WalletImplBase) {
        Uninitialized_WalletImplBase._initialize();
    }
}

contract Initialized_WalletImplTest is Initialized_OwnableImplTest, Initialized_WalletImplBase {
    function setUp() public virtual override(Initialized_OwnableImplBase, Initialized_WalletImplBase) {
        Initialized_WalletImplBase.setUp();
    }

    function _initialize() internal virtual override(Uninitialized_OwnableImplBase, Initialized_WalletImplBase) {
        Initialized_WalletImplBase._initialize();
    }

    /// -----------------------------------------------------------------------
    /// execCalls
    /// -----------------------------------------------------------------------

    function test_revertWhen_callerNotOwner_execCalls() public callerNotOwner($notOwner) {
        vm.expectRevert(Unauthorized.selector);
        $wallet.execCalls($calls);
    }

    function testFuzz_revertWhen_callerNotOwner_execCalls(
        address owner_,
        address notOwner_,
        Uninitialized_WalletImplBase.FuzzCallsParams calldata fuzzCalls_
    ) public callerNotOwner(notOwner_) {
        vm.assume(owner_ != notOwner_);
        $owner = owner_;
        _initialize();
        WalletImpl.Call[] memory calls = cleanFuzzCalls(fuzzCalls_);

        vm.expectRevert(Unauthorized.selector);
        $wallet.execCalls(calls);
    }

    function test_execCalls_executesCalls() public callerOwner {
        WalletImpl.Call memory call = $calls[0];
        vm.expectCall(call.to, call.value, call.data);
        $wallet.execCalls($calls);
    }

    function testFuzz_execCalls_executesCalls(Uninitialized_WalletImplBase.FuzzCallsParams calldata fuzzCalls_)
        public
        callerOwner
    {
        WalletImpl.Call[] memory calls = cleanFuzzCalls(fuzzCalls_);
        for (uint256 i; i < calls.length; i++) {
            WalletImpl.Call memory call = calls[i];
            vm.expectCall(call.to, call.value, call.data);
        }
        $wallet.execCalls(calls);
    }

    function test_execCalls_emitsExecCalls() public callerOwner {
        _expectEmit();
        emit ExecCalls($calls);
        $wallet.execCalls($calls);
    }

    function testFuzz_execCalls_emitsExecCalls(Uninitialized_WalletImplBase.FuzzCallsParams calldata fuzzCalls_)
        public
        callerOwner
    {
        WalletImpl.Call[] memory calls = cleanFuzzCalls(fuzzCalls_);
        _expectEmit();
        emit ExecCalls(calls);
        $wallet.execCalls(calls);
    }
}

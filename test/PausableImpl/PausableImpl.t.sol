// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "../Base.t.sol";

import {
    Initialized_OwnableImplBase,
    Initialized_OwnableImplTest,
    Uninitialized_OwnableImplBase,
    Uninitialized_OwnableImplTest
} from "../OwnableImpl/OwnableImpl.t.sol";
import {
    Initialized_PausableImplBase, PausableImplHarness, Uninitialized_PausableImplBase
} from "./PausableImplBase.t.sol";

contract Uninitialized_PausableImplTest is Uninitialized_OwnableImplTest, Uninitialized_PausableImplBase {
    function setUp() public virtual override(Uninitialized_OwnableImplBase, Uninitialized_PausableImplBase) {
        Uninitialized_PausableImplBase.setUp();
    }

    function _initialize() internal virtual override(Uninitialized_OwnableImplBase, Uninitialized_PausableImplBase) {
        Uninitialized_PausableImplBase._initialize();
    }

    /// -----------------------------------------------------------------------
    ///  init
    /// -----------------------------------------------------------------------

    function test_init_setsPaused() public {
        _initialize();
        assertEq($pausable.paused(), $paused);
    }

    function testFuzz_init_setsPaused(bool paused_) public {
        $paused = paused_;

        _initialize();
        assertEq($pausable.paused(), $paused);
    }
}

contract Initialized_PausableImplTest is Initialized_OwnableImplTest, Initialized_PausableImplBase {
    function setUp() public virtual override(Initialized_OwnableImplBase, Initialized_PausableImplBase) {
        Initialized_PausableImplBase.setUp();
    }

    function _initialize() internal virtual override(Uninitialized_OwnableImplBase, Initialized_PausableImplBase) {
        Initialized_PausableImplBase._initialize();
    }

    /// -----------------------------------------------------------------------
    /// setsPaused
    /// -----------------------------------------------------------------------

    function _test_revertWhen_callerNotOwner_setPaused() internal {
        vm.expectRevert(Unauthorized.selector);
        $pausable.setPaused($paused);
    }

    function test_revertWhen_callerNotOwner_setPaused() public callerNotOwner($notOwner) {
        _test_revertWhen_callerNotOwner_setPaused();
    }

    function testFuzz_revertWhen_callerNotOwner_setPaused(address notOwner_, bool paused_)
        public
        callerNotOwner(notOwner_)
    {
        $paused = paused_;

        _test_revertWhen_callerNotOwner_setPaused();
    }

    function _test_setPaused_setsPaused() internal {
        $pausable.setPaused($paused);
        assertEq($pausable.paused(), $paused);
    }

    function test_setPaused_setsPaused() public callerOwner {
        _test_setPaused_setsPaused();
    }

    function testFuzz_setPaused_setsPaused(bool paused_) public callerOwner {
        $paused = paused_;

        _test_setPaused_setsPaused();
    }

    function _test_setPaused_emitsSetPaused() internal {
        _expectEmit();
        emit SetPaused($paused);
        $pausable.setPaused($paused);
    }

    function test_setPaused_emitsSetPaused() public callerOwner {
        _test_setPaused_emitsSetPaused();
    }

    function testFuzz_setPaused_emitsSetPaused(bool paused_) public callerOwner {
        $paused = paused_;

        _test_setPaused_emitsSetPaused();
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "../Base.t.sol";

import {Initialized_OwnableImplBase, Uninitialized_OwnableImplBase} from "./OwnableImplBase.t.sol";

contract Uninitialized_OwnableImplTest is Uninitialized_OwnableImplBase {
    /// -----------------------------------------------------------------------
    ///  init
    /// -----------------------------------------------------------------------

    function test_init_emitsOwnershipTransferred() public {
        _expectEmit();
        emit OwnershipTransferred(address(0), $owner);
        _initialize();
    }

    function testFuzz_init_emitsOwnershipTransferred(address owner_) public {
        $owner = owner_;
        test_init_emitsOwnershipTransferred();
    }

    function test_init_setsOwner() public {
        _initialize();
        assertEq($ownable.owner(), $owner);
    }

    function testFuzz_init_setsOwner(address owner_) public {
        $owner = owner_;
        test_init_setsOwner();
    }

    /// -----------------------------------------------------------------------
    ///  transferOwnership
    /// -----------------------------------------------------------------------

    function testFuzz_revertWhen_callerNotOwner_transferOwnership(address owner_, address notOwner_)
        public
        callerNotOwner(notOwner_)
    {
        vm.assume(owner_ != notOwner_);
        $owner = owner_;
        _initialize();

        vm.expectRevert(Unauthorized.selector);
        $ownable.transferOwnership($notOwner);
    }

    function testFuzz_transferOwnership_setsOwner(address owner_, address nextOwner_) public callerFuzzOwner(owner_) {
        $nextOwner = nextOwner_;

        $ownable.transferOwnership($nextOwner);
        assertEq($ownable.owner(), $nextOwner);
    }

    function testFuzz_transferOwnership_emitsOwnershipTransferred(address owner_, address nextOwner_)
        public
        callerFuzzOwner(owner_)
    {
        $nextOwner = nextOwner_;

        _expectEmit();
        emit OwnershipTransferred($owner, $nextOwner);
        $ownable.transferOwnership($nextOwner);
    }
}

contract Initialized_OwnableImplTest is Initialized_OwnableImplBase {
    /// -----------------------------------------------------------------------
    ///  transferOwnership
    /// -----------------------------------------------------------------------

    function test_revertWhen_callerNotOwner_transferOwnership() public callerNotOwner($notOwner) {
        vm.expectRevert(Unauthorized.selector);
        $ownable.transferOwnership($notOwner);
    }

    function testFuzz_revertWhen_callerNotOwner_transferOwnership(address notOwner_) public callerNotOwner(notOwner_) {
        test_revertWhen_callerNotOwner_transferOwnership();
    }

    function test_transferOwnership_setsOwner() public callerOwner {
        $ownable.transferOwnership($nextOwner);
        assertEq($ownable.owner(), $nextOwner);
    }

    function testFuzz_transferOwnership_setsOwner(address nextOwner_) public callerOwner {
        $nextOwner = nextOwner_;

        test_transferOwnership_setsOwner();
    }

    function test_transferOwnership_emitsOwnershipTransferred() public callerOwner {
        _expectEmit();
        emit OwnershipTransferred($owner, $nextOwner);
        $ownable.transferOwnership($nextOwner);
    }

    function testFuzz_transferOwnership_emitsOwnershipTransferred(address nextOwner_) public callerOwner {
        $nextOwner = nextOwner_;

        test_transferOwnership_emitsOwnershipTransferred();
    }
}

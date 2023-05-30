// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "../Base.t.sol";

import {OwnableImpl} from "../../src/OwnableImpl.sol";

/// State tree
///  Uninitialized
///  Initialized

abstract contract Uninitialized_OwnableImplBase is BaseTest {
    OwnableImplHarness $ownable;
    address $owner;
    address $notOwner;
    address $nextOwner;

    error Unauthorized();

    event OwnershipTransferred(address indexed oldOwner, address indexed nextOwner);

    function setUp() public virtual override {
        BaseTest.setUp();
        _setUpOwnableImplState({
            ownable_: address(new OwnableImplHarness()),
            owner_: users.alice,
            nextOwner_: users.bob,
            notOwner_: users.eve
        });
    }

    function _setUpOwnableImplState(address ownable_, address owner_, address nextOwner_, address notOwner_)
        internal
        virtual
    {
        $ownable = OwnableImplHarness(ownable_);
        $owner = owner_;
        $nextOwner = nextOwner_;
        $notOwner = notOwner_;
    }

    function _initialize() internal virtual {
        $ownable.exposed_initOwnable($owner);
    }

    /// -----------------------------------------------------------------------
    /// modifiers
    /// -----------------------------------------------------------------------

    modifier callerNotOwner(address notOwner_) {
        vm.assume(notOwner_ != $owner);
        $notOwner = notOwner_;
        vm.startPrank(notOwner_);
        _;
    }

    modifier callerOwner() {
        vm.startPrank($owner);
        _;
    }

    modifier callerFuzzOwner(address owner_) {
        $owner = owner_;
        _initialize();
        vm.startPrank($owner);
        _;
    }
}

abstract contract Initialized_OwnableImplBase is Uninitialized_OwnableImplBase {
    function setUp() public virtual override {
        Uninitialized_OwnableImplBase.setUp();
        _initialize();
    }
}

contract OwnableImplHarness is OwnableImpl {
    function exposed_initOwnable(address owner_) external {
        __initOwnable(owner_);
    }
}

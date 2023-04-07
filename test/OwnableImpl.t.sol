// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "./base.t.sol";

import {LibClone} from "../src/LibClone.sol";
import {OwnableImpl} from "../src/OwnableImpl.sol";

contract OwnableImplTest is BaseTest {
    using LibClone for address;

    OwnableImplHarness public ownableImpl;
    OwnableImplHarness public ownable;

    error Unauthorized();

    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    function setUp() public virtual override {
        ownableImpl = new OwnableImplHarness();
        ownable = OwnableImplHarness(address(ownableImpl).clone());
    }

    /// -----------------------------------------------------------------------
    /// modifiers
    /// -----------------------------------------------------------------------

    modifier callerOwner() {
        _;
    }

    /// -----------------------------------------------------------------------
    /// tests - basic
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// tests - basic - init
    /// -----------------------------------------------------------------------

    function test_init_setsOwner() public {
        ownable.exposed_initOwnable(address(this));
        assertEq(ownable.owner(), address(this));
    }

    function test_init_emitsOwnershipTransferred() public {
        _expectEmit();
        emit OwnershipTransferred(address(0), address(this));
        ownable.exposed_initOwnable(address(this));
    }

    /// -----------------------------------------------------------------------
    /// tests - basic - transferOwnership
    /// -----------------------------------------------------------------------

    function test_RevertWhen_CallerNotOwner_transferOwnership() public {
        vm.expectRevert(Unauthorized.selector);
        ownable.transferOwnership(address(this));
    }

    function test_transferOwnership_setsOwner() public callerOwner {
        ownable.exposed_initOwnable(address(this));

        ownable.transferOwnership(address(0));
        assertEq(ownable.owner(), address(0));
    }

    function test_transferOwnership_emitsOwnershipTransferred() public callerOwner {
        ownable.exposed_initOwnable(address(this));

        _expectEmit();
        emit OwnershipTransferred(address(this), address(0));
        ownable.transferOwnership(address(0));
    }

    /// -----------------------------------------------------------------------
    /// tests - fuzz
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// tests - fuzz - init
    /// -----------------------------------------------------------------------

    function testFuzz_init_setsOwner(address owner_) public {
        ownable.exposed_initOwnable(owner_);
        assertEq(ownable.owner(), owner_);
    }

    function testFuzz_init_emitsOwnershipTransferred(address owner_) public {
        _expectEmit();
        emit OwnershipTransferred(address(0), owner_);
        ownable.exposed_initOwnable(owner_);
    }

    /// -----------------------------------------------------------------------
    /// tests - fuzz - transferOwnership
    /// -----------------------------------------------------------------------

    function testFuzz_RevertWhen_CallerNotOwner_transferOwnership(address owner_, address prankOwner_) public {
        vm.assume(owner_ != prankOwner_);

        ownable.exposed_initOwnable(owner_);

        vm.prank(prankOwner_);
        vm.expectRevert(Unauthorized.selector);
        ownable.transferOwnership(prankOwner_);
    }

    function testFuzz_transferOwnership_setsOwner(address owner_, address newOwner_) public callerOwner {
        ownable.exposed_initOwnable(owner_);

        vm.prank(owner_);
        ownable.transferOwnership(newOwner_);
        assertEq(ownable.owner(), newOwner_);
    }

    function testFuzz_transferOwnership_emitsOwnershipTransferred(address owner_, address newOwner_)
        public
        callerOwner
    {
        ownable.exposed_initOwnable(owner_);

        _expectEmit();
        vm.prank(owner_);
        emit OwnershipTransferred(owner_, newOwner_);
        ownable.transferOwnership(newOwner_);
    }
}

contract OwnableImplHarness is OwnableImpl {
    function exposed_initOwnable(address owner_) external {
        __initOwnable(owner_);
    }
}

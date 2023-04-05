// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {BaseTest} from "test/base.t.sol";

import {LibClone} from "src/LibClone.sol";
import {PausableImpl} from "src/PausableImpl.sol";

contract PausableImplTest is BaseTest {
    using LibClone for address;

    PausableImplHarness public pausableImpl;
    PausableImplHarness public pausable;

    error Unauthorized();
    error Paused();

    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);
    event SetPaused(bool paused);

    function setUp() public virtual override {
        pausableImpl = new PausableImplHarness();
        pausable = PausableImplHarness(address(pausableImpl).clone());
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
        pausable.exposed_initPausable(address(this), true);
        assertEq(pausable.$owner(), address(this));
    }

    function test_init_emitsOwnershipTransferred() public {
        _expectEmit();
        emit OwnershipTransferred(address(0), address(this));
        pausable.exposed_initPausable(address(this), true);
    }

    function test_init_setsPaused() public {
        pausable.exposed_initPausable(address(this), true);
        assertEq(pausable.$paused(), true);
    }

    /// -----------------------------------------------------------------------
    /// tests - basic - setsPaused
    /// -----------------------------------------------------------------------

    function test_RevertWhen_CallerNotOwner_setPaused() public {
        vm.expectRevert(Unauthorized.selector);
        pausable.setPaused(true);
    }

    function test_setPaused_setsPaused() public callerOwner {
        pausable.exposed_initPausable(address(this), true);

        pausable.setPaused(false);
        assertEq(pausable.$paused(), false);
    }

    function test_setPaused_emitsSetPaused() public callerOwner {
        pausable.exposed_initPausable(address(this), false);

        _expectEmit();
        emit SetPaused(true);
        pausable.setPaused(true);
    }

    /// -----------------------------------------------------------------------
    /// tests - fuzz
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// tests - fuzz - init
    /// -----------------------------------------------------------------------

    function testFuzz_init_setsOwner(address owner_, bool paused_) public {
        pausable.exposed_initPausable(owner_, paused_);
        assertEq(pausable.$owner(), owner_);
    }

    function testFuzz_init_emitsOwnershipTransferred(address owner_, bool paused_) public {
        _expectEmit();
        emit OwnershipTransferred(address(0), owner_);
        pausable.exposed_initPausable(owner_, paused_);
    }

    function testFuzz_init_setsPaused(address owner_, bool paused_) public {
        pausable.exposed_initPausable(owner_, paused_);
        assertEq(pausable.$paused(), paused_);
    }

    /// -----------------------------------------------------------------------
    /// tests - fuzz - setsPaused
    /// -----------------------------------------------------------------------

    function testFuzz_RevertWhen_CallerNotOwner_setPaused(address owner_, bool paused_, address prankOwner_) public {
        vm.assume(owner_ != prankOwner_);

        pausable.exposed_initPausable(owner_, paused_);

        vm.prank(prankOwner_);
        vm.expectRevert(Unauthorized.selector);
        pausable.setPaused(paused_);
    }

    function testFuzz_setPaused_setsPaused(address owner_, bool paused_) public callerOwner {
        pausable.exposed_initPausable(owner_, !paused_);

        vm.prank(owner_);
        pausable.setPaused(paused_);
        assertEq(pausable.$paused(), paused_);
    }

    function testFuzz_setPaused_emitsSetPaused(address owner_, bool paused_) public callerOwner {
        pausable.exposed_initPausable(owner_, paused_);

        _expectEmit();
        vm.prank(owner_);
        emit SetPaused(paused_);
        pausable.setPaused(paused_);
    }
}

contract PausableImplHarness is PausableImpl {
    function exposed_initPausable(address owner_, bool paused_) external {
        __initPausable(owner_, paused_);
    }
}

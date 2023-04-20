// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "../Base.t.sol";

import {
    Initialized_OwnableImplBase,
    OwnableImplHarness,
    Uninitialized_OwnableImplBase
} from "../OwnableImpl/OwnableImplBase.t.sol";
import {PausableImpl} from "../../src/PausableImpl.sol";

/// State tree
///  Uninitialized
///  Initialized

abstract contract Uninitialized_PausableImplBase is Uninitialized_OwnableImplBase {
    error Paused();

    event SetPaused(bool paused);

    PausableImplHarness $pausable;
    bool $paused;

    function setUp() public virtual override {
        // using super calls out to Initialized_OwnableImplBase.setUp() from Initialized_PausableImplTest
        /* super.setUp(); */
        Uninitialized_OwnableImplBase.setUp();
        _setUpPausableImplState({pausable_: address(new PausableImplHarness()), paused_: false});
    }

    function _setUpPausableImplState(address pausable_, bool paused_) internal virtual {
        $pausable = PausableImplHarness(pausable_);
        $ownable = OwnableImplHarness(pausable_);
        $paused = paused_;
    }

    function _initialize() internal virtual override {
        $pausable.exposed_initPausable($owner, $paused);
    }
}

abstract contract Initialized_PausableImplBase is Initialized_OwnableImplBase, Uninitialized_PausableImplBase {
    function setUp() public virtual override(Initialized_OwnableImplBase, Uninitialized_PausableImplBase) {
        super.setUp();
        _initialize();
    }

    function _initialize() internal virtual override(Uninitialized_OwnableImplBase, Uninitialized_PausableImplBase) {
        super._initialize();
    }

    /// -----------------------------------------------------------------------
    /// modifiers
    /// -----------------------------------------------------------------------

    modifier paused() {
        assertTrue($paused);
        _;
    }

    modifier unpaused() {
        assertFalse($paused);
        _;
    }
}

contract PausableImplHarness is PausableImpl {
    function exposed_initPausable(address owner_, bool paused_) external {
        __initPausable(owner_, paused_);
    }
}

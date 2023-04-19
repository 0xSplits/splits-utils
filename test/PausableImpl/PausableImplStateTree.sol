// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "../base.t.sol";

import {
    Initialized_OwnableImplBase,
    OwnableImplHarness,
    Uninitialized_OwnableImplBase
} from "../OwnableImpl/OwnableImplStateTree.sol";
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
        super.setUp();
        _setUp({paused_: false});
    }

    function _setUp(bool paused_) internal virtual {
        $pausable = new PausableImplHarness();
        $paused = paused_;
        $ownable = OwnableImplHarness(address($pausable));
    }

    function _initialize() internal virtual override {
        $pausable.exposed_initPausable($owner, $paused);
    }
}

abstract contract Initialized_PausableImplBase is Uninitialized_PausableImplBase, Initialized_OwnableImplBase {
    function setUp() public virtual override(Uninitialized_PausableImplBase, Initialized_OwnableImplBase) {
        Uninitialized_PausableImplBase.setUp();
        _setUp();
    }

    function _initialize() internal virtual override(Uninitialized_OwnableImplBase, Uninitialized_PausableImplBase) {
        Uninitialized_PausableImplBase._initialize();
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

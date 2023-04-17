// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "./base.t.sol";

import {LibClone} from "../src/LibClone.sol";

abstract contract LibCloneBase is BaseTest {
    using LibClone for address;

    event ReceiveETH(uint256 amount);

    address impl;
    address clone;
    uint96 amount;
    bytes data;

    function setUp() public virtual override {
        super.setUp();
        _setUp(users.alice, 1 ether, "Hello World!");
    }

    function _setUp(address impl_, uint96 amount_, bytes memory data_) internal virtual {
        _setUpImpl(impl_);
        amount = amount_;
        data = data_;
    }

    function _setUpImpl(address impl_) internal {
        impl = impl_;
        clone = impl_.clone();
    }

    function test_clone_code() public {
        assertEq(
            clone.code,
            abi.encodePacked(
                hex"36602c57343d527f",
                // `keccak256("ReceiveETH(uint256)")`
                hex"9e4ac34f21c619cefc926c8bd93b54bf5a39c7ab2127a895af1cc0691d7e3dff",
                hex"593da1005b3d3d3d3d363d3d37363d73",
                impl,
                hex"5af43d3d93803e605757fd5bf3"
            )
        );
    }

    function test_clone_canReceiveETH() public {
        payable(clone).transfer(amount);
    }

    function test_clone_emitsReceiveETH() public {
        _expectEmit();
        emit ReceiveETH(amount);
        payable(clone).transfer(amount);
    }

    function test_clone_canDelegateCall() public {
        // don't expect call to necessarily succeed, just to happen
        vm.expectCall(impl, data);
        clone.call(data);
    }
}

contract LibCloneTest is LibCloneBase {
    function setUp() public override {
        super.setUp();
    }

    function testFuzz_clone_code(address impl_) public {
        _setUpImpl(impl_);

        test_clone_code();
    }

    function testFuzz_clone_canReceiveETH(address impl_, uint96 amount_) public {
        _setUpImpl(impl_);
        amount = amount_;

        test_clone_canReceiveETH();
    }

    function testFuzz_clone_emitsReceiveETH(address impl_, uint96 amount_) public {
        _setUpImpl(impl_);
        amount = amount_;

        test_clone_emitsReceiveETH();
    }

    function testFuzz_clone_canDelegateCall(address impl_, bytes calldata data_) public {
        vm.assume(data_.length > 0);
        assumeNoPrecompiles(impl_);
        vm.assume(impl_ != address(vm));

        _setUpImpl(impl_);
        data = data_;

        test_clone_canDelegateCall();
    }
}

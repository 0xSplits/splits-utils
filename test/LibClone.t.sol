// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "./base.t.sol";

import {LibClone} from "../src/LibClone.sol";

contract LibCloneTest is BaseTest {
    using LibClone for address;

    function setUp() public override {}

    function testFuzz_clone(address impl_) public {
        address clone = impl_.clone();
        assertEq(
            clone.code,
            abi.encodePacked(
                hex"36602c57343d527f",
                // `keccak256("ReceiveETH(uint256)")`
                hex"9e4ac34f21c619cefc926c8bd93b54bf5a39c7ab2127a895af1cc0691d7e3dff",
                hex"593da1005b3d3d3d3d363d3d37363d73",
                impl_,
                hex"5af43d3d93803e605757fd5bf3"
            )
        );
    }

    function testFuzz_cloneCanReceiveETH(address impl_, uint96 amount_) public {
        address clone = impl_.clone();
        payable(clone).transfer(amount_);
    }

    function testFuzz_cloneCanDelegateCall(address impl_, bytes calldata data_) public {
        vm.assume(data_.length > 0);
        assumePayable(impl_);
        assumeNoPrecompiles(impl_);

        address clone = impl_.clone();

        vm.expectCall(impl_, data_);
        (bool success,) = clone.call(data_);
        assertTrue(success);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import {MockERC20} from "test/mocks/MockERC20.sol";
import {TokenUtils} from "src/TokenUtils.sol";

/// @dev base inspired by PaulRBerg
abstract contract BaseTest is Test {
    /// -----------------------------------------------------------------------
    /// libraries
    /// -----------------------------------------------------------------------

    using TokenUtils for address;

    /// -----------------------------------------------------------------------
    /// structs
    /// -----------------------------------------------------------------------

    struct Users {
        address payable alice;
        address payable bob;
        address payable eve;
    }

    /// -----------------------------------------------------------------------
    /// storage
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// storage - constants & immutables
    /// -----------------------------------------------------------------------

    address internal constant ZERO_ADDRESS = address(0);
    address internal constant ETH_ADDRESS = address(0);
    uint8 internal constant ERC_DECIMALS = 24;

    /// -----------------------------------------------------------------------
    /// storage - mutables
    /// -----------------------------------------------------------------------

    Users public users;
    address public mockERC20;

    /// -----------------------------------------------------------------------
    /// functions
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// functions - public & external
    /// -----------------------------------------------------------------------

    function setUp() public virtual {
        mockERC20 = address(new MockERC20("Test Token", "TOK", ERC_DECIMALS));

        users = Users({alice: createUser("Alice"), bob: createUser("Bob"), eve: createUser("Eve")});
    }

    /// -----------------------------------------------------------------------
    /// functions - private & internal
    /// -----------------------------------------------------------------------

    function expectEmit() internal {
        vm.expectEmit(true, true, true, true);
    }

    /// @dev Generates an address by hashing the name, labels the address and funds it with 1k ether & 1m TOK
    function createUser(string memory name) internal returns (address payable addr) {
        addr = payable(address(uint160(uint256(keccak256(abi.encodePacked(name))))));
        vm.label({account: addr, newLabel: name});
        deal({account: addr});
    }

    function deal(address account) internal {
        vm.deal({account: account, newBalance: 1_000 ether});
        deal({token: address(mockERC20), to: account, give: 1_000_000 * (10 ** ERC_DECIMALS)});
    }
}
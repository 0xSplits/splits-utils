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

    uint256 constant BLOCK_NUMBER = 16984898; // 2023-04-05
    address constant SPLIT_MAIN = 0x2ed6c4B5dA6378c7897AC67Ba9e43102Feb694EE;
    address constant UNISWAP_V3_FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    // ethereum WETH used by uniswap v3
    address constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address internal constant ZERO_ADDRESS = address(0);
    address internal constant ETH_ADDRESS = address(0);
    uint8 internal constant ERC_DECIMALS = 24;
    uint32 internal constant PERCENTAGE_SCALE = 100_00_00; // = 1e6 = 100%

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
        users = Users({alice: _createUser("Alice"), bob: _createUser("Bob"), eve: _createUser("Eve")});
    }

    // TODO: doesn't appear to work; maybe some kind of security blocker for libs
    // trying to pull envs?
    /* function setUpFork() public virtual { */
    /*     setUp(); */

    /*     string memory MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL"); */
    /*     vm.createSelectFork(MAINNET_RPC_URL, BLOCK_NUMBER); */
    /* } */

    /// -----------------------------------------------------------------------
    /// functions - private & internal
    /// -----------------------------------------------------------------------

    function _expectEmit() internal {
        vm.expectEmit({checkTopic1: true, checkTopic2: true, checkTopic3: true, checkData: true});
    }

    /// @dev Generates an address by hashing the name, labels the address and funds it with 1k ether & 1m TOK
    function _createUser(string memory name) internal returns (address payable addr) {
        addr = payable(address(uint160(uint256(keccak256(abi.encodePacked(name))))));
        vm.label({account: addr, newLabel: name});
        _deal({account: addr});
    }

    function _deal(address account) internal {
        vm.deal({account: account, newBalance: 1_000 ether});
        deal({token: address(mockERC20), to: account, give: 1_000_000 * (10 ** ERC_DECIMALS)});
    }

    /// dumbest sort as reference for testing
    function _sort(uint256[] memory arr) internal pure {
        uint256 length = arr.length;
        for (uint256 i; i < length; ++i) {
            for (uint256 j = i + 1; j < length; ++j) {
                if (arr[i] > arr[j]) (arr[i], arr[j]) = (arr[j], arr[i]);
            }
        }
    }
}

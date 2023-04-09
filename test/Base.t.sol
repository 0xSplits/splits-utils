// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import {AddressUtils, ADDRESS_ZERO} from "../src/AddressUtils.sol";
import {MockERC20} from "./mocks/MockERC20.sol";
import {TokenUtils} from "../src/TokenUtils.sol";

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

    /// dumb sort as testing reference
    function _sort(uint256[] memory arr) internal pure {
        uint256 length = arr.length;
        for (uint256 i; i < length; ++i) {
            for (uint256 j = i + 1; j < length; ++j) {
                if (arr[i] > arr[j]) (arr[i], arr[j]) = (arr[j], arr[i]);
            }
        }
    }

    function _predictNextAddressesFrom(address deployer_, uint256 num)
        internal
        view
        returns (address[] memory nextAddresses)
    {
        nextAddresses = new address[](num);
        uint64 nonce = vm.getNonce(deployer_);
        for (uint256 i; i < num; i++) {
            nextAddresses[i] = _predictNextAddressFrom(deployer_, nonce);
            nonce++;
        }
    }

    function _predictNextAddressFrom(address deployer_) internal view returns (address) {
        return _predictNextAddressFrom(deployer_, vm.getNonce(deployer_));
    }

    function _predictNextAddressFrom(address deployer_, uint64 nonce_) internal pure returns (address) {
        bytes memory data;
        if (nonce_ == 0x00) {
            data = abi.encodePacked(bytes1(0xd6), bytes1(0x94), deployer_, bytes1(0x80));
        } else if (nonce_ <= 0x7f) {
            data = abi.encodePacked(bytes1(0xd6), bytes1(0x94), deployer_, uint8(nonce_));
        } else if (nonce_ <= 0xff) {
            data = abi.encodePacked(bytes1(0xd7), bytes1(0x94), deployer_, bytes1(0x81), uint8(nonce_));
        } else if (nonce_ <= 0xffff) {
            data = abi.encodePacked(bytes1(0xd8), bytes1(0x94), deployer_, bytes1(0x82), uint16(nonce_));
        } else if (nonce_ <= 0xffffff) {
            data = abi.encodePacked(bytes1(0xd9), bytes1(0x94), deployer_, bytes1(0x83), uint24(nonce_));
        } else {
            data = abi.encodePacked(bytes1(0xda), bytes1(0x94), deployer_, bytes1(0x84), uint32(nonce_));
        }
        return address(uint160(uint256(keccak256(data))));
    }

    /// -----------------------------------------------------------------------
    /// functions - private & internal - extended asserts
    /// -----------------------------------------------------------------------

    function assertEq(uint32[] memory a_, uint32[] memory b_) internal virtual {
        uint256[] memory a;
        uint256[] memory b;
        assembly ("memory-safe") {
            a := a_
            b := b_
        }
        assertEq(a, b);
    }
}

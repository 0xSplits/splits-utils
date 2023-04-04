// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import {LibClone} from "src/LibClone.sol";
import {TokenUtils} from "src/TokenUtils.sol";
import {MockERC20} from "./mocks/MockERC20.sol";

contract TokenUtilsTest is Test {
    address internal constant ETH_ADDRESS = address(0);

    address payable alice;
    TokenUtilsHarness public tokenUtils;
    address public mERC20;

    function setUp() public virtual {
        alice = createUser("Alice");

        mERC20 = address(new MockERC20("Test Token", "TOK", 6));

        tokenUtils = new TokenUtilsHarness();
        vm.deal({ account: address(tokenUtils), newBalance: 1 << 96 });
        deal({ token: address(mERC20), to: address(tokenUtils), give: 1_000_000e18 });
    }

    /// -----------------------------------------------------------------------
    /// tests - basic
    /// -----------------------------------------------------------------------

    function test_isETH_recognizesETH() public {
        assertTrue(tokenUtils.exposed_isETH(ETH_ADDRESS));
    }

    function test_isETH_recognizesERC20() public {
        assertFalse(tokenUtils.exposed_isETH(address(mERC20)));
    }

    function test_decimals_recognizesETH() public {
        assertEq(tokenUtils.exposed_decimals(ETH_ADDRESS), 18);
    }

    function test_decimals_recognizesNonETH() public {
        vm.expectCall(mERC20, abi.encodeCall(MockERC20(mERC20).decimals, ()));
        assertEq(tokenUtils.exposed_decimals(mERC20), 6);
    }

    function test_balanceOf_recognizesETH() public {
        assertEq(tokenUtils.exposed_balanceOf(ETH_ADDRESS, address(this)), address(this).balance);
    }

    function test_balanceOf_recognizesERC20() public {
        assertEq(tokenUtils.exposed_balanceOf(address(mERC20), address(this)), MockERC20(mERC20).balanceOf(address(this)));
    }

    function test_safeTransfer_recognizesETH() public {
        vm.expectCall(alice, 1 ether, "");
        tokenUtils.exposed_safeTransfer(ETH_ADDRESS, alice, 1 ether);
    }

    function test_safeTransfer_recognizesERC20() public {
        vm.expectCall(address(mERC20), 0, abi.encodeCall(MockERC20(mERC20).transfer, (alice, 1 ether)));
        tokenUtils.exposed_safeTransfer(address(mERC20), alice, 1 ether);
    }

    /// -----------------------------------------------------------------------
    /// internal
    /// -----------------------------------------------------------------------

    // TODO: move into base contract ?

    /// @dev Generates an address by hashing the name, labels the address and funds it with 100 ETH, 1 million DAI,
    /// and 1 million USDC.
    function createUser(string memory name) internal returns (address payable addr) {
        addr = payable(address(uint160(uint256(keccak256(abi.encodePacked(name))))));
        vm.label({ account: addr, newLabel: name });
        vm.deal({ account: addr, newBalance: 100 ether });
        /* deal({ token: address(dai), to: addr, give: 1_000_000e18 }); */
    }
}

contract TokenUtilsHarness {
    using TokenUtils for address;

    function exposed_isETH(address token_) external pure returns (bool) {
        return token_._isETH();
    }
    function exposed_decimals(address token_) external view returns (uint8) {
        return token_._decimals();
    }
    function exposed_balanceOf(address token_, address addr_) external view returns (uint256) {
        return token_._balanceOf(addr_);
    }
    function exposed_safeTransfer(address token_, address addr_, uint256 amount_) external {
        token_._safeTransfer(addr_, amount_);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "./Base.t.sol";

import {TokenUtils} from "../src/TokenUtils.sol";

contract TokenUtilsTest is BaseTest {
    TokenUtilsHarness public tokenUtils;

    function setUp() public virtual override {
        super.setUp();

        tokenUtils = new TokenUtilsHarness();
        _deal({account: address(tokenUtils)});
    }

    /// -----------------------------------------------------------------------
    /// tests - basic
    /// -----------------------------------------------------------------------

    function test_isETH_eth() public {
        assertTrue(tokenUtils.exposed_isETH(ETH_ADDRESS));
    }

    function test_isETH_nonETH() public {
        assertFalse(tokenUtils.exposed_isETH(address(mockERC20)));
    }

    function test_decimals_eth() public {
        assertEq(tokenUtils.exposed_decimals(ETH_ADDRESS), 18);
    }

    function test_decimals_nonETH() public {
        vm.expectCall(mockERC20, abi.encodeCall(MockERC20(mockERC20).decimals, ()));
        assertEq(tokenUtils.exposed_decimals(mockERC20), MOCK_ERC20_DECIMALS);
    }

    function test_balanceOf_eth() public {
        assertEq(tokenUtils.exposed_balanceOf(ETH_ADDRESS, users.alice), users.alice.balance);
    }

    function test_balanceOf_nonETH() public {
        assertEq(
            tokenUtils.exposed_balanceOf(address(mockERC20), users.alice), MockERC20(mockERC20).balanceOf(users.alice)
        );
    }

    function test_safeTransfer_eth() public {
        uint256 oldBalance = users.alice.balance;
        vm.expectCall(users.alice, 1 ether, "");
        tokenUtils.exposed_safeTransfer(ETH_ADDRESS, users.alice, 1 ether);
        assertEq(oldBalance + 1 ether, users.alice.balance);
    }

    function test_safeTransfer_nonETH() public {
        uint256 oldBalance = MockERC20(mockERC20).balanceOf(users.alice);
        vm.expectCall(address(mockERC20), 0, abi.encodeCall(MockERC20(mockERC20).transfer, (users.alice, 1)));
        tokenUtils.exposed_safeTransfer(address(mockERC20), users.alice, 1);
        assertEq(oldBalance + 1, MockERC20(mockERC20).balanceOf(users.alice));
    }

    /// -----------------------------------------------------------------------
    /// tests - fuzz
    /// -----------------------------------------------------------------------

    function testFuzz_decimals_nonETH(uint8 decimals_) public {
        mockERC20 = address(new MockERC20("Test Token", "TOK", decimals_));

        vm.expectCall(mockERC20, abi.encodeCall(MockERC20(mockERC20).decimals, ()));
        assertEq(tokenUtils.exposed_decimals(mockERC20), decimals_);
    }

    function testFuzz_balanceOf_eth(uint96 newBalance_) public {
        vm.deal({account: users.alice, newBalance: newBalance_});
        assertEq(tokenUtils.exposed_balanceOf(ETH_ADDRESS, users.alice), newBalance_);
    }

    function testFuzz_balanceOf_nonETH(uint256 newBalance_) public {
        deal({token: address(mockERC20), to: users.alice, give: newBalance_});
        assertEq(tokenUtils.exposed_balanceOf(address(mockERC20), users.alice), newBalance_);
    }

    function testFuzz_safeTransfer_eth(uint96 amount_) public {
        vm.deal({account: address(tokenUtils), newBalance: amount_});

        uint256 oldBalance = users.alice.balance;
        vm.expectCall(users.alice, amount_, "");
        tokenUtils.exposed_safeTransfer(ETH_ADDRESS, users.alice, amount_);
        assertEq(oldBalance + amount_, users.alice.balance);
        assertEq(address(tokenUtils).balance, 0);
    }

    function testFuzz_safeTransfer_nonETH(uint96 amount_) public {
        deal({token: address(mockERC20), to: address(tokenUtils), give: amount_});

        uint256 oldBalance = MockERC20(mockERC20).balanceOf(users.alice);
        vm.expectCall(address(mockERC20), 0, abi.encodeCall(MockERC20(mockERC20).transfer, (users.alice, amount_)));
        tokenUtils.exposed_safeTransfer(address(mockERC20), users.alice, amount_);
        assertEq(oldBalance + amount_, MockERC20(mockERC20).balanceOf(users.alice));
        assertEq(MockERC20(mockERC20).balanceOf(address(tokenUtils)), 0);
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

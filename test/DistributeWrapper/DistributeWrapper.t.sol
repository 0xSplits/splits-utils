// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC20} from "../../src/interfaces/external/IERC20.sol";
import {DistributeWrapper} from "../../src/DistributeWrapper.sol";
import {BaseTest} from "../Base.t.sol";
import {ISplitMain} from "../../src/interfaces/ISplitMain.sol";

contract DistributeWrapperTest is BaseTest {
    DistributeWrapper public distributeWrapper;

    address public constant TEST_SPLIT = 0xaD30f7EEBD9Bd5150a256F47DA41d4403033CdF0;

    address[] private test_split_recipients;
    uint32 private test_split_distributorFee;
    uint32[] private test_split_percentAllocations;

    function setUp() public override {
        super.setUp();

        string memory MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");
        vm.selectFork(vm.createFork(MAINNET_RPC_URL));
        distributeWrapper = new DistributeWrapper(SPLIT_MAIN);

        test_split_recipients.push(0x8a14D4a671fBe267844B08D9748eD946348aEbFD);
        test_split_recipients.push(0xbbcec987E4C189FCbAB0a2534c77b3ba89229F11);

        test_split_distributorFee = 9998;

        test_split_percentAllocations.push(140000);
        test_split_percentAllocations.push(860000);
    }

    function testFork_distributeETH() public {
        uint256 amount = 1e18;

        deal(TEST_SPLIT, amount);

        distributeWrapper.distributeETH(
            TEST_SPLIT,
            test_split_recipients,
            test_split_percentAllocations,
            test_split_distributorFee,
            address(this),
            amount
        );

        assertEq(TEST_SPLIT.balance, 0);
        assertGt(ISplitMain(SPLIT_MAIN).getETHBalance(address(this)), 0);
    }

    function testFork_distributeETH_Revert_whenAmountNotPresent() public {
        uint256 amount = 1e18;

        testFork_distributeETH();

        vm.expectRevert(DistributeWrapper.AmountNotPresent.selector);
        distributeWrapper.distributeETH(
            TEST_SPLIT,
            test_split_recipients,
            test_split_percentAllocations,
            test_split_distributorFee,
            address(this),
            amount
        );
    }

    function testFork_distributeERC20() public {
        uint256 amount = 100e18;

        deal(DAI, TEST_SPLIT, amount);

        distributeWrapper.distributeERC20(
            TEST_SPLIT,
            DAI,
            test_split_recipients,
            test_split_percentAllocations,
            test_split_distributorFee,
            address(this),
            amount
        );

        assertEq(IERC20(DAI).balanceOf(TEST_SPLIT), 1);
        assertGt(ISplitMain(SPLIT_MAIN).getERC20Balance(address(this), DAI), 0);
    }

    function testFork_distributeERC20_Revert_whenAmountNotPresent() public {
        uint256 amount = 100e18;

        testFork_distributeERC20();

        vm.expectRevert(DistributeWrapper.AmountNotPresent.selector);
        distributeWrapper.distributeERC20(
            TEST_SPLIT,
            DAI,
            test_split_recipients,
            test_split_percentAllocations,
            test_split_distributorFee,
            address(this),
            amount
        );
    }
}

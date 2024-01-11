// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ISplitMain} from "./interfaces/ISplitMain.sol";
import {IERC20} from "./interfaces/external/IERC20.sol";

/// @title Wrapper for Distributing Splits
/// @notice This contract is a wrapper for split main.
///         It distributes splits only when the specified
///         amount of the token is present in the wallet.
/// @author Splits
contract DistributeWrapper {
    /* -------------------------------------------------------------------------- */
    /*                                   ERRORS                                   */
    /* -------------------------------------------------------------------------- */

    error AmountNotPresent();

    /* -------------------------------------------------------------------------- */
    /*                           CONSTANTS & IMMUTABLES                           */
    /* -------------------------------------------------------------------------- */

    ISplitMain public immutable SPLIT_MAIN;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    constructor(address _splitMain) {
        SPLIT_MAIN = ISplitMain(_splitMain);
    }

    /* -------------------------------------------------------------------------- */
    /*                                  FUNCTIONS                                 */
    /* -------------------------------------------------------------------------- */

    function distributeETH(
        address _split,
        address[] calldata _accounts,
        uint32[] calldata _percentAllocations,
        uint32 _distributorFee,
        address _distributorAddress,
        uint256 _amount
    ) external {
        if (_split.balance < _amount) revert AmountNotPresent();

        SPLIT_MAIN.distributeETH(_split, _accounts, _percentAllocations, _distributorFee, _distributorAddress);
    }

    function distributeERC20(
        address _split,
        address _token,
        address[] calldata _accounts,
        uint32[] calldata _percentAllocations,
        uint32 _distributorFee,
        address _distributorAddress,
        uint256 _amount
    ) external {
        if (IERC20(_token).balanceOf(_split) < _amount) revert AmountNotPresent();

        SPLIT_MAIN.distributeERC20(_split, _token, _accounts, _percentAllocations, _distributorFee, _distributorAddress);
    }
}

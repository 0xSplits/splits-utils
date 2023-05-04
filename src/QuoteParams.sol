// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {QuotePair} from "./QuotePair.sol";

struct QuoteParams {
    QuotePair quotePair;
    uint128 baseAmount;
    bytes data;
}

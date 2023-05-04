// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

using {_convert} for QuotePair global;
using {_sort} for ConvertedQuotePair global;

struct QuotePair {
    address base;
    address quote;
}

struct ConvertedQuotePair {
    address cBase;
    address cQuote;
}

struct SortedConvertedQuotePair {
    address cToken0;
    address cToken1;
}

function _convert(QuotePair calldata qp, function (address) internal view returns (address) convert)
    view
    returns (ConvertedQuotePair memory)
{
    return ConvertedQuotePair({cBase: convert(qp.base), cQuote: convert(qp.quote)});
}

function _sort(ConvertedQuotePair memory cqp) pure returns (SortedConvertedQuotePair memory) {
    return (cqp.cBase > cqp.cQuote)
        ? SortedConvertedQuotePair({cToken0: cqp.cQuote, cToken1: cqp.cBase})
        : SortedConvertedQuotePair({cToken0: cqp.cBase, cToken1: cqp.cQuote});
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

// TODO: add natspec?

library AddressUtils {
    address internal constant ADDRESS_ZERO = address(0);

    function _isEmpty(address addr) internal pure returns (bool) {
        return (addr == ADDRESS_ZERO);
    }

    function _isNotEmpty(address addr) internal pure returns (bool) {
        return (addr != ADDRESS_ZERO);
    }
}

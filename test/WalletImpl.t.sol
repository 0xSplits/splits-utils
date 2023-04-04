// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {BaseTest} from "test/base.t.sol";

import {LibClone} from "src/LibClone.sol";
import {WalletImpl} from "src/WalletImpl.sol";

contract WalletImplTest is BaseTest {
    using LibClone for address;

    // if you crank these values up too much, forge will stack overflow
    uint256 constant FUZZ_CALLS_MAX_LENGTH = 4;
    uint256 constant FUZZ_CALL_MAX_VALUE = 1e18;
    uint256 constant FUZZ_CALL_MAX_DATA_LENGTH_IN_WORDS = 4;
    uint256 constant FUZZ_CALL_MAX_DATA_LENGTH = FUZZ_CALL_MAX_DATA_LENGTH_IN_WORDS * 32;

    struct FuzzCallsParams {
        uint8 callsLength;
        WalletImpl.Call[FUZZ_CALLS_MAX_LENGTH] calls;
        FuzzCall[FUZZ_CALLS_MAX_LENGTH] fuzzCalls;
    }

    struct FuzzCall {
        address to;
        uint256 value;
        uint16 dataLength;
        bytes32[FUZZ_CALL_MAX_DATA_LENGTH_IN_WORDS] data;
    }

    WalletImplHarness public walletImpl;
    WalletImplHarness public wallet;

    error Unauthorized();

    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);
    event ExecCalls(WalletImpl.Call[] calls);

    function setUp() public virtual override {
        super.setUp();

        walletImpl = new WalletImplHarness();
        wallet = WalletImplHarness(address(walletImpl).clone());

        deal({account: address(wallet)});
        vm.deal({account: address(wallet), newBalance: 1 << 96});
    }

    /// -----------------------------------------------------------------------
    /// modifiers
    /// -----------------------------------------------------------------------

    modifier callerOwner() {
        _;
    }

    /// -----------------------------------------------------------------------
    /// tests - basic
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// tests - basic - init
    /// -----------------------------------------------------------------------

    function test_init_setsOwner() public {
        wallet.exposed_initWallet(address(this));
        assertEq(wallet.$owner(), address(this));
    }

    function test_init_emitsOwnershipTransferred() public {
        expectEmit();
        emit OwnershipTransferred(address(0), address(this));
        wallet.exposed_initWallet(address(this));
    }

    /// -----------------------------------------------------------------------
    /// tests - basic - execCalls
    /// -----------------------------------------------------------------------

    function test_RevertWhen_CallerNotOwner_execCalls() public {
        vm.expectRevert(Unauthorized.selector);
        WalletImpl.Call[] memory calls = new WalletImpl.Call[](0);
        wallet.execCalls(calls);
    }

    function test_execCalls_executesCalls() public callerOwner {
        wallet.exposed_initWallet(address(this));

        WalletImpl.Call[] memory calls = new WalletImpl.Call[](1);
        calls[0] = WalletImpl.Call({to: users.alice, value: 1 ether, data: "0x123456789"});
        vm.expectCall(users.alice, 1 ether, "0x123456789");
        wallet.execCalls(calls);
    }

    function test_execCalls_emitsExecCalls() public callerOwner {
        wallet.exposed_initWallet(address(this));

        WalletImpl.Call[] memory calls = new WalletImpl.Call[](1);
        calls[0] = WalletImpl.Call({to: users.alice, value: 1 ether, data: "0x123456789"});
        expectEmit();
        emit ExecCalls(calls);
        wallet.execCalls(calls);
    }

    /// -----------------------------------------------------------------------
    /// tests - fuzz
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// tests - fuzz - init
    /// -----------------------------------------------------------------------

    function testFuzz_init_setsOwner(address owner_) public {
        wallet.exposed_initWallet(owner_);
        assertEq(wallet.$owner(), owner_);
    }

    function testFuzz_init_emitsOwnershipTransferred(address owner_) public {
        expectEmit();
        emit OwnershipTransferred(address(0), owner_);
        wallet.exposed_initWallet(owner_);
    }

    /// -----------------------------------------------------------------------
    /// tests - fuzz - execCalls
    /// -----------------------------------------------------------------------

    function testFuzz_RevertWhen_CallerNotOwner_execCalls(address owner_, address prankOwner_) public {
        wallet.exposed_initWallet(owner_);
        vm.prank(prankOwner_);

        vm.assume(owner_ != prankOwner_);

        vm.expectRevert(Unauthorized.selector);
        WalletImpl.Call[] memory calls = new WalletImpl.Call[](0);
        wallet.execCalls(calls);
    }

    function testFuzz_execCalls_executesCalls(address owner_, FuzzCallsParams calldata params_) public callerOwner {
        wallet.exposed_initWallet(owner_);

        WalletImpl.Call[] memory calls = cleanFuzzCalls(params_);
        for (uint256 i; i < calls.length; i++) {
            WalletImpl.Call memory call = calls[i];
            vm.expectCall(call.to, call.value, call.data);
        }
        vm.prank(owner_);
        wallet.execCalls(calls);
    }

    function testFuzz_execCalls_emitsExecCalls(address owner_, FuzzCallsParams calldata params_) public callerOwner {
        wallet.exposed_initWallet(owner_);

        WalletImpl.Call[] memory calls = cleanFuzzCalls(params_);
        expectEmit();
        emit ExecCalls(calls);
        vm.prank(owner_);
        wallet.execCalls(calls);
    }

    /// -----------------------------------------------------------------------
    /// internal
    /// -----------------------------------------------------------------------

    function cleanFuzzCalls(FuzzCallsParams calldata params_) internal returns (WalletImpl.Call[] memory calls) {
        uint256 boundedCallsLength = bound(params_.callsLength, 0, FUZZ_CALLS_MAX_LENGTH);

        calls = new WalletImpl.Call[](boundedCallsLength);
        for (uint256 i; i < boundedCallsLength; i++) {
            FuzzCall calldata fuzzCall = params_.fuzzCalls[i];
            assumeNoPrecompiles(fuzzCall.to);
            assumePayable(fuzzCall.to);
            vm.assume(fuzzCall.to != address(wallet));
            vm.assume(fuzzCall.to != address(walletImpl));

            uint256 boundedValue = bound(fuzzCall.value, 0, FUZZ_CALL_MAX_VALUE);
            uint256 boundedDataLength = bound(fuzzCall.dataLength, 0, FUZZ_CALL_MAX_DATA_LENGTH);
            bytes memory boundedData = boundedBytes(fuzzCall.data, boundedDataLength);
            calls[i] = WalletImpl.Call({to: fuzzCall.to, value: boundedValue, data: boundedData});
        }
    }

    function boundedBytes(bytes32[FUZZ_CALL_MAX_DATA_LENGTH_IN_WORDS] calldata data_, uint256 boundedDataLength_)
        internal
        pure
        returns (bytes memory boundedData)
    {
        boundedData = abi.encodePacked(data_);
        assembly {
            mstore(boundedData, boundedDataLength_)
        }
    }
}

contract WalletImplHarness is WalletImpl {
    function exposed_initWallet(address owner_) external {
        __initWallet(owner_);
    }
}

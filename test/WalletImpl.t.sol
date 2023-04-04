// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import {LibClone} from "src/LibClone.sol";
import {WalletImpl} from "src/WalletImpl.sol";

contract WalletImplTest is Test {
    using LibClone for address;

    uint256 constant FUZZ_CALL_MAX = 32;

    address payable alice;
    WalletImplHarness public walletImpl;
    WalletImplHarness public wallet;

    error Unauthorized();

    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);
    event ExecCalls(WalletImpl.Call[] calls);

    function setUp() public virtual {
        alice = createUser("Alice");

        walletImpl = new WalletImplHarness();
        wallet = WalletImplHarness(address(walletImpl).clone());
        vm.deal({ account: address(wallet), newBalance: 1 << 96 });
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
        vm.expectEmit(true, true, true, true);
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
        calls[0] = WalletImpl.Call({to: alice, value: 1 ether, data: "0x123456789"});
        vm.expectCall(alice, 1 ether, "0x123456789");
        wallet.execCalls(calls);
    }

    function test_execCalls_emitsExecCalls() public callerOwner {
        wallet.exposed_initWallet(address(this));

        WalletImpl.Call[] memory calls = new WalletImpl.Call[](1);
        calls[0] = WalletImpl.Call({to: alice, value: 1 ether, data: "0x123456789"});
        vm.expectEmit(true, true, true, true);
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
        vm.expectEmit(true, true, true, true);
        emit OwnershipTransferred(address(0), owner_);
        wallet.exposed_initWallet(owner_);
    }

    /// -----------------------------------------------------------------------
    /// tests - basic - execCalls
    /// -----------------------------------------------------------------------

    function test_RevertWhen_CallerNotOwner_execCalls(address owner_, address prankOwner_) public {
        vm.assume(owner_ != prankOwner_);

        wallet.exposed_initWallet(owner_);

        vm.prank(prankOwner_);
        vm.expectRevert(Unauthorized.selector);
        WalletImpl.Call[] memory calls = new WalletImpl.Call[](0);
        wallet.execCalls(calls);
    }

    function test_execCalls_executesCalls(address owner_, WalletImpl.Call[FUZZ_CALL_MAX] calldata calls_, uint8 callsLength_) public callerOwner {
        WalletImpl.Call[] memory calls = cleanCalls(calls_, callsLength_);
        wallet.exposed_initWallet(owner_);

        vm.prank(owner_);
        for (uint256 i; i < calls.length; i++) {
            WalletImpl.Call memory call = calls[i];
            vm.expectCall(call.to, call.value, call.data);
        }
        wallet.execCalls(calls);
    }

    function test_execCalls_emitsExecCalls(address owner_, WalletImpl.Call[FUZZ_CALL_MAX] calldata calls_, uint8 callsLength_) public callerOwner {
        WalletImpl.Call[] memory calls = cleanCalls(calls_, callsLength_);
        wallet.exposed_initWallet(owner_);

        vm.prank(owner_);
        vm.expectEmit(true, true, true, true);
        emit ExecCalls(calls);
        wallet.execCalls(calls);
    }

    /// -----------------------------------------------------------------------
    /// internal
    /// -----------------------------------------------------------------------

    // TODO: move into base contract ?

    function cleanCalls(WalletImpl.Call[FUZZ_CALL_MAX] calldata calls_, uint8 callsLength_) internal returns (WalletImpl.Call[] memory calls) {
        uint256 boundedCallsLength = bound(callsLength_, 1, FUZZ_CALL_MAX);
        calls = new WalletImpl.Call[](boundedCallsLength);
        for (uint256 i; i < boundedCallsLength; i++) {
            WalletImpl.Call calldata call = calls_[i];
            assumeNoPrecompiles(call.to);
            assumePayable(call.to);
            vm.assume(call.value < uint256(1e18));
            vm.assume(call.to != address(wallet));
            calls[i] = call;
        }
    }

    /// @dev Generates an address by hashing the name, labels the address and funds it with 100 ETH, 1 million DAI,
    /// and 1 million USDC.
    function createUser(string memory name) internal returns (address payable addr) {
        addr = payable(address(uint160(uint256(keccak256(abi.encodePacked(name))))));
        vm.label({ account: addr, newLabel: name });
        vm.deal({ account: addr, newBalance: 100 ether });
        /* deal({ token: address(dai), to: addr, give: 1_000_000e18 }); */
    }
}

contract WalletImplHarness is WalletImpl {
    function exposed_initWallet(address owner_) external {
        __initWallet(owner_);
    }
}

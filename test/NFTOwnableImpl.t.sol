// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {ERC721} from "solmate/tokens/ERC721.sol";

import {LibClone} from "src/LibClone.sol";
import {NFTOwnableImpl} from "src/Ownable/NFTOwnableImpl.sol";

import {MockERC721} from "test/mocks/MockERC721.sol";
import {BaseTest} from "test/base.t.sol";

contract NFTOwnableImplTest is BaseTest {
    using LibClone for address;

    NFTOwnableImplHarness public nftOwnableImpl;
    NFTOwnableImplHarness public nftOwnable;
    TestERC721 public testNFT;

    error Unauthorized();
    error InvalidFunction();

    function setUp() public virtual override {
        nftOwnableImpl = new NFTOwnableImplHarness();
        nftOwnable = NFTOwnableImplHarness(address(nftOwnableImpl).clone());

        testNFT = new TestERC721("Test ERC 721", "TEST");
        nftOwnable.exposed_initNFTOwnable(address(testNFT));
    }

    /// -----------------------------------------------------------------------
    /// tests - basic - transferOwnership
    /// -----------------------------------------------------------------------

    function test_RevertWhen_CallerNotOwner_transferOwnership() public {
        vm.expectRevert(Unauthorized.selector);
        nftOwnable.transferOwnership(address(this));
    }

    function test_RevertWhen_CallerIsOwner_transferOwnership() public {
        testNFT.exposed_setOwner(address(this));

        vm.expectRevert(InvalidFunction.selector);
        nftOwnable.transferOwnership(address(this));
    }

    /// -----------------------------------------------------------------------
    /// tests - fuzz - transferOwnership
    /// -----------------------------------------------------------------------

    function testFuzz_RevertWhen_CallerNotOwner_transferOwnership(address owner_, address prankOwner_) public {
        vm.assume(owner_ != prankOwner_);

        vm.prank(prankOwner_);
        vm.expectRevert(Unauthorized.selector);
        nftOwnable.transferOwnership(prankOwner_);
    }

    function testFuzz_RevertWhen_CallerIsOwner_transferOwnership(address owner_, address prankOwner_) public {
        vm.assume(owner_ != prankOwner_);

        testNFT.exposed_setOwner(owner_);

        vm.prank(owner_);
        vm.expectRevert(InvalidFunction.selector);
        nftOwnable.transferOwnership(prankOwner_);
    }
}

contract NFTOwnableImplHarness is NFTOwnableImpl {
    address internal $nftContract;

    function exposed_initNFTOwnable(address nftContract_) external {
        $nftContract = nftContract_;
    }

    function nftContract() public view override returns (ERC721) {
        return ERC721($nftContract);
    }

    function tokenId() public pure override returns (uint256) {
        return 0;
    }
}

contract TestERC721 is MockERC721 {
    address internal $owner;

    constructor(string memory _name, string memory _symbol) MockERC721(_name, _symbol) {}

    function exposed_setOwner(address owner_) public {
        $owner = owner_;
    }

    function ownerOf(uint256) public view override returns (address owner) {
        owner = $owner;
    }
}

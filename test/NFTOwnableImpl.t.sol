// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {ERC721} from "solmate/tokens/ERC721.sol";

import {LibClone} from "src/LibClone.sol";
import {NFTOwnableImpl} from "src/Ownable/NFTOwnableImpl.sol";

import {MockERC721} from "test/mocks/MockERC721.sol";
import {BaseTest} from "test/base.t.sol";

contract NFTOwnableImplTest is BaseTest {
    using LibClone for address;

    uint256 constant TOKEN_ID = 0;

    NFTOwnableImplHarness public nftOwnableImpl;
    NFTOwnableImplHarness public nftOwnable;

    error Unauthorized();
    error InvalidFunction();

    function setUp() public virtual override {
        super.setUp();

        nftOwnableImpl = new NFTOwnableImplHarness();
        nftOwnable = NFTOwnableImplHarness(address(nftOwnableImpl).clone());

        nftOwnable.exposed_initNFTContract(mockERC721, TOKEN_ID);
    }

    /// -----------------------------------------------------------------------
    /// tests - basic - init
    /// -----------------------------------------------------------------------

    function test_init_doesNothing() public {
        nftOwnable.exposed_initOwnable(address(this));
    }

    /// -----------------------------------------------------------------------
    /// tests - basic - transferOwnership
    /// -----------------------------------------------------------------------

    function test_RevertWhen_CallerNotOwner_transferOwnership() public {
        address nftOwner = makeAddr("nftOwner");
        MockERC721(mockERC721).mint(nftOwner, TOKEN_ID);

        vm.expectRevert(Unauthorized.selector);
        nftOwnable.transferOwnership(address(this));
    }

    function test_RevertWhen_CallerIsOwner_transferOwnership() public {
        MockERC721(mockERC721).mint(address(this), TOKEN_ID);

        vm.expectRevert(InvalidFunction.selector);
        nftOwnable.transferOwnership(address(this));
    }

    /// -----------------------------------------------------------------------
    /// tests - fuzz - init
    /// -----------------------------------------------------------------------

    function testFuzz_init_doesNothing(address owner_) public {
        nftOwnable.exposed_initOwnable(owner_);
    }

    /// -----------------------------------------------------------------------
    /// tests - fuzz - transferOwnership
    /// -----------------------------------------------------------------------

    function testFuzz_RevertWhen_CallerNotOwner_transferOwnership(address owner_, address prankOwner_) public {
        vm.assume(owner_ != prankOwner_);
        vm.assume(owner_ != address(0));

        MockERC721(mockERC721).mint(owner_, TOKEN_ID);

        vm.prank(prankOwner_);
        vm.expectRevert(Unauthorized.selector);
        nftOwnable.transferOwnership(prankOwner_);
    }

    function testFuzz_RevertWhen_CallerIsOwner_transferOwnership(address owner_, address receiver_) public {
        vm.assume(owner_ != receiver_);
        vm.assume(owner_ != address(0));

        MockERC721(mockERC721).mint(owner_, TOKEN_ID);

        vm.prank(owner_);
        vm.expectRevert(InvalidFunction.selector);
        nftOwnable.transferOwnership(receiver_);
    }
}

contract NFTOwnableImplHarness is NFTOwnableImpl {
    address internal $nftContract;
    uint256 internal $tokenId;

    function exposed_initOwnable(address owner_) external {
        __initOwnable(owner_);
    }

    function exposed_initNFTContract(address nftContract_, uint256 tokenId_) external {
        $nftContract = nftContract_;
        $tokenId = tokenId_;
    }

    function nftContract() public view override returns (ERC721) {
        return ERC721($nftContract);
    }

    function tokenId() public view override returns (uint256) {
        return $tokenId;
    }
}

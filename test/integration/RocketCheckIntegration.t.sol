// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/producer/RoyaltyNFT.sol";
import "../../src/TokenSpliter.sol";
import "../MockedERC20.sol";
import "../../src/producer/Producer.sol";
import "../../src/retailer/RetailMarketplace.sol";

contract RocketCheckIntegration is Test {
    RoyaltyNFT public royaltyNftPartner1;
    RoyaltyNFT public royaltyNftPartner2;
    
    MockedERC20 token1;
    MockedERC20 token2;
    Producer producer;
    RetailMarketplace marketplace;

    address owner;
    address developer;
    address partner1;
    address partner2;
    address user1;
    address user2;

    function setUp() public {
        owner = address(this);
        developer = address(0x123);
        
        partner1 = address(0x11);
        partner2 = address(0x12);
        
        user1 = payable(address(0x2));
        user2 = payable(address(0x3));

        token1 = new MockedERC20(1000 * 1e18, "TokenFirst", "TKF");
        token2 = new MockedERC20(1000 * 1e18, "TokenSecond", "TKS");

        vm.startPrank(developer);
        producer = new Producer();
        marketplace = new RetailMarketplace(producer);

        producer.whitelistParner(partner1, "PARTNER COLLECTION 1", "PART1");
        producer.whitelistParner(partner2, "PARTNER COLLECTION 2", "PART2");

        royaltyNftPartner1 = RoyaltyNFT(producer.getPartnerNFTContract(partner1));
        royaltyNftPartner2 = RoyaltyNFT(producer.getPartnerNFTContract(partner2));

        producer.whitelistToken(token1);
        producer.whitelistToken(token2);
        vm.stopPrank();
    }

    function testPartnerNftContracts() public {
        assertEq(address(royaltyNftPartner1), producer.getPartnerNFTContract(partner1), "Partner1 Address Not the same");
        assertEq(address(royaltyNftPartner2), producer.getPartnerNFTContract(partner2), "Partner2 Address Not the same");
    } 

    function testWhitelistPartner() public {
        bool isPartner1 = producer.checkPartnerShip(partner1);
        assertTrue(isPartner1, "Partner 1 is not whitelisted");
        
        bool isPartner2 = producer.checkPartnerShip(partner2);
        assertTrue(isPartner2, "Partner 2 is not whitelisted");
    }

    function testWhitelistERC20() public {
        bool isTokenWhitelist1 = producer.checkERC20(token1);
        assertTrue(isTokenWhitelist1, "token 1 is not whitelisted");
        
        bool isTokenWhitelist2 = producer.checkERC20(token2);
        assertTrue(isTokenWhitelist2, "token 2 is not whitelisted");
    }

    function testMintNFTPartner() public {
        vm.startPrank(partner1);
        string memory ipfsUrl1 = "https://ipfs.lol.com/";
        string memory ipfsUrlFinal1 = "https://ipfs.lol.com/0.json";
        royaltyNftPartner1.safeMint(partner1, ipfsUrl1);

        assertEq(royaltyNftPartner1.ownerOf(0), partner1, "Owner of the minted token should be the receiver address");
        assertEq(royaltyNftPartner1.tokenURI(0), ipfsUrlFinal1, "URI of the minted token should match the provided URI");
        vm.stopPrank();

        vm.startPrank(partner2);
        string memory ipfsUrl2 = "https://ipfs2.lol.com/";
        string memory ipfsUrlFinal2 = "https://ipfs2.lol.com/0.json";
        royaltyNftPartner2.safeMint(partner2, ipfsUrl2);

        assertEq(royaltyNftPartner2.ownerOf(0), partner2, "Owner of the minted token should be the receiver address");
        assertEq(royaltyNftPartner2.tokenURI(0), ipfsUrlFinal2, "URI of the minted token should match the provided URI");
        vm.stopPrank();   
    }

    function testTransfer() public {
        string memory ipfsUrl = "https://ipfs.lol.com";
        vm.startPrank(partner1);
        royaltyNftPartner1.safeMint(partner1, ipfsUrl);
        assertEq(royaltyNftPartner1.ownerOf(0), partner1, "Owner of the minted token should be the receiver address");

        royaltyNftPartner1.approve(partner1, 0);
        royaltyNftPartner1.transferFrom(partner1, user1, 0);
        vm.stopPrank();

        vm.startPrank(user1);
        assertTrue(royaltyNftPartner1.balanceOf(user1) >= 1, "User 1 have no NFT");
        assertEq(royaltyNftPartner1.ownerOf(0), user1, "Owner of the minted token should be the receiver address");
        vm.stopPrank();

        vm.startPrank(partner2);
        royaltyNftPartner2.safeMint(partner2, ipfsUrl);
        assertEq(royaltyNftPartner2.ownerOf(0), partner2, "Owner of the minted token should be the receiver address");

        royaltyNftPartner2.approve(partner2, 0);
        royaltyNftPartner2.transferFrom(partner2, user2, 0);
        vm.stopPrank();

        vm.startPrank(user2);
        assertTrue(royaltyNftPartner2.balanceOf(user2) >= 1, "User 1 have no NFT");
        assertEq(royaltyNftPartner2.ownerOf(0), user2, "Owner of the minted token should be the receiver address");
        vm.stopPrank();
    }

    function testListing() public {
        string memory ipfsUrl = "https://ipfs.lol.com";
        uint256 nftId = 0;
        uint256 price = 100 * 1e18;
        
        vm.startPrank(partner1);

        royaltyNftPartner1.safeMint(partner1, ipfsUrl);
        royaltyNftPartner1.approve(address(marketplace), nftId);

        marketplace.list(nftId, price, token1, royaltyNftPartner1);
        (address _owner, uint256 listedPrice, bool isListed, IERC20 paymentToken, IERC721 nft, uint256 tokenId) = marketplace.listings(nftId);
        
        vm.stopPrank();

        assertEq(_owner, partner1, "Owner should be producer1");
        assertEq(listedPrice, price, "Price should be 100 tokens");
        assertEq(isListed, true, "NFT should be listed");
        assertEq(tokenId, nftId, "Token Id not mathching");
        assertEq(address(paymentToken), address(token1), "Payment token should be the ERC20 token");
        assertEq(address(nft), address(royaltyNftPartner1), "NFT address should be the RoyaltyNFT");
    }

    function testBuy() public {
        string memory ipfsUrl = "https://ipfs.lol.com";
        uint256 nftId = 0;
        uint256 price = 100 * 1e18;
        
        vm.startPrank(partner1);

        royaltyNftPartner1.safeMint(partner1, ipfsUrl);
        royaltyNftPartner1.approve(address(marketplace), nftId);
        marketplace.list(nftId, price, token1, royaltyNftPartner1);

        vm.stopPrank();
        
        assertEq(royaltyNftPartner1.ownerOf(nftId), partner1, "partner should be the owner of the NFT");

        token1.approve(owner, price);
        token1.transferFrom(owner, user1, price);
        assertEq(token1.balanceOf(user1), price, "User has no token");

        vm.startPrank(user1);

        token1.approve(address(marketplace), price);
        marketplace.buy(nftId);

        assertEq(royaltyNftPartner1.ownerOf(nftId), user1, "customer should be the new owner of the NFT");

        // Verify balances
        uint256 royaltyAmount = (price * 10) / 100;
        uint256 sellerAmount = price - royaltyAmount;

        assertEq(token1.balanceOf(partner1), sellerAmount + royaltyAmount / 2, "Seller should receive the remaining amount");
        assertEq(token1.balanceOf(developer), royaltyAmount / 2, "Developers royalty not received");
        assertEq(token1.balanceOf(user1), 0, "User should not have tokens");

        vm.stopPrank();
    }
}
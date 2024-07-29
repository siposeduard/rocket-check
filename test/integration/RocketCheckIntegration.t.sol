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
        partner2 = address(0x11);
        
        user1 = payable(address(0x2));
        user2 = payable(address(0x3));

        token1 = new MockedERC20(1000 * 1e18);
        token2 = new MockedERC20(1000 * 1e18);

        vm.startPrank(developer);
        producer = new Producer();
        royaltyNftPartner1 = RoyaltyNFT(producer.whitelistParner(partner1, "PARTNER COLLECTION 1", "PART1"));
        royaltyNftPartner2 = RoyaltyNFT(producer.whitelistParner(partner2, "PARTNER COLLECTION 2", "PART2"));

        producer.whitelistToken(token1);
        producer.whitelistToken(token2);
        vm.stopPrank();
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
}
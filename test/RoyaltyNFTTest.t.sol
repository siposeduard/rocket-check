// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/producer/RoyaltyNFT.sol";
import "../src/TokenSpliter.sol";

contract RoyaltyNFTTest is Test {
    RoyaltyNFT public royaltyNft;
    TokenSpliter tokenSpliter;
    address owner;
    address retail;
    address user1;
    address user2;

    function setUp() public {
        owner = address(this);
        retail = address(0x1);
        user1 = payable(address(0x2));
        user2 = payable(address(0x3));

        vm.startPrank(retail);
        tokenSpliter = new TokenSpliter(address(0x0123), retail);
        royaltyNft = new RoyaltyNFT(tokenSpliter, "NAME", "SYMBOL", retail);
        vm.stopPrank();
    }

    function testConstructor() public {
        assertEq(address(royaltyNft.tokenRoyaltySpliter()), address(tokenSpliter), "tokenSpliter address should match the one provided in constructor");
    }

    function testSafeMint() public {
        string memory uri = "https://example.com/nft/";
        string memory uriFinal = "https://example.com/nft/0.json";
        vm.startPrank(retail);

        royaltyNft.safeMint();
        royaltyNft.setBaseURI(uri);
        assertEq(royaltyNft.ownerOf(0), retail, "Owner of the minted token should be the receiver address");
        assertEq(royaltyNft.tokenURI(0), uriFinal, "URI of the minted token should match the provided URI");

        vm.stopPrank();
    }

    function testTokenURI() public {
        string memory uri = "https://example.com/nft/";
        string memory uriFinal = "https://example.com/nft/0.json";
        vm.startPrank(retail);

        royaltyNft.safeMint();
        royaltyNft.setBaseURI(uri);
        assertEq(royaltyNft.tokenURI(0), uriFinal, "Token URI should return the correct URI");

        vm.stopPrank();
    }

    function testRoyaltyInfo() public {
        uint256 tokenId = 0;
        uint256 salePrice = 10000; // 100 dollars

        vm.startPrank(retail);

        royaltyNft.safeMint();
        royaltyNft.setBaseURI("https://example.com/nft/1");
        
        vm.stopPrank();

        (address receiver, uint256 royaltyAmount) = royaltyNft.royaltyInfo(tokenId, salePrice);
        assertEq(receiver, address(tokenSpliter), "Royalty receiver should be the retail");
        assertEq(royaltyAmount, 1000, "Royalty amount should be 10% of the sale price");
    }
}
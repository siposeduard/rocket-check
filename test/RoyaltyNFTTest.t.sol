// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/producer/RoyaltyNFT.sol";
import "../src/TokenAndEthSplitter.sol";

contract RoyaltyNFTTest is Test {
    RoyaltyNFT public royaltyNft;
    TokenAndEthSplitter tokenSpliter;
    address owner;
    address retail;
    address user1;
    address user2;

    function setUp() public {
        owner = address(this);
        retail = address(0x1);
        user1 = payable(address(0x2));
        user2 = payable(address(0x3));

        tokenSpliter = new TokenAndEthSplitter(address(0x0123), owner);
        royaltyNft = new RoyaltyNFT(tokenSpliter);
    }

    function testConstructor() public {
        assertEq(address(royaltyNft.tokenRoyaltySpliter()), address(tokenSpliter), "tokenSpliter address should match the one provided in constructor");
    }

    function testSafeMint() public {
        address to = address(0x456);
        string memory uri = "https://example.com/nft/1";
        royaltyNft.safeMint(to, uri);
        assertEq(royaltyNft.ownerOf(0), to, "Owner of the minted token should be the receiver address");
        assertEq(royaltyNft.tokenURI(0), uri, "URI of the minted token should match the provided URI");
    }

    function testTokenURI() public {
        address to = address(0x456);
        string memory uri = "https://example.com/nft/1";
        royaltyNft.safeMint(to, uri);
        assertEq(royaltyNft.tokenURI(0), uri, "Token URI should return the correct URI");
    }

    function testRoyaltyInfo() public {
        uint256 tokenId = 0;
        uint256 salePrice = 10000; // 100 dollars
        royaltyNft.safeMint(retail, "https://example.com/nft/1");

        (address receiver, uint256 royaltyAmount) = royaltyNft.royaltyInfo(tokenId, salePrice);
        assertEq(receiver, address(tokenSpliter), "Royalty receiver should be the retail");
        assertEq(royaltyAmount, 1000, "Royalty amount should be 10% of the sale price");
    }
}
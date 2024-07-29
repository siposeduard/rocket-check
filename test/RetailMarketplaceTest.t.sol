// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/producer/RoyaltyNFT.sol";
import "../src/producer/Producer.sol";
import "../src/TokenSpliter.sol";
import "../src/retailer/RetailMarketplace.sol";
import "../src/RocketToken.sol";

contract RetailMarketplaceTest is Test {
    RoyaltyNFT public royaltyNft;
    TokenSpliter public tokenSpliter;
    RocketToken public token;
    Producer public producer;
    RetailMarketplace public marketplace;

    address public owner;
    address public developer;
    address public retail;
    address public producer1;
    address public customer;

    function setUp() public {
        owner = address(this);
        retail = address(0x1);
        developer = address(0x123);
        producer1 = payable(address(0x2));
        customer = payable(address(0x3));

        vm.prank(owner);

        token = new RocketToken(1000 * 1e18, "TokenFirst", "TKF");
        tokenSpliter = new TokenSpliter(developer, retail);
        royaltyNft = new RoyaltyNFT(tokenSpliter, "RoyaltyNFT", "RNFT", owner);
        producer = new Producer();
        marketplace = new RetailMarketplace(producer);

        // Initial token distribution
        token.transfer( producer1, 100 * 1e18);
        token.transfer( customer, 500 * 1e18);
    }

  function testListNFT() public {
    vm.prank(owner);

    address nftContractAddress = producer.whitelistParner(producer1, "TestNFT", "TNFT");

    vm.stopPrank();

    vm.startPrank(producer1);

    royaltyNft = RoyaltyNFT(nftContractAddress);
    royaltyNft.safeMint();
    royaltyNft.setBaseURI("https://example.com/token1");
    uint256 globalId = 0;
    uint256 price = 100 * 1e18;

    royaltyNft.approve(address(marketplace), globalId);

    vm.stopPrank();

    vm.prank(owner);

    // Whitelist the token
    producer.whitelistToken(token);

    vm.startPrank(producer1);

    royaltyNft.approve(address(marketplace), globalId);
    marketplace.list(globalId, price, token, royaltyNft);

    vm.stopPrank();

    (address _owner, uint256 listedPrice, bool isListed, IERC20 paymentToken, IERC721 nft, uint256 tokenId) = marketplace.listings(globalId);
    assertEq(_owner, producer1, "Owner should be producer1");
    assertEq(listedPrice, price, "Price should be 100 tokens");
    assertEq(isListed, true, "NFT should be listed");
    assertEq(tokenId, globalId, "Token Id not mathching");
    assertEq(address(paymentToken), address(token), "Payment token should be the ERC20 token");
    assertEq(address(nft), address(royaltyNft), "NFT address should be the RoyaltyNFT");
  }

    function testDeListNFT() public {
      vm.prank(owner);

      address nftContractAddress = producer.whitelistParner(producer1, "TestNFT", "TNFT");

      vm.stopPrank();

      vm.startPrank(producer1);

      royaltyNft = RoyaltyNFT(nftContractAddress);
      royaltyNft.safeMint();
      royaltyNft.setBaseURI("https://example.com/token1");
      uint256 tokenId = 0;
      uint256 price = 100 * 1e18;
      royaltyNft.approve(address(marketplace), tokenId);

      vm.stopPrank();

       vm.prank(owner);

      // Whitelist the token
      producer.whitelistToken(token);

      vm.prank(producer1);
      marketplace.list(tokenId, price, token, royaltyNft);

      vm.prank(producer1);
      marketplace.deList(tokenId);

      (, , bool isListed, , , ) = marketplace.listings(tokenId);
      assertEq(isListed, false, "NFT should be delisted");
    }

  function testBuyNFT() public {
    vm.prank(owner);

    address nftContractAddress = producer.whitelistParner(producer1, "TestNFT", "TNFT");

    vm.startPrank(producer1);

    royaltyNft = RoyaltyNFT(nftContractAddress);
    royaltyNft.safeMint();
    royaltyNft.setBaseURI("https://example.com/token1");
    uint256 globalId = 0;
    uint256 price = 100 * 1e18;

    royaltyNft.approve(address(marketplace), globalId);

    vm.stopPrank();

    vm.prank(owner);

    // Whitelist the token
    producer.whitelistToken(token);

    vm.startPrank(producer1);

    royaltyNft.approve(address(marketplace), globalId);
    marketplace.list(globalId, price, token, royaltyNft);

    vm.stopPrank();

    vm.prank(customer);

    token.approve(address(marketplace), price);


    console.log("producerBalnce", token.balanceOf(producer1));
    vm.prank(customer);
    marketplace.buy(globalId);

    assertEq(royaltyNft.ownerOf(globalId), customer, "customer should be the new owner of the NFT");

    console.log("producerBalnce", token.balanceOf(producer1));

    // Verify balances
    uint256 royaltyAmount = (price * 10) / 100;
    uint256 sellerAmount = price - royaltyAmount;

    assertEq(token.balanceOf(producer1), 100 * 1e18 + sellerAmount + royaltyAmount / 2, "Seller should receive the remaining amount");
  }
}
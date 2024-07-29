// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { Producer } from '../producer/Producer.sol';
import '../producer/RoyaltyNFT.sol';
import "../TokenSpliter.sol";

contract RetailMarketplace {

  Producer producer;
  uint256 globalId;

  struct Listing {
    address owner;
    uint256 price;
    bool isListed;
    IERC20 paymentToken;
    IERC721 nft;
    uint256 tokenId;
  }

  mapping(uint256 => Listing) public listings;

  constructor(Producer _producer) {
    producer = _producer;
  }

  function list(uint256 tokenId, uint256 price, IERC20 paymentToken, IERC721 nft) external {
    require(producer.checkPartnerShip(msg.sender), "Not on whitelist");
    require(price > 0, "Price must be greater than zero");
    require(producer.checkERC20(paymentToken), "Token not whitelisted");

    // Approve the marketplace to transfer the NFT on behalf of the owner
    // nft.approve(address(this), tokenId);

    // List the NFT
    listings[globalId] = Listing({
        owner: msg.sender,
        price: price,
        isListed: true,
        paymentToken: paymentToken,
        nft: nft,
        tokenId: tokenId
    });

    globalId++;
  }

  function deList(uint256 _globalId) external {
    require(listings[_globalId].owner == msg.sender, "Caller is not the owner");
    listings[_globalId].isListed = false;
  }

  function buy(uint256 _globalId) external {
    Listing storage listing = listings[_globalId];
    require(listing.isListed, "NFT is not listed for sale");

    // Get the NFT contract associated with the partner
    address nftContractAddress = producer.getPartnerNFTContract(listing.owner);
    require(nftContractAddress != address(0), "NFT contract not found for partner");
    ERC721Royalty nftContract = ERC721Royalty(nftContractAddress);

    // Get royalty information
    (address royaltyRecipient, uint256 royaltyAmount) = nftContract.royaltyInfo(_globalId, listing.price);

    // Transfer payment from buyer to seller and royalty recipient
    listing.paymentToken.transferFrom(msg.sender, royaltyRecipient, royaltyAmount);
    listing.paymentToken.transferFrom(msg.sender, listing.owner, listing.price - royaltyAmount);

    TokenSpliter(royaltyRecipient).splitToken(listing.paymentToken);

    // Transfer the NFT to the buyer
    nftContract.safeTransferFrom(listing.owner, msg.sender, _globalId);

    // Update listing
    listing.isListed = false;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./RoyaltyNFT.sol";
import "../TokenAndEthSplitter.sol";

interface IProduct  {
    function checkPartnerShip(address partnerAddress) external view returns(bool);
}

contract Producer is IProduct, Ownable {
    address developer;
    mapping(address owner => address nftContract) partners;

    constructor() Ownable(msg.sender) {
        developer = msg.sender;
    }

    function whitelistParner(address partnerAddress, string memory name, string memory symbol) external onlyOwner returns(address) {
        address nftContract = factory(partnerAddress, name, symbol);
        partners[partnerAddress] = nftContract;
        return nftContract;
    }

    function factory(address partnerAddress, string memory name, string memory symbol) internal onlyOwner returns(address) {
        TokenAndEthSplitter paymentSpliter = new TokenAndEthSplitter(developer, partnerAddress);
        RoyaltyNFT nftContract = new RoyaltyNFT(paymentSpliter, name, symbol);

        return(address(nftContract));
    }

    function checkPartnerShip(address partnerAddress) external view returns(bool) {
        return partners[partnerAddress] != 0x0000000000000000000000000000000000000000;
    }

    function removePartner(address partnerAddress) external onlyOwner returns(bool) {
        partners[partnerAddress] = 0x0000000000000000000000000000000000000000;
        return(true);
    }
}
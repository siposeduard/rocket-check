// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./RoyaltyNFT.sol";
import "../TokenAndEthSplitter.sol";
import "./IProducer.sol";

contract Producer is IProducer, Ownable {
    address developer;

    mapping(address owner => address nftContract) public partners;
    mapping(IERC20 erc20 => bool isWhitelisted) erc20Whitelists;

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
        RoyaltyNFT nftContract = new RoyaltyNFT(paymentSpliter, name, symbol, partnerAddress);

        return(address(nftContract));
    }

    function checkPartnerShip(address partnerAddress) external view returns(bool) {
        return partners[partnerAddress] != 0x0000000000000000000000000000000000000000;
    }

    function getPartnerNFTContract(address partnerAddress) external view returns(address) {
        return partners[partnerAddress];
    }

    function whitelistToken(IERC20 erc20Whitelist) external onlyOwner returns(bool) {
        erc20Whitelists[erc20Whitelist] = true;
        return true;
    }

    function removeWhitelistToken(IERC20 erc20Whitelist) external onlyOwner returns(bool) {
        erc20Whitelists[erc20Whitelist] = false;
        return true;
    }

    function checkERC20(IERC20 erc20Whitelist) external view returns(bool) {
        return erc20Whitelists[erc20Whitelist] == true;
    }

    function removePartner(address partnerAddress) external onlyOwner returns(bool) {
        partners[partnerAddress] = 0x0000000000000000000000000000000000000000;
        return(true);
    }
}
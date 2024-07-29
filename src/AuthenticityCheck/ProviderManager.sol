// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./AuthenticityNFT.sol";
import "./ItemManager.sol";

import {console} from "forge-std/Script.sol";

contract ProviderManager is AccessControl {
    ItemManager itemManager;
    AuthenticityNFT authenticityNFT;

    struct Provider {
        uint id;
        string name;
        address providerAddress;
    }

    mapping(uint => Provider) public providers;
    uint public providersCount;


    constructor(ItemManager _itemManager) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        authenticityNFT = new AuthenticityNFT();
        itemManager = _itemManager;
    }

    // Function to add a new provider and grant them the MINTER_ROLE
    function addProvider(string memory _name, address _providerAddress) public onlyRole(DEFAULT_ADMIN_ROLE) {
        providersCount++;
        providers[providersCount] = Provider(providersCount, _name, _providerAddress);
    }

    // Function to remove a provider
    function removeProvider(uint _providerId) public onlyRole(DEFAULT_ADMIN_ROLE) {
        delete providers[_providerId];
    }

    // Function to get a provider by ID
    function getProvider(uint _providerId) public view returns (Provider memory) {
        return providers[_providerId];
    }

    // Function that mints an NFT for a given item
    function authAndMint(uint itemId, string memory uniqueCode) public {
        ItemManager.Item memory item = itemManager.getItem(itemId);

        uint256 tokenId = authenticityNFT.safeMint(item.owner, uniqueCode);
        itemManager.authenticateItem(itemId, true, tokenId);
    }

    function ownerOf(uint itemId) public view returns (address) {
        ItemManager.Item memory item = itemManager.getItem(itemId);
        console.log("Item NFT Token ID: ", item.id);
        return authenticityNFT.ownerOf(item.nftTokenId);
    }

    // Function to retrieve all providers
    function getProviders() public view returns (Provider[] memory) {
        Provider[] memory _providers = new Provider[](providersCount);
        for (uint i = 1; i <= providersCount; i++) {
            _providers[i - 1] = providers[i];
        }
        return _providers;
    }
}

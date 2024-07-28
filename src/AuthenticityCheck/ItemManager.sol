// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ItemManager {
    struct Item {
        uint id;
        address owner;
        string uniqueId;
        string[] photoHashes; // Store the hashes of the photos for authenticity
        string deliveryTracking;
        bool isAuthenticated;
        uint providerId;
        uint nftTokenId;
        uint[] ratings;
    }

    mapping(uint => Item) public items;
    uint public itemsCount;

    event ItemRegistered(uint indexed itemId, address indexed owner, string uniqueId);
    event ItemSentForCheck(uint indexed itemId, uint providerId);
    event ItemAuthenticated(uint indexed itemId, bool isAuthenticated, uint nftTokenId);
    event ItemRated(uint indexed itemId, uint rating);

    function registerItem(string memory _uniqueId, string[] memory _photoHashes, string memory _deliveryTracking) public {
        itemsCount++;
        items[itemsCount] = Item(itemsCount, msg.sender, _uniqueId, _photoHashes, _deliveryTracking, false, 0, 0, new uint[](0));
        emit ItemRegistered(itemsCount, msg.sender, _uniqueId);
    }

    function sendItemForCheck(uint _itemId, uint _providerId) public {
        require(items[_itemId].owner == msg.sender, "Only the owner can send the item for check.");
        items[_itemId].providerId = _providerId;
        emit ItemSentForCheck(_itemId, _providerId);
    }

    function getItem(uint _itemId) public view returns (Item memory) {
        return items[_itemId];
    }

    function authenticateItem(uint _itemId, bool _isAuthenticated, uint _nftTokenId) internal {
        items[_itemId].isAuthenticated = _isAuthenticated;
        items[_itemId].nftTokenId = _nftTokenId;
        emit ItemAuthenticated(_itemId, _isAuthenticated, _nftTokenId);
    }

    function rateItem(uint _itemId, uint _rating) public {
        require(items[_itemId].owner != msg.sender, "Owners cannot rate their own items.");
        require(_rating >= 1 && _rating <= 5, "Rating must be between 1 and 5.");
        items[_itemId].ratings.push(_rating);
        emit ItemRated(_itemId, _rating);
    }

    function getItemRating(uint _itemId) public view returns (uint) {
        uint totalRatings = 0;
        for (uint i = 0; i < items[_itemId].ratings.length; i++) {
            totalRatings += items[_itemId].ratings[i];
        }
        return items[_itemId].ratings.length > 0 ? totalRatings / items[_itemId].ratings.length : 0;
    }
}

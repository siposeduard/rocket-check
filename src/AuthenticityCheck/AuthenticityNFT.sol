// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC721, Ownable {
    uint256 private _nextTokenId;

    struct ClothingItem {
        uint256 tokenId;
        string uniqueCode;
    }

    mapping(uint256 => ClothingItem) public clothingItems;

    // Event emitted when a new token is minted
    event TokenMinted(address indexed to, uint256 tokenId, string uniqueCode);

    constructor(address initialOwner)
        ERC721("MyToken", "MTK")
        Ownable(initialOwner)
    {}
    

    // Function to safely mint a new token
    // Only the owner of the contract can call this function
    function safeMint(address to, string memory uniqueCode) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        
        _safeMint(to, tokenId);

        ClothingItem memory newItem = ClothingItem({
            tokenId: tokenId,
            uniqueCode: uniqueCode
        });

        clothingItems[tokenId] = newItem;

        emit TokenMinted(to, tokenId, uniqueCode);
    }


    // Function to retrieve the details of a clothing item by its token ID
    function getClothingItem(uint256 tokenId) public view returns (ClothingItem memory) {
        return clothingItems[tokenId];
    }
}

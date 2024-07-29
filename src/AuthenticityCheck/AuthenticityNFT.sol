// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./ProviderManager.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

contract AuthenticityNFT is ERC721 {
    using Strings for uint256;
    string public baseURI;
    string public baseExtension = ".json";

    uint256 public _nextTokenId = 0;

    struct ClothingItem {
        uint256 tokenId;
        string uniqueCode;
    }

    mapping(uint256 => ClothingItem) public clothingItems;

    // Role definition for minter
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // Event emitted when a new token is minted
    event TokenMinted(address indexed to, uint256 tokenId, string uniqueCode);

    constructor()
        ERC721("AuthenticityNFT", "RCH")
    {}

    // Function to safely mint a new token
    function safeMint(address to, string memory uniqueCode) public returns (uint256) {

        _nextTokenId++;
        uint256 tokenId = _nextTokenId;
        
        _safeMint(to, tokenId);

        ClothingItem memory newItem = ClothingItem({
            tokenId: tokenId,
            uniqueCode: uniqueCode
        });

        clothingItems[tokenId] = newItem;

        emit TokenMinted(to, tokenId, uniqueCode); // Emit the event here

        return tokenId;
    }

    function getBaseURI() public view returns(string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {

        string memory currentBaseURI = getBaseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    // Function to set the base URI
    function setBaseURI(string memory _baseURI) public {
        baseURI = _baseURI;
    }

    // Function to retrieve the details of a clothing item by its token ID
    function getClothingItem(uint256 tokenId) public view returns (ClothingItem memory) {
        return clothingItems[tokenId];
    }

    // Overriding supportsInterface to include AccessControl
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

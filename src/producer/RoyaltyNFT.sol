// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../TokenAndEthSplitter.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract RoyaltyNFT is ERC721Royalty, Ownable {
    uint256 private _nextTokenId;
    
    using Strings for uint256;
    string public baseURI;
    string public baseExtension = ".json";

    TokenAndEthSplitter public immutable tokenRoyaltySpliter;
    uint256 public constant royaltyPercentage = 10;

    mapping(uint256 => address[]) private _ownersHistory;


    constructor(TokenAndEthSplitter  _tokenRoyaltySpliter, string memory name, string memory symbol, address partnerAddress) ERC721(name, symbol) Ownable(partnerAddress) {
        require(address(_tokenRoyaltySpliter) != address(0), "tokenRoyaltySpliter address cannot be zero");
        tokenRoyaltySpliter = _tokenRoyaltySpliter;
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        baseURI = uri;
        _ownersHistory[tokenId].push(to);
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
       require(
            _requireOwned(tokenId) != address(0),
            "ERC721Metadata: URI query for nonexistent token"
        );

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

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Royalty)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // Override royalty info to ensure it's always callable
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) public view override returns (address, uint256) {
        console.log(_tokenId);
        uint256 royaltyAmount = (_salePrice * royaltyPercentage) / 100;
        return (address(tokenRoyaltySpliter), royaltyAmount);
    }

    function getOwnershipHistory(uint256 tokenId) public view returns (address[] memory) {
        return _ownersHistory[tokenId];
    }

    function transferFrom(address from, address to, uint256 tokenId) override(ERC721) public {
        if (from != address(0)) {
           _ownersHistory[tokenId].push(to);
        }
        super.transferFrom(from, to, tokenId);
    }
}
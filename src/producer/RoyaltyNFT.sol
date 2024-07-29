// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../TokenAndEthSplitter.sol";

contract RoyaltyNFT is ERC721Royalty, ERC721URIStorage, Ownable {
    uint256 private _nextTokenId;

    TokenAndEthSplitter public immutable tokenRoyaltySpliter;
    uint256 public constant royaltyPercentage = 10;

    mapping(uint256 => address[]) private _ownersHistory;


    constructor(TokenAndEthSplitter  _tokenRoyaltySpliter, string memory name, string memory symbol) ERC721(name, symbol) Ownable(msg.sender) {
        require(address(_tokenRoyaltySpliter) != address(0), "tokenRoyaltySpliter address cannot be zero");
        tokenRoyaltySpliter = _tokenRoyaltySpliter;
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        _ownersHistory[tokenId].push(to);  // Add the first owner on mint
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Royalty, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // Override royalty info to ensure it's always callable
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) public view override returns (address, uint256) {
        uint256 royaltyAmount = (_salePrice * royaltyPercentage) / 100;
        return (address(tokenRoyaltySpliter), royaltyAmount);
    }

    function getOwnershipHistory(uint256 tokenId) public view returns (address[] memory) {
        return _ownersHistory[tokenId];
    }

    // Override to update the owners history
    // function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721Royalty, ERC721URIStorage) {
    //     if (from != address(0)) {  // Ignore minting
    //         _ownersHistory[tokenId].push(to);
    //     }
    //     super._beforeTokenTransfer(from, to, tokenId);
    // }
}
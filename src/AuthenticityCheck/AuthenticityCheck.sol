// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.20;

// import "./AuthenticityNFT.sol";
// import "./ProviderManager.sol";
// import "./ItemManager.sol";

// contract AuthenticityCheck is AuthenticityNFT, ProviderManager, ItemManager {
//     constructor(address initialOwner, ProviderManager provider)
//         ProviderManager(initialOwner)
//         AuthenticityNFT(initialOwner, provider)
//     {}

//     function authenticateAndMint(uint _itemId, bool _isAuthenticated) public {
//         // Ensure the item has been sent for check and the sender is the assigned provider
//         require(items[_itemId].providerId > 0, "Item must be sent for check first.");
//         // require(providers[items[_itemId].providerId].providerAddress == msg.sender, "Only the assigned provider can authenticate.");

        

//         uint nftTokenId = 0;
//         if (_isAuthenticated) {
//             // Mint the NFT if the item is authenticated
//             safeMint(items[_itemId].owner, items[_itemId].uniqueId);
//             nftTokenId = _nextTokenId - 1; // The newly minted token ID
//         }

//         // Update the item's authentication status and associated NFT token ID
//         // authenticateItem(_itemId, _isAuthenticated, nftTokenId);
//     }

//     // Function to rate an item
//     function rateAuthenticatedItem(uint _itemId, uint _rating) public {
//         require(isItemAuthenticated(_itemId), "Item must be authenticated to be rated.");
//         rateItem(_itemId, _rating);
//     }

//     // Function to check if an item is authenticated
//     function isItemAuthenticated(uint _itemId) public view returns (bool) {
//         return items[_itemId].isAuthenticated;
//     }

//     // Function to retrieve the owner of the NFT associated with an item
//     // function ownerOf(uint _itemId) override public view returns (address) {
//     //     // require(isItemAuthenticated(_itemId), "Item must be authenticated to have an NFT owner.");
//     //     return ownerOf(items[_itemId].nftTokenId);
//     // }


//     function supportsInterface(bytes4 interfaceId)
//         public
//         view
//         virtual
//         override(AuthenticityNFT, AccessControl)
//         returns (bool)
//     {
//         return super.supportsInterface(interfaceId);
//     }
// }

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/AuthenticityCheck/ItemManager.sol";
import "../src/AuthenticityCheck/ProviderManager.sol";

contract AuthenticityCheckTest is Test {
    ProviderManager providerManager;
    ItemManager itemManager;

    address admin = address(1);
    address owner = address(2);
    address owner2 = address(3);
    address provider = address(3);
    address provider2 = address(4);
    address provider3 = address(5);
    address addr2 = address(5);

    function setUp() public {
        console.log("Setting up test...");
        
        vm.startPrank(admin);
        console.log("Deploying AuthenticityCheck as admin:", admin);
        itemManager = new ItemManager();
        providerManager = new ProviderManager(itemManager);

        providerManager.addProvider("Provider 1", provider);

        vm.stopPrank();
    }


    function testWorkFlow() public {
        console.log("Testing work flow...");

        string[] memory photoHashes = new string[](2);
        photoHashes[0] = "hash1";
        photoHashes[1] = "hash2";

        vm.startPrank(owner);
        itemManager.registerItem("Item1", photoHashes, "Tracking1");
        uint itemId = 1;
        vm.stopPrank();

        vm.startPrank(provider);
        providerManager.authAndMint(itemId, "Item1");
        vm.stopPrank();

        ItemManager.Item memory item = itemManager.getItem(itemId);
        assertTrue(item.isAuthenticated);

        vm.startPrank(owner);
        assertEq(providerManager.ownerOf(itemId), owner);
        assertFalse(providerManager.ownerOf(itemId) == addr2);
        vm.stopPrank();

    }

    function testProviders() public {
        ProviderManager.Provider[] memory providers = providerManager.getProviders();
        assertEq(providers.length, 1);
        assertEq(providers[0].name, "Provider 1");
        assertEq(providers[0].providerAddress, provider);

        vm.startPrank(admin);
        providerManager.addProvider("Provider 2", provider2);
        providerManager.addProvider("Provider 3", provider3);
        vm.stopPrank();

        providers = providerManager.getProviders(); // Refresh the providers list
        assertEq(providers.length, 3);
        assertEq(providers[1].name, "Provider 2");
        assertEq(providers[1].providerAddress, provider2);
        assertEq(providers[2].name, "Provider 3");
        assertEq(providers[2].providerAddress, provider3);
    }

    function testItems() public {
        
        // Register item 1
        string[] memory photoHashes = new string[](2);
        photoHashes[0] = "hash1";
        photoHashes[1] = "hash2";

        vm.startPrank(owner);
        itemManager.registerItem("Item1", photoHashes, "Tracking1");
        uint itemId = 1;
        vm.stopPrank();

        // Test the item
        ItemManager.Item memory item = itemManager.getItem(itemId);
        assertEq(item.id, 1);
        assertEq(item.owner, owner);
        assertEq(item.uniqueId, "Item1");
        assertEq(item.photoHashes[0], "hash1");
        assertEq(item.photoHashes[1], "hash2");
        assertEq(item.deliveryTracking, "Tracking1");
        assertEq(item.isAuthenticated, false);
        assertEq(item.providerId, 0);
        assertEq(item.nftTokenId, 0);
        assertEq(item.ratings.length, 0);


        // Register item 2
        string[] memory photoHashes2 = new string[](2);
        photoHashes2[0] = "hash3";
        photoHashes2[1] = "hash4";

        vm.startPrank(owner);
        itemManager.registerItem("Item2", photoHashes2, "Tracking2");
        uint itemId2 = 2;
        vm.stopPrank();

        // Test the item
        ItemManager.Item memory item2 = itemManager.getItem(itemId2);
        assertEq(item2.id, 2);
        assertEq(item2.owner, owner);
        assertEq(item2.uniqueId, "Item2");
        assertEq(item2.photoHashes[0], "hash3");
        assertEq(item2.photoHashes[1], "hash4");
        assertEq(item2.deliveryTracking, "Tracking2");
        assertEq(item2.isAuthenticated, false);
        assertEq(item2.providerId, 0);
        assertEq(item2.nftTokenId, 0);
        assertEq(item2.ratings.length, 0);

        // Test the ownership after authentication
        vm.startPrank(provider);
        providerManager.authAndMint(1, "Item1");
        providerManager.authAndMint(2, "Item2");

        assertEq(providerManager.ownerOf(1), providerManager.ownerOf(2));
        
        vm.stopPrank();


        // Testing a different owner
        vm.startPrank(owner2);

        // Register item 3
        string[] memory photoHashes3 = new string[](2);
        photoHashes3[0] = "hash5";
        photoHashes3[1] = "hash6";

        vm.stopPrank();

        vm.startPrank(owner2);
        itemManager.registerItem("Item1", photoHashes3, "Tracking3");
        vm.stopPrank();

        // Test the ownership after authentication
        vm.startPrank(provider);
        providerManager.authAndMint(3, "Item1");
        assertFalse(providerManager.ownerOf(1) == providerManager.ownerOf(3));
        vm.stopPrank();
    }
}
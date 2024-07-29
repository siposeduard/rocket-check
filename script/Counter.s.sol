// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import "../src/producer/Producer.sol";
import "../test/MockedERC20.sol";
import "../src/retailer/RetailMarketplace.sol";

contract CounterScript is Script {
    function setUp() public {}
    
    function run() public {
        uint256 PrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address deployer = 0x53273F201D39CaEa8F9D6CE39f15434900fB7ac0;
        address partner1 = 0xBa8C58a8C88425Ee96879B12C6caA008C3845863;

        vm.startBroadcast(PrivateKey);

        MockedERC20 myToken = new MockedERC20(10000 * 1e18, "ROCKET TOKEN", "RKT");
        console.log("ROCKET deployed at:", address(myToken));

        myToken.approve(deployer, 200 * 1e18);
        myToken.transferFrom(deployer, partner1, 50 * 1e18);

        Producer prducer = new Producer();
        console.log("Producer deployed at:", address(prducer));

        RetailMarketplace market = new RetailMarketplace(prducer);
        console.log("RetailMarketplace deployed at:", address(market));

        prducer.whitelistParner(partner1, "Partner1NFT", "PART1");

        vm.stopBroadcast();
    }
}
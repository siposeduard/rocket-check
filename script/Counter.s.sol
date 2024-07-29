// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import "../src/producer/Producer.sol";
import "../test/MockedERC20.sol";

contract CounterScript is Script {
    function setUp() public {}
    
    function run() public {
        uint256 PrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address deployer = 0x0000000000000000000000000000000000000000;
        address partner1 = 0x0000000000000000000000000000000000000000;

        vm.startBroadcast(PrivateKey);

        MockedERC20 myToken = new MockedERC20(1000 * 1e18);
        console.log("MyToken deployed at:", address(myToken));

        myToken.approve(deployer, 200 * 1e18);
        myToken.transferFrom(deployer, partner1, 50 * 1e18);

        Producer prducer = new Producer();
        console.log("Producer deployed at:", address(prducer));

        prducer.whitelistParner(partner1, "Partner1NFT", "PART1");

        vm.stopBroadcast();
    }
}
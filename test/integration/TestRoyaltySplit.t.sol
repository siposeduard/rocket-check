// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/producer/RoyaltyNFT.sol";
import "../../src/TokenAndEthSplitter.sol";
import "../MockedERC20.sol";
import "../../src/producer/Producer.sol";

contract TestRoyaltySplit is Test {
    RoyaltyNFT public royaltyNft;
    TokenAndEthSplitter tokenSpliter;
    MockedERC20 token;

    address owner;
    address developer;
    address retail;
    address user1;
    address user2;

    function setUp() public {
        owner = address(this);
        retail = address(0x1);
        developer = address(0x123);
        user1 = payable(address(0x2));
        user2 = payable(address(0x3));

        token = new MockedERC20(1000 * 1e18);
    }

    function testConstructor() public {
        assertEq(address(royaltyNft.tokenRoyaltySpliter()), address(tokenSpliter), "tokenSpliter address should match the one provided in constructor");
    }
}
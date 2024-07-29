// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../test/MockedERC20.sol";
import "forge-std/Test.sol";
import "../src/TokenSpliter.sol";

contract TokenSpliterTest is Test {
    TokenSpliter public splitter;
    MockedERC20 public token;
    address developer;
    address producer;

    function setUp() public {
        developer = address(0x1);
        producer = address(0x2);
        
        splitter = new TokenSpliter(developer, producer);
        token = new MockedERC20(1000 * 1e18);
    }

    // function testSplitETH() public {
    //     // Setup: Send some ETH to the splitter contract
    //     payable(address(splitter)).transfer(10 ether);

    //     // Pre-condition checks
    //     assertEq(address(splitter).balance, 10 ether);

    //     // Execution: Split the ETH
    //     vm.prank(address(splitter));

    //     // Post-condition checks
    //     assertEq(address(developer).balance, 5 ether + 5 wei);
    //     assertEq(address(producer).balance, 5 ether);
    // }

    function testSplitToken() public {
        assertEq(token.balanceOf(address(this)), 1000 * 1e18);
        token.approve(address(this), 200 * 1e18);

        token.transferFrom(address(this), address(splitter), 100 * 1e18);
        // Pre-condition checks
        assertEq(token.balanceOf(address(splitter)), 100 * 1e18);

        // Execution: Split the tokens
        splitter.splitToken(token);

        // Post-condition checks
        assertEq(token.balanceOf(address(this)), 900 * 1e18);
        assertEq(token.balanceOf(developer), 50 * 1e18);
        assertEq(token.balanceOf(producer), 50 * 1e18);
    }

    // function testFailSplitETHWithEmptyBalance() public {
    //     // This test should fail since there's no ETH to split
    //     // splitter.splitETH();
    // }

    function testFailSplitTokenWithEmptyBalance() public {
        // This test should fail since there are no tokens to split
        splitter.splitToken(token);
    }
}

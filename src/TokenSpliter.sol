// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenSpliter {
    address public developer;
    address public producer;

    constructor(address _developer, address _producer) {
        developer = _developer;
        producer = _producer;
    }

    // Function to split ERC-20 tokens
    function splitToken(IERC20 token) public {
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No tokens to split");

        uint256 half = balance / 2;
        uint256 remainder = balance % 2;

        require(token.transfer(developer, half + remainder), "Failed to send tokens to developer");
        require(token.transfer(producer, half), "Failed to send tokens to producer");
    }
}
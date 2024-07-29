// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IProducer  {
    function checkPartnerShip(address partnerAddress) external view returns(bool);

    function checkERC20(IERC20 erc20Whitelist) external view returns(bool);
}
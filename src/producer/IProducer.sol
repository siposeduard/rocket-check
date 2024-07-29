// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IProduct  {
    function checkPartnerShip(address partnerAddress) external view returns(bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ProviderManager {
    struct Provider {
        uint id;
        string name;
        address providerAddress;
    }

    mapping(uint => Provider) public providers;
    uint public providersCount;

    event ProviderAdded(uint indexed providerId, string name, address providerAddress);

    function addProvider(string memory _name, address _providerAddress) public {
        providersCount++;
        providers[providersCount] = Provider(providersCount, _name, _providerAddress);
        emit ProviderAdded(providersCount, _name, _providerAddress);
    }

    function getProviders() public view returns (Provider[] memory) {
        Provider[] memory _providers = new Provider[](providersCount);
        for (uint i = 1; i <= providersCount; i++) {
            _providers[i - 1] = providers[i];
        }
        return _providers;
    }
}

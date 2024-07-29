# Rocket check

## Introduction

Welcome to our complex supply chain project using NFTs for product authentication on Polygon. This project leverages the power of blockchain technology to ensure the authenticity of original products, such as Jordan shoes, tees, and more. By using NFTs, we can uniquely identify each product and provide a transparent, immutable record of its origin and ownership.

## Features

- **NFT-Based Authentication**: Each product is represented by a unique NFT, ensuring its authenticity.
- **Polygon Blockchain**: Utilizes Polygon for a secure and decentralized system.
- **Smart Contracts**: Implements smart contracts to automate and secure the supply chain processes.
- **Transparency**: Provides an immutable and transparent record of each product's history.
- **Scalability**: Designed to handle complex supply chains with multiple stakeholders.

## Smart contract addresses

Rocket Token: 0x85dF71dB41a4DeA82F18d79B003F13bb3C52bbAC https://amoy.polygonscan.com/address/0x85dF71dB41a4DeA82F18d79B003F13bb3C52bbAC

Marketplace: 0x339B7096C3f49F71c33a6A1885a5474AA90Ee59e https://amoy.polygonscan.com/address/0x339B7096C3f49F71c33a6A1885a5474AA90Ee59e

Producer: 0xeE683206731b8A1F9bd04a19Bd9B1F503b290908 https://amoy.polygonscan.com/address/0xeE683206731b8A1F9bd04a19Bd9B1F503b290908
 
## Getting Started

### Prerequisites

- Node.js (v14 or higher)
- NPM or Yarn
- Truffle or Hardhat (for smart contract deployment)
- Metamask or any Polygon-compatible wallet

### Installation

1. **Clone the Repository**

   ```sh
   git clone https://github.com/siposeduard/rocket-check.git
   cd rocket-check
   ```

2. **Install Dependencies**

   ```sh
   npm install
   ```

   or

   ```sh
   yarn install
   ```

3. **Compile Smart Contracts**

   ```sh
   npx hardhat compile
   ```

   or

   ```sh
   truffle compile
   ```

4. **Deploy Smart Contracts**

   Ensure you have a Polygon wallet (like Metamask) connected to the desired network (e.g., Mumbai Testnet or Polygon Mainnet).

   ```sh
   npx hardhat run scripts/deploy.js --network mumbai
   ```

   or

   ```sh
   truffle migrate --network mumbai
   ```

## Usage

### Minting an NFT

To mint a new NFT representing a product, use the following command:

```sh
npx hardhat run scripts/mint.js --network mumbai --tokenURI "ipfs://<metadata-url>"
```

or

```sh
truffle exec scripts/mint.js --network mumbai --tokenURI "ipfs://<metadata-url>"
```

Replace `<metadata-url>` with the IPFS URL containing the product metadata.

### Verifying Product Authenticity

To verify the authenticity of a product, you can query the smart contract to check the NFT's details.

Example using Web3.js:

```javascript
const Web3 = require('web3');
const web3 = new Web3('https://rpc-mumbai.matic.today');

const contractABI = [/* ABI from the compiled contract */];
const contractAddress = '0xYourContractAddress';

const contract = new web3.eth.Contract(contractABI, contractAddress);

async function getProductDetails(tokenId) {
  const owner = await contract.methods.ownerOf(tokenId).call();
  const tokenURI = await contract.methods.tokenURI(tokenId).call();
  console.log(`Owner: ${owner}`);
  console.log(`Token URI: ${tokenURI}`);
}

getProductDetails(1);
```

## Project Structure

- `contracts/`: Contains the smart contracts written in Solidity.
- `scripts/`: Contains deployment and interaction scripts.
- `test/`: Contains test cases for the smart contracts.
- `migrations/`: Truffle migration scripts.
- `src/`: Frontend code (if applicable).

## Contributing

We welcome contributions from the community. To contribute, please follow these steps:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Make your changes.
4. Commit your changes (`git commit -m 'Add new feature'`).
5. Push to the branch (`git push origin feature-branch`).
6. Create a new Pull Request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgements

We would like to thank the Polygon community for their continuous support and the various open-source projects that made this possible.

---

Feel free to reach out if you have any questions or need further assistance. Happy building!

---

**Maintainers**

- [Your Name](https://github.com/siposeduard)
- [Contributor Name](https://github.com/siposeduard)

---

Thank you for using our complex supply chain solution. Together, we can ensure the authenticity and integrity of products in the marketplace.

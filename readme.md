# Contract Factory

NFT Collection Contract Factory, created with Solidity and Hardhat.

## Compile and Deploy contracts

You can compile contracts using hardhat lib. Just run:

    npx hardhat compile

To deploy your contract into blockchain, just edit the `scripts/deploy.js` file with your contract name and run the command:

    npx hardhat run scripts/deploy.js --network mumbai

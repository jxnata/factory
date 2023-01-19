/** @type import('hardhat/config').HardhatUserConfig */

require("@nomiclabs/hardhat-waffle");
require("hardhat-abi-exporter");

const MUMBAI_PRIVATE_KEY =
  "18acca313aeff892ef2542f2e5410d5f43f1880b592e6ec27957e55fe6761432";

module.exports = {
  solidity: "0.8.17",
  abiExporter: {
    path: "./abi/",
    clear: true,
  },
  networks: {
    mumbai: {
      url: `https://matic-mumbai.chainstacklabs.com`,
      accounts: [`0x${MUMBAI_PRIVATE_KEY}`],
    },
  },
};

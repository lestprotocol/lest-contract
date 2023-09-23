require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");
const { getHardhatConfigNetworks } = require("@zetachain/addresses-tools/dist/networks");

require("dotenv").config();


const PRIVATE_KEYS =
  process.env.PRIVATE_KEY !== undefined ? [`0x${process.env.PRIVATE_KEY}`] : [];

module.exports = {
  solidity: "0.8.10",
  networks: {
    "hela-testnet": {
      url: "https://testnet-rpc.helachain.com",
      accounts: [process.env.PRIVATE_KEY]
    },
    "telos-testnet": {
      url: "https://testnet.telos.net/evm",
      accounts: [process.env.PRIVATE_KEY]
    },
    "omni-testnet": {
      url: "https://testnet.omni.network",
      accounts: [process.env.PRIVATE_KEY]
    },
    ...getHardhatConfigNetworks(PRIVATE_KEYS),
  },
  etherscan: {
    // apiKey: [process.env.API_KEY, process.env.API_KEY2]
    apiKey: {
      "mantle-testnet": process.env.API_KEY, //random value
    },
    customChains: [
      {
        network: "mantle-testnet",
        chainId: 5001,
        urls: {
          apiURL: "https://explorer.testnet.mantle.xyz/api",
          browserURL: "https://explorer.testnet.mantle.xyz"
        },
      },
    ],
  },
};
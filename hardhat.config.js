require("@nomiclabs/hardhat-waffle");
const dotenv = require("dotenv");
dotenv.config({ path: './config.env' })

const { ALCHEMY_API_KEY, WALLET_PRIVATE_KEY } = process.env

module.exports = {
  solidity: "0.8.10",
  networks: {
    goerli: {
      url: `https://eth-goerli.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
      accounts: [WALLET_PRIVATE_KEY],
    },
  },
};

/**
 * @type import('hardhat/config').HardhatUserConfig
 */


 require('dotenv').config();
 require('@nomiclabs/hardhat-waffle');
 require('hardhat-contract-sizer');
//  require('hardhat-gas-reporter')

 const { API_URL, PRIVATE_KEY } = process.env;
 module.exports = {
   solidity: "0.8.4",
   defaultNetwork: "ropsten",
   networks: {
     hardhat: {
       forking: {
         url: `https://eth-ropsten.alchemyapi.io/v2/${API_URL}`
       }
     },
     ropsten: {
       url: `https://eth-ropsten.alchemyapi.io/v2/${API_URL}`,
       accounts: [`0x${PRIVATE_KEY}`],
       gasPrice: 100000000000,
       gas: 100000000
     },
    //  rinkeby: {
    //    url: `https://eth-rinkbey.alchemyapi.io/v2/${API_URL}`,
    //    accounts: [`0x${PRIVATE_KEY}`]
    //  }
   },
   settings: {
    optimizer: {
      enabled: true,
      runs: 200
    },
    outputSelection: {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "devdoc",
          "userdoc",
          "metadata",
          "abi"
        ]
      }
    },
    contractSizer: {
      alphaSort: true,
      disambiguatePaths: false,
      runOnCompile: true,
      strict: true,
      only: ['DemoOptimzed'],
    }
  },
  mocha: {
    timeout: 400000
  }
  //  gasReporter: {
  //   currency: 'CHF',
  //   gasPrice: 168
  //  }
 };


/**
 * @type import('hardhat/config').HardhatUserConfig
 */

 require('dotenv').config();
 require('@nomiclabs/hardhat-waffle');
//  require('hardhat-gas-reporter')

 const { API_URL, PRIVATE_KEY } = process.env;
 module.exports = {
   solidity: "0.8.4",
   defaultNetwork: "hardhat",
   networks: {
     hardhat: {},
     ropsten: {
       url: API_URL,
       accounts: [`0x${PRIVATE_KEY}`]
     }
   }
  //  gasReporter: {
  //   currency: 'CHF',
  //   gasPrice: 168
  //  }
 };


const { utils } = require("ethers");
const { ethers } = require("hardhat");


async function main() {
  let Contract, contract;
  const URI = "https://cuteeFruitee.api/";


  // Deployment of contract
  Contract = await ethers.getContractFactory("CuteeFruitee");
  contract = await Contract.deploy(URI);

  console.log("Contract deployed with address: ", contract.address);

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
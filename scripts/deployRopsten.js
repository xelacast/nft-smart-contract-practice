const { utils } = require("ethers");
const { ethers } = require("hardhat");


async function main() {
  let Contract, contract, owner, addr1, addr2, addr3, addr4, addr5, addr6;
  const URI = "https://cuteeFruitee.api/tokens/"
  const hiddenURI = URI + "hidden.json";
  // these are removed for erc1155 token standard for duplication of data
  // const name = "DemoNFT";
  // const symbol = "DNFT";

  // Deployment of contract
  const [deployer] = await ethers.getSigners();
  const gwei = (await deployer.getBalance()).toString()
  console.log("Account Balance: ", utils.parseEther(gwei));
  Contract = await ethers.getContractFactory("DemoOptimized");
  contract = await Contract.deploy(URI, hiddenURI);
  // await contract.deployed();

  console.log("Contract deployed with id: ", contract.address);

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
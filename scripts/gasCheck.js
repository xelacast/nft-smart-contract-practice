const { utils } = require("ethers");
const { ethers } = require("hardhat");


async function main() {
  let Contract, contract, owner, addr1, addr2, addr3, addr4, addr5, addr6;
  const URI = "https://cuteeFruitee.api/tokens/"
  // these are removed for erc1155 token standard for duplication of data
  // const name = "DemoNFT";
  // const symbol = "DNFT";

  // Deployment of contract
  Contract = await ethers.getContractFactory("DemoOptimized");
  contract = await Contract.deploy(URI, "hidden.json");
  [owner, addr1, addr2, addr3, addr4, addr5, addr6] = await ethers.getSigners();

  console.log("Contract deployed with id: ", contract.address);

  const options = {
    value: ethers.utils.parseEther("0.1"),
    // gasPrice: gasPrice,
    // gasLimit: ethers.utils.hexlify(10000), // 100gwei
    // nonce: connection.getTransactionCount(addr1.address, 'latest'),
    // data: "1"
  }

  await contract.connect(owner).setPresaleStartTime(0,1);

  // how you send arguments and ether into a connected contract
  await contract.connect(addr1).mintBundle(1, options);
  // await contract.connect(addr1).mintBundle(1, options);
  // try {
  //   await contract.connect(addr1).mintBundle(1, options);

  // } catch(error) {
  //   console.log("Cant mint more than 2")
  // }
  // await addr1.sendTransaction(tx);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
const { ethers } = require("hardhat");
const { utils } = require('ethers')

async function main() {

  const URI = "www.cuteeFruitee.co/";
  // Do i need a prview uri if I am going to update the ipfs folder with previews?
  const PREVIEW_URI = "www.cuteeFruitee.co/preview";

  const Contract = await ethers.getContractFactory("DemoOptimized");
  const contract = await Contract.deploy(URI, PREVIEW_URI);

  const [owner, addr1, addr2] = await ethers.getSigners()

  await contract.connect(owner).setSaleTime(0,1,2);


  const tx = {
    value: utils.parseEther("0.1"),
  }
  await contract.connect(addr1).mintBundle(tx);

}

main()
.then(() => process.exit(0))
.catch((error) => {
  console.log(error);
  process.exit(1);
})
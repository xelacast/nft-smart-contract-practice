const { ethers } = require("hardhat");
const { utils } = require('ethers')

async function main() {

  const URI = "www.cuteeFruitee.co/";
  // Do i need a prview uri if I am going to update the ipfs folder with previews?
  const PREVIEW_URI = "www.cuteeFruitee.co/preview";

  const Contract = await ethers.getContractFactory("DemoOptimized");
  const contract = await Contract.deploy(URI, PREVIEW_URI);

  const [owner, addr1, addr2, addr3, addr4, a5, a6, a7, a8, a9] = await ethers.getSigners()

  await contract.connect(owner).setVifMember([addr1.address, addr2.address, owner.address, addr3.address, addr4.address]);
  //  a5.address, a6.address, a7.address, a8.address, a9.address]);

  await contract.connect(owner).setSaleTime(0,1,2);

  // connect to deployed contract with ethers.
  // const myContract = await hre.ethers.getContractAt("<contract name>" "<contract address>");

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
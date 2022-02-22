const { utils } = require("ethers");
const { ethers } = require("hardhat");


async function main() {
  let Contract, contract, owner, addr1, addr2, addr3;
  let fruitTokenUpperParam = 4001;
  let fruitTokenLowerParam = 0;
  let fourInOneUpperParam = 101001;
  let fourInOneLowerParam = 100000;
  const URI = "https://cuteeFruitee.api/tokens/";
  const URIHidden = "https://cuteeFruitee.api/preview/hidden.json";
  // these are removed for erc1155 token standard for duplication of data
  // const name = "DemoNFT";
  // const symbol = "DNFT";

  // Deployment of contract
  Contract = await ethers.getContractFactory("DemoOptimized");
  contract = await Contract.deploy(URI, URIHidden);
  [owner, addr1, addr2, addr3] = await ethers.getSigners();

  console.log("Contract deployed with id: ", contract.address);
  // await contract.connect(owner).setSeasonLowerParams(4000, 101000);

  await contract.connect(owner).giveawayMintBatch([addr1.address, addr2.address])
  // await contract.connect(owner).giveawayMintBatch([addr1.address, addr2.address])
  await contract.connect(owner).setPresaleStartTime(0,1);
  await contract.connect(owner).mintBundle({value: utils.parseEther("0.1")});

  console.log(await contract.balanceOf(owner.address, 0));
  await contract.connect(addr1).safeTransferFrom(addr1.address, owner.address, 0, 3, []);
  console.log("6",await contract.balanceOf(owner.address, 0));
  console.log("0",await contract.balanceOf(addr1.address, 0));

  console.log("1",await contract.balanceOf(addr1.address, 1));
  console.log("0",await contract.balanceOf(owner.address, 1));
  await contract.connect(addr1).safeTransferFrom(addr1.address, owner.address, 1, 1, []);
  console.log("0",await contract.balanceOf(addr1.address, 1));
  console.log("1",await contract.balanceOf(owner.address, 1));

  // !WORKS!
  // test if a address does not have a mapping
  console.log("1",await contract.balanceOf(addr1.address, 4));
  console.log("0",await contract.balanceOf(addr3.address, 4));
  await contract.connect(addr1).safeTransferFrom(addr1.address, addr3.address, 4, 1, []);
  console.log("0",await contract.balanceOf(addr1.address, 4));
  console.log("1",await contract.balanceOf(addr3.address, 4));

  // console.log(await contract.balanceOf(owner.address, 9));
  // console.log(await contract.balanceOf(owner.address, 10));
  // console.log(await contract.balanceOf(owner.address, 11));
  // console.log(await contract.balanceOf(owner.address, 12));
  // console.log(await contract.balanceOf(owner.address, 100003));

  // console.log(await contract.uri(12));
  // console.log(await contract.connect(owner).getBalances(1));

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
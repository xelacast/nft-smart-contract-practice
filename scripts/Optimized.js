const { utils } = require("ethers");
const { ethers } = require("hardhat");


async function main() {
  let Contract, contract, owner, addr1, addr2;
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
  [owner, addr1, addr2] = await ethers.getSigners();

  console.log("Contract deployed with id: ", contract.address);
  await contract.connect(owner).setSeasonLowerParams(4000, 101000);

  await contract.connect(owner).giveawayMintBatch([addr1.address, addr1.address])
  await contract.connect(owner).setPresaleStartTime(0,1);
  await contract.connect(owner).mintBundle({value: utils.parseEther("0.1")});

  // console.log(await contract.uri(12));
  console.log(await contract.connect(owner).getBalances(1));

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
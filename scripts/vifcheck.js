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

  // await contract.connect(owner).setPresaleStartTime(0,1);
  // await contract.connect(owner).setVIFMember([addr1.address]);
  // await contract.connect(owner).setVIFMember([addr2.address, addr3.address]);
  await contract.connect(owner).setVIFMember([addr4.address, addr5.address, addr6.address, addr1.address]);

  await contract.connect(addr1).mintBundle({value: utils.parseEther("0.1")});

  await contract.connect(owner).resetVIF();
  // await contract.connect(owner).setPricePerBundle(utils.parseEther("0.2"))
  console.log(await contract.getPricePerBundle());

  // await contract.connect(owner).giveawayBundle([addr1.address])
  // await contract.connect(owner).giveawayBundle([addr1.address, addr2.address])
  // await contract.connect(owner).giveawayBundle([addr1.address, addr2.address, addr3.address])

  // await contract.connect(owner).increaseReceiptSupply(4000);
  // await contract.connect(owner).setSeasonLowerParams(4000, 101000);

  // await contract.connect(addr1).cuteeExchange(0, 100001, 1);
  // console.log("2", await contract.balanceOf(addr1.address, 0));

  // await contract.connect(owner).setBundleSupply(1000)

  // console.log(addr1.address, await contract.getVIFMember(addr1.address));

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
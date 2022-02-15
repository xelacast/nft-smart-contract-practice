const { ethers } = require("hardhat");


async function main() {
  let Contract, contract, owner, addr1, addr2;
  const URI = "https://cuteeFruitee.api/tokens/{id}.json"
  // these are removed for erc1155 token standard for duplication of data
  // const name = "DemoNFT";
  // const symbol = "DNFT";

  // Deployment of contract
  Contract = await ethers.getContractFactory("DemoDapp");
  contract = await Contract.deploy(URI);
  [owner, addr1, addr2] = await ethers.getSigners();

  console.log("Contract deployed with id: ", contract.address);

  // basic test of getting the uri
  console.log("URI is: ", await contract.uri(0));

  await contract.connect(addr1).mintBundle({value: ethers.utils.parseEther("0.08")})
  console.log(await addr1.getBalance())

  console.log("Balance of token id 0: ", await contract.balanceOf(addr1.address, 0))
  console.log("Balance of token id 1: ", await contract.balanceOf(addr1.address, 1))
  console.log("Balance of token id 2: ", await contract.balanceOf(addr1.address, 2))
  console.log("Balance of token id 3: ", await contract.balanceOf(addr1.address, 3))
  console.log("Balance of token id 4: ", await contract.balanceOf(addr1.address, 4))
  console.log("Balance of token id 5: ", await contract.balanceOf(addr1.address, 5))
  console.log("Balance of token id 100001: ", await contract.balanceOf(addr1.address, 100001))

  console.log("Balance of contract: ", ethers.utils.formatEther(await contract.getBalanceOfContract()));
  console.log(await contract.connect(addr1).getBundleBalance());
  console.log(await contract.getBatchSupply());
  console.log(await contract.getReceiptSupply());

  console.log()

  await contract.connect(owner).giveawayMintBatch(addr2.address);
  console.log(await addr2.getBalance());
  await contract.connect(addr2).mintBundle({value: ethers.utils.parseEther("0.08")});
  // try {
  //   await contract.connect(addr1).giveawayMintBatch(addr1.address);
  // } catch(error) {
  //   console.log("Cant access giveaways if you are not the owner.")
  // }

  console.log("Balance of token id 0: ", await contract.balanceOf(addr1.address, 0))
  console.log("Balance of token id 5: ", await contract.balanceOf(addr2.address, 5))
  console.log("Balance of token id 6: ", await contract.balanceOf(addr2.address, 6))
  console.log("Balance of token id 7: ", await contract.balanceOf(addr2.address, 7))
  console.log("Balance of token id 8: ", await contract.balanceOf(addr2.address, 8))
  console.log("Balance of token id 9: ", await contract.balanceOf(addr2.address, 9))
  console.log("Balance of token id 100002: ", await contract.balanceOf(addr2.address, 100002))
  console.log("Balance of contract: ", ethers.utils.formatEther(await contract.getBalanceOfContract()));
  console.log(await contract.connect(addr2).getBundleBalance());
  console.log(await contract.getBatchSupply());
  console.log(await contract.getReceiptSupply());



}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
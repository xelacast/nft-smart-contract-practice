const { ethers } = require("hardhat");

async function main() {
  const Contract = await ethers.getContractFactory("DemoDapp");
  const contract = await Contract.deploy("Hello");

  console.log("Contract deployed at: ", contract.address);

  const [owner, addr1, addr2] = await ethers.getSigners();

  await contract.connect(owner).setVIF([addr1.address]);
  // console.log(await contract.getTime());

  // try {
  //   await contract.connect(addr1).mintBundle({value: ethers.utils.parseEther("0.1")});
  // } catch (err) {
  //   console.error(err)
  // }
//* activatin sale
  // await contract.connect(owner).activateSale();
  await contract.connect(owner).activatePreSale();

  try {
    tx = {
      value: ethers.utils.parseEther("0.1"),
      // data: 2
    }
    await contract.connect(addr1).mintBundle(tx);
  } catch (err) {
    console.error(err)
  }
  try {
    tx = {
      value: ethers.utils.parseEther("0.1"),
      // data: 2
    }
    await contract.connect(addr2).mintBundle(tx);
  } catch (err) {
    console.log("Account was not whitelsisted")
  }
  // await contract.connect(owner).activatePreSale();
  console.log(ethers.utils.formatEther(await contract.connect(owner).getBalance()));

  console.log(await contract.balanceOfBatch([addr1.address, addr1.address,addr1.address, addr1.address,addr1.address, addr1.address],[1,2,3,4,100001,0]))
  console.log(await contract.balanceOf(addr1.address, 1))

}

main()
.then(() => process.exit(0))
.catch((error) => {
  console.error(error);
  process.exit(1);
})
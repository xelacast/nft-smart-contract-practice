const { expect } = require("chai");
const { ethers } = require("hardhat");


//TODO create an api that posts account to db. Activated on mint.
describe("Mint Pass Test", () => {
  let Contract, contract, owner, addr1, addr2;
  let uri = "www.CuteeFruitee.co"

  beforeEach(async () => {
    Contract = await ethers.getContractFactory("CuteeFruitee");
    contract = await Contract.deploy(uri);
    [owner, addr1, addr2] = await ethers.getSigners();
  })

  it("Gives free mint pass to 2 users. Users use mint pass.", async () => {
    await contract.connect(owner).mintPassGiveaway([addr1.address, addr2.address]);

    expect(await contract.getMintPassCount(addr1.address)).to.equal(1);
    expect(await contract.getMintPassCount(addr2.address)).to.equal(1);

    await contract.connect(addr1).useMintPass();
    await contract.connect(addr2).useMintPass();
    await expect(contract.connect(addr1).useMintPass()).to.be.revertedWith("You do not have a free mint.");
    expect(await contract.balanceOf(addr1.address, 0)).to.equal(3);



  })
})
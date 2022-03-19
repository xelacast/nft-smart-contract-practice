const { expect } = require("chai");
const { ethers } = require("hardhat");
const fillerProof = require('../json/fillerProof.json');


//TODO create an api that posts account to db. Activated on mint.
describe("Contract Balance Test", () => {
  let Contract, contract, owner, addr1, addr2, addr3;
  let uri = "www.CuteeFruitee.co"
  let proof = fillerProof.proof;
  let maxAmount = fillerProof.maxAmount;
  let tx = {
    value: ethers.utils.parseEther("0.1")
  }

  beforeEach(async () => {
    Contract = await ethers.getContractFactory("CuteeFruitee");
    contract = await Contract.deploy(uri);
    [owner, addr1, addr2, addr3] = await ethers.getSigners();
  })

  it("3 Users mint 3 bundles. Checks contract balance nad withdrawals it. Then Checks balance of withdrawer.", async () => {
    await contract.connect(owner).setPublicSale();
    await contract.connect(addr1).mintBundle(proof, maxAmount, tx);
    await contract.connect(addr2).mintBundle(proof, maxAmount, tx);
    await contract.connect(addr3).mintBundle(proof, maxAmount, tx);

    await contract.connect(owner).withdrawBalance();

    expect(Number(ethers.utils.formatEther(await owner.getBalance()))).to.be.greaterThan(10000);


  })
})
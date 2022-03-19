const { expect } = require("chai");
const { ethers } = require("hardhat");
const fillerProof = require('../json/fillerProof.json');


//TODO create an api that posts account to db. Activated on mint.
describe("Mint Token Test", () => {
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

  it("Gets correct balance of tokens with corresponding address. 3 Accounts", async () => {
    await contract.connect(owner).setPublicSale();
    await contract.connect(addr1).mintBundle(proof, maxAmount, tx);
    await contract.connect(addr2).mintBundle(proof, maxAmount, tx);
    await contract.connect(addr3).mintBundle(proof, maxAmount, tx);

    // fruit tokens
    expect(await contract.balanceOf(addr1.address, 3)).to.equal(1);
    expect(await contract.balanceOf(addr2.address, 7)).to.equal(1);
    expect(await contract.balanceOf(addr3.address, 10)).to.equal(1);
    // 4in1 tokens
    expect(await contract.balanceOf(addr1.address, 100001)).to.equal(1);
    expect(await contract.balanceOf(addr2.address, 100002)).to.equal(1);
    expect(await contract.balanceOf(addr3.address, 100003)).to.equal(1);
    // receipt tokens
    expect(await contract.balanceOf(addr1.address, 0)).to.equal(3);
    expect(await contract.balanceOf(addr2.address, 0)).to.equal(3);
    expect(await contract.balanceOf(addr3.address, 0)).to.equal(3);

  })
})
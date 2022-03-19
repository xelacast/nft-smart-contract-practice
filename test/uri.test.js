const { expect } = require("chai");
const { ethers } = require("hardhat");


//TODO create an api that posts account to db. Activated on mint.
describe("Uri Test", () => {
  let Contract, contract, owner, addr1, addr2;
  let uri = "www.CuteeFruitee.co"

  beforeEach(async () => {
    Contract = await ethers.getContractFactory("CuteeFruitee");
    contract = await Contract.deploy(uri);
    [owner, addr1, addr2] = await ethers.getSigners();
  })

  it("Checks contract uri params 0, 1, 100001", async () => {
    expect(await contract.uri(1)).to.equal(uri + "/fruits/1.json");
    expect(await contract.uri(0)).to.equal(uri + "/receipts/0.json");
    expect(await contract.uri(100001)).to.equal(uri + "/4in1s/100001.json");

  })
})
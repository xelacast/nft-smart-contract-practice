const { expect } = require("chai");
const { ethers } = require("hardhat");
const fillerProof = require("../json/fillerProof");


//TODO create an api that posts account to db. Activated on mint.
describe("Tests Seasons Drops", () => {
  let Contract, contract, owner, addr1, addr2;
  let proof = fillerProof.proof;
  let maxAmount = fillerProof.maxAmount;

  beforeEach(async () => {
    Contract = await ethers.getContractFactory("CuteeFruitee");
    contract = await Contract.deploy();
    [owner, addr1, addr2] = await ethers.getSigners();
  })

})
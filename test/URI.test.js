const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");
const { setTimeout } = require("timers/promises");

describe("URI Check", function() {
  let owner, addr1, addr2, addr3, Contract, contract;
  let fruitTokenUpperParam, fruitTokenLowerParam,
  fourInOneUpperParam, fourInOneLowerParam;
  const URI = "https://cuteeFruitee.api/tokens/";
  const URIHidden = "https://cuteeFruitee.api/preview/hidden.json";

  beforeEach(async () => {
    Contract = await ethers.getContractFactory("DemoOptimized");
    contract = await Contract.deploy(URI, URIHidden);
    [owner, addr1, addr2, addr3] = await ethers.getSigners();
  })

  it("Checks uri for upper and lower bounds. Bounds are set anything between them must show hiddenURI, except token 0.", async () => {
    expect(await contract.uri(0)).to.equal("https://cuteeFruitee.api/tokens/0.json");
    expect(await contract.uri(1)).to.equal("https://cuteeFruitee.api/preview/hidden.json");
    expect(await contract.uri(4000)).to.equal("https://cuteeFruitee.api/preview/hidden.json");
    expect(await contract.uri(100001)).to.equal("https://cuteeFruitee.api/preview/hidden.json");
    expect(await contract.uri(101000)).to.equal("https://cuteeFruitee.api/preview/hidden.json");
    expect(await contract.uri(4001)).to.equal("https://cuteeFruitee.api/preview/hidden.json");
    expect(await contract.uri(101001)).to.equal("https://cuteeFruitee.api/preview/hidden.json");
  })

  it("Changes the lowerBound for fruit and fourInOneTokenId to receive new token metadata inpersanating the start of season one", async () => {
    await contract.connect(owner).setSeasonLowerParams(4000, 101000);
    expect(await contract.uri(0)).to.equal("https://cuteeFruitee.api/tokens/0.json");
    expect(await contract.uri(1)).to.equal("https://cuteeFruitee.api/tokens/1.json");
    expect(await contract.uri(4000)).to.equal("https://cuteeFruitee.api/tokens/4000.json");
    expect(await contract.uri(4001)).to.equal("https://cuteeFruitee.api/preview/hidden.json");
    expect(await contract.uri(100001)).to.equal("https://cuteeFruitee.api/tokens/100001.json");
    expect(await contract.uri(101000)).to.equal("https://cuteeFruitee.api/tokens/101000.json");
    expect(await contract.uri(101001)).to.equal("https://cuteeFruitee.api/preview/hidden.json");
  })


})
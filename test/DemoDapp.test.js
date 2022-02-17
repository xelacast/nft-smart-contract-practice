const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");

describe("DemoDapp", function() {
  let owner, addr1, addr2, addr3, Contract, contract;

  beforeEach(async () => {
    Contract = await ethers.getContractFactory("DemoDapp");
    contract = await Contract.deploy("HEllo");
    [owner, addr1, addr2, addr3] = await ethers.getSigners();
  })

  it("Adds an address to the whitelist (onlyOwner)", async () => {
    await contract.connect(owner).setVIF([addr1.address]);
    expect(await contract.connect(owner).getVIF(addr1.address)).to.equal(1);
    expect(await contract.connect(owner).getVIF(addr2.address)).to.equal(0);
    // expect(await contract.connect(addr1).setVeryImportantFruit([addr1.address])).to.be.reverted;
  })

  it("Gives an address a giveaway mint and checks balance", async () => {
    await contract.connect(owner).giveawayMintBatch([addr1.address, addr2.address]);

    expect(await contract.balanceOf(addr1.address, 1)).to.equal(1)
    expect(await contract.balanceOf(addr1.address, 2)).to.equal(1)
    expect(await contract.balanceOf(addr1.address, 3)).to.equal(1)
    expect(await contract.balanceOf(addr1.address, 4)).to.equal(1)
    expect(await contract.balanceOf(addr1.address, 100001)).to.equal(1)
    expect(await contract.balanceOf(addr1.address, 0)).to.equal(3)

    expect(await contract.balanceOf(addr2.address, 5)).to.equal(1)
    expect(await contract.balanceOf(addr2.address, 6)).to.equal(1)
    expect(await contract.balanceOf(addr2.address, 7)).to.equal(1)
    expect(await contract.balanceOf(addr2.address, 8)).to.equal(1)
    expect(await contract.balanceOf(addr2.address, 100002)).to.equal(1)
    expect(await contract.balanceOf(addr2.address, 0)).to.equal(3)

    expect(await contract.balanceOf(addr3.address, 9)).to.equal(0)
    expect(await contract.balanceOf(addr3.address, 10)).to.equal(0)
    expect(await contract.balanceOf(addr3.address, 11)).to.equal(0)
    expect(await contract.balanceOf(addr3.address, 12)).to.equal(0)
    expect(await contract.balanceOf(addr3.address, 100003)).to.equal(0)
    expect(await contract.balanceOf(addr3.address, 0)).to.equal(0)
  })

  it("Sets Sale as active and allows a user to mint 1 bundle and checks balance of contract", async () => {

    // expect(await contract.connect(addr1).mintBundle({value: ethers.utils.parseEther("0.1")})).to.be.revertedWith('presale is active and you are not a VIF or public sale is not active');

    await contract.connect(owner).activateSale();
    //! reverts but does not work with hardhat local enviroment
    // expect(await contract.connect(addr1).activateSale()).to.be.reverted;
    await contract.connect(addr1).mintBundle({value: ethers.utils.parseEther("0.1")});
    expect(await contract.balanceOf(addr1.address, 1)).to.equal(1);
    expect(await contract.balanceOf(addr1.address, 2)).to.equal(1);
    expect(await contract.balanceOf(addr1.address, 3)).to.equal(1);
    expect(await contract.balanceOf(addr1.address, 4)).to.equal(1);
    expect(await contract.balanceOf(addr1.address, 100001)).to.equal(1);
    expect(await contract.balanceOf(addr1.address, 0)).to.equal(3);

    expect(await contract.connect(owner).getBalance()).to.equal("100000000000000000")

  })

  it("Activates presale, Sets a whitelist member checks the purchase ability, and checks the purchase ability of a non whitelist member, deactivates presale and checks again", async () => {
    // try buying mint //* Works not in hardhat env
    // expect(await contract.connect(addr1).mintBundle({value: ethers.utils.parseEther("0.1")})).to.be.revertedWith("Public sale is not active");
    // activate presale
    await contract.connect(owner).activatePreSale();
    // set a member to whitelist
    await contract.connect(owner).setVIF([addr1.address]);
    // buy with whitelist member
    await contract.connect(addr1).mintBundle({value: ethers.utils.parseEther("0.1")})
    // buy with non-whitelist member //* passing but not in hardhat env
    // expect(await contract.connect(addr2).mintBundle({value: ethers.utils.parseEther("0.1")})).to.be.revertedWith("Presale is acttive but you're not a VIF");
    // deactivate presale
    await contract.connect(owner).activatePreSale();
    // buy with whitelist member //* passing but not in hardhat env
    // expect(await contract.connect(addr1).mintBundle({value: ethers.utils.parseEther("0.1")})).to.be.revertedWIth("Public sale is not active");
    // buy with non-whitelist member //* passing but not in hardhat env
    // expect(await contract.connect(addr2).mintBundle({value: ethers.utils.parseEther("0.1")})).to.be.revertedWIth("Public sale is not active");
    expect(await contract.balanceOf(addr1.address, 0)).to.equal(3);

  })

  it("Sets a whitelist member, checks it, resets whitelist mapping, sets again, checks and deletes.", async () => {
    expect(await contract.connect(owner).getVIFLeft()).to.equal(500)
    await contract.connect(owner).setVIF([addr1.address, addr2.address]);
    expect(await contract.getVIF(addr1.address)).to.equal(1);
    expect(await contract.getVIF(addr2.address)).to.equal(1);
    expect(await contract.getVIF(addr3.address)).to.equal(0);
    expect(await contract.connect(owner).getVIFLeft()).to.equal(498)

    await contract.connect(owner).resetVIF(499);
    expect(await contract.getVIF(addr1.address)).to.equal(0);
    expect(await contract.getVIF(addr2.address)).to.equal(0);
    expect(await contract.getVIF(addr3.address)).to.equal(0);

    // * Second Setting
    expect(await contract.connect(owner).getVIFLeft()).to.equal(499)
    await contract.connect(owner).setVIF([addr1.address, addr3.address]);
    expect(await contract.connect(owner).getVIFLeft()).to.equal(497)
    expect(await contract.getVIF(addr1.address)).to.equal(1);
    expect(await contract.getVIF(addr2.address)).to.equal(0);
    expect(await contract.getVIF(addr3.address)).to.equal(1);

    await contract.connect(owner).resetVIF(23);
    expect(await contract.connect(owner).getVIFLeft()).to.equal(23)
    expect(await contract.getVIF(addr1.address)).to.equal(0);
    expect(await contract.getVIF(addr2.address)).to.equal(0);
    expect(await contract.getVIF(addr3.address)).to.equal(0);
  })
})
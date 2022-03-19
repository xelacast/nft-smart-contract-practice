const { expect } = require("chai");
const { ethers } = require("hardhat");
const { MerkleTree } = require("merkletreejs");
const { keccak256 } = require('ethers/lib/utils')

describe("White List Check with Merkle Tree", function() {
  const URI = "https://cuteeFruitee.api/tokens/";
  let owner, addr1, addr2, addr3, addr4, addr5, addr6, addr7;
  let Contract, contract, vifMaxAmount, presaleMaxAmount, proofs, fillerProof;
  let tx;

  beforeEach(async () => {
    [owner, addr1, addr2, addr3, addr4, addr5, addr6, addr7] = await ethers.getSigners();
    Contract = await ethers.getContractFactory("CuteeFruitee");
    contract = await Contract.deploy(URI);

    const encoder = ethers.utils.defaultAbiCoder;

    vifMaxAmount = "30";
    presaleMaxAmount = "20";

    //* Create Merkle Tree of VIF and Fruity Members
    // encode leafs unambigious to match solidity
    const vifLeafs = [owner.address, addr1.address, addr2.address].map(account => encoder.encode(["address", "string"], [account, vifMaxAmount]));
    const fruityLeafs = [addr3.address, addr4.address, addr5.address].map(account => encoder.encode(["address", "string"], [account, presaleMaxAmount]));

    const leafs = vifLeafs.concat(fruityLeafs);
    const tree = new MerkleTree(leafs, keccak256, {hashLeaves: true, sortPairs: true});
    const root = tree.getHexRoot();
    const hashedLeafs = leafs.map(leaf => keccak256(leaf))
    proofs = hashedLeafs.map(leaf => tree.getHexProof(leaf));
    fillerProof = tree.getHexProof('a');

    await contract.connect(owner).setMerkleRoot(root);

    tx = {
      value: ethers.utils.parseEther("0.1")
    }

  })

  it("Allows a VIF Member mint 3 times. Once per sale.", async () => {
    // const [owner, addr1] = await ethers.getSigners();
    await contract.connect(owner).setVifSale();
    await contract.connect(addr1).mintBundle(proofs[1], vifMaxAmount, tx);
    expect(await contract.balanceOf(addr1.address, 0)).to.equal(3);
    await expect(contract.connect(addr1).mintBundle(proofs[1], vifMaxAmount, tx)).to.be.revertedWith("You have bought the max amount of fruit baskets for the VIF sale. Wait until Fruity sale to purchase more.");

    // deactivate VIF sale and Activate Presale
    await contract.connect(owner).setVifSale();
    await contract.connect(owner).setFruitySale();

    // Mint another bundle
    await contract.connect(addr1).mintBundle(proofs[1], vifMaxAmount, tx);
    expect(await contract.balanceOf(addr1.address, 0)).to.equal(6);
    await expect(contract.connect(addr1).mintBundle(proofs[1], vifMaxAmount, tx)).to.be.revertedWith("You have bought the max amount of fruit baskets as a VIF member. Wait until public sale to purchase more.");

    await contract.connect(owner).setFruitySale();
    await contract.connect(owner).setPublicSale();

    await contract.connect(addr1).mintBundle(proofs[1], vifMaxAmount, tx);
    expect(await contract.balanceOf(addr1.address, 0)).to.equal(9);
    await expect(contract.connect(addr1).mintBundle(proofs[1], vifMaxAmount, tx)).to.be.revertedWith("You have bought the max amount of fruit baskets as a VIF member.");

  })

  it("Allows a Presale Member to mint 2 bundles. Once per Presale and Public sale", async () => {
    await contract.connect(owner).setVifSale();
    await expect(contract.connect(addr5).mintBundle(proofs[5], presaleMaxAmount, tx)).to.be.revertedWith("You are not a VIF member.");

    // deactivate VIF sale and Activate Presale
    await contract.connect(owner).setVifSale();
    // vifSaleIsActive = false;
    await contract.connect(owner).setFruitySale();
    //fruitiesSaleIsActive = true;

    await contract.connect(addr5).mintBundle(proofs[5], presaleMaxAmount, tx);
    expect(await contract.balanceOf(addr5.address, 0)).to.equal(3);

    await expect(contract.connect(addr5).mintBundle(proofs[5], presaleMaxAmount, tx)).to.be.revertedWith("You have bought the max amount of fruit baskets as a Fruity Member. Wait until public sale.");

    await contract.connect(owner).setFruitySale();
    await contract.connect(owner).setPublicSale();
    // fruitiesSaleIsActive = false
    // publicSaleIsActive = true

    await contract.connect(addr5).mintBundle(proofs[5], presaleMaxAmount, tx);
    expect(await contract.balanceOf(addr5.address, 0)).to.equal(6);

    await expect(contract.connect(addr5).mintBundle(proofs[5], presaleMaxAmount, tx)).to.be.revertedWith("You have bought the max amount of fruit baskets as a Fruity Member.");
  });

  it("Allows non-member to mint if and only if public sale is active", async () => {
    await expect(contract.connect(addr6).mintBundle(fillerProof, 1, tx)).to.be.revertedWith("Sales have not started yet.");

    await contract.connect(owner).setVifSale();

    await expect(contract.connect(addr6).mintBundle(fillerProof, 1, tx)).to.be.revertedWith("You are not a VIF member.");

    await contract.connect(owner).setVifSale();
    await contract.connect(owner).setFruitySale();

    await expect(contract.connect(addr6).mintBundle(fillerProof, 1, tx)).to.be.revertedWith("You are not a Presale or VIF member. Wait until public sale.");

    await contract.connect(owner).setFruitySale();
    await contract.connect(owner).setPublicSale();

    await contract.connect(addr6).mintBundle(fillerProof, 1, tx);

    expect(await contract.balanceOf(addr6.address, 0)).to.equal(3);

    await expect(contract.connect(addr6).mintBundle(fillerProof, 1, tx)).to.be.revertedWith("Only allowed one purchase of a fruitbasket during public sale.");
  });

})
const { ethers } = require("hardhat");
const { utils } = require('ethers');
const { MerkleTree } = require('merkletreejs');
const { keccak256 } = require('ethers/lib/utils');
const accounts = require('../json/accounts.json');

async function main() {

  const URI = "www.cuteeFruitee.co/";
  // Do i need a prview uri if I am going to update the ipfs folder with previews?
  const [owner, addr1, addr2, addr3, addr4, a5, a6, a7, a8, a9] = await ethers.getSigners();

  const Contract = await ethers.getContractFactory("CuteeFruitee");
  const contract = await Contract.deploy(URI);

  const encoder = ethers.utils.defaultAbiCoder;

  const vifMaxAmount = "30";
  const presaleMaxAmount = "20";

  // The accounts will have different max values
  // uint256 does not encode correctly
  const vifAccountLeafs = accounts.vif.map(account => encoder.encode(["address", "string"],[account, vifMaxAmount]));
  const presaleAccountLeafs = accounts.presale.map(account => encoder.encode(["address", "string"],[account, presaleMaxAmount]));

  const leafs = vifAccountLeafs.concat(presaleAccountLeafs);

  const tree = new MerkleTree(
    leafs,
    keccak256,
    {hashLeaves: true, sortPairs: true}
    );

  const root = tree.getHexRoot();

  const ownerLeaf = keccak256(leafs[0]);
  const addr1Leaf = keccak256(leafs[1]);
  const addr2Leaf = keccak256(leafs[2]);
  const addr3Leaf = keccak256(leafs[3]);
  const addr4Leaf = keccak256(leafs[4]);
  const addr5Leaf = keccak256(leafs[5]);


  const ownerProof = tree.getHexProof(ownerLeaf);
  const addr1Proof = tree.getHexProof(addr1Leaf);
  const addr2Proof = tree.getHexProof(addr2Leaf);
  const addr3Proof = tree.getHexProof(addr3Leaf);
  const addr4Proof = tree.getHexProof(addr4Leaf);
  const addr5Proof = tree.getHexProof(addr5Leaf);
  const badAddr6Proof = tree.getHexProof(addr5Leaf);

  // console.log(tree.verify(proof, leaf, root));

  await contract.connect(owner).setMerkleRoot(root);
  // console.log(await contract.connect(owner)._verifyMerkle(ownerProof, 30));
  // console.log(await contract.connect(addr1)._verifyMerkle(addr1Proof, 30));
  // console.log(await contract.connect(addr2)._verifyMerkle(addr2Proof, 30));
  // console.log(await contract.connect(addr3)._verifyMerkle(addr3Proof, 20));
  // console.log(await contract.connect(addr4)._verifyMerkle(addr4Proof, 20));
  // console.log(await contract.connect(a5)._verifyMerkle(addr5Proof, 20));
  // console.log(await contract.connect(a6)._verifyMerkle(addr5Proof, 20));


  // await contract.connect(owner).setSaleTime(0,1,2);

  // const tx = {
  //   value: utils.parseEther("0.1"),
  // }
  // await contract.connect(addr1).mintBundle(tx);
  // await contract.connect(addr1).mintBundle(tx);

  await contract.connect(owner).setVifSale();
  await contract.connect(addr1).mintBundle(addr1Proof, 30, {value: ethers.utils.parseEther('0.1')});

  await contract.connect(owner).setVifSale();
  await contract.connect(owner).setFruitieSale();
  await contract.connect(addr1).mintBundle(addr1Proof, 30, {value: ethers.utils.parseEther('0.1')});

  await contract.connect(owner).setFruitieSale();
  await contract.connect(owner).setPublicSale();

  await contract.connect(addr1).mintBundle(addr1Proof, 30, {value: ethers.utils.parseEther('0.1')});
  await contract.connect(addr2).mintBundle(addr1Proof, 30, {value: ethers.utils.parseEther('0.1')});



}

main()
.then(() => process.exit(0))
.catch((error) => {
  console.log(error);
  process.exit(1);
})
const { MerkleTree } = require('merkletreejs');
const { keccak256 } = require('ethers/lib/utils');
const accounts = require('./Accounts.json');
const hre = require('hardhat');
// const ethers = require('ethers');
// This code is going to be used for testing and then put into the
// Backend

async function main() {

  // !! this code works!!!
  // ! backend code!!
  // !! this code is key for encoding our lists
  // ? This encoder mimics the solidity abi.encode byte encoding method
  const encoder = ethers.utils.defaultAbiCoder;
  const leaves = accounts.vif.map(account => encoder.encode(["address", "string"], [account, "30"]));
  // const leaves = accounts.vif.map(account => encoder.encode(["address", "string"], [account, "<dynamic value>"]));

  //* leaves will be accumulated in a db and a spread sheet. A discord bot will interact with both of these
  const tree = new MerkleTree(leaves, keccak256, { hashLeaves: true, sortPairs: true});

  //* root will be created when we fill all VIF and whitelist members.
  const root = tree.getHexRoot();

  //* proof will be generated when the user clicks the mint button.
  // the code will generate the hash based on the address and the
  // VIF or Presale
  const leaf = keccak256(leaves[0])

  const proof = tree.getHexProof(leaf);

  console.log("js Merkle test", tree.verify(proof, leaf, root));
  await contract.setMerkleRoot(root); // root will be set on mint date


}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.log(error);
    process.exit(1);
  })
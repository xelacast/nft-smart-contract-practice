const { MerkleTree } = require('merkletreejs');
const accounts = require('../json/accounts.json');
const { keccak256 } = require('ethers/lib/utils');


// When using the hashLeaves true it is hashing the leaves as they come in.
// In this process of doing things the accounts are being hashed twice so
// We must use a hash of the account that was already hashed to get the leaf
// Is this more secure? or stupid to do?

function main() {
  const vifMaxAmount = '03';

  // hashed accounts and maxAmmount into keccak256
  const vifAccountsLeafs = accounts.vif.map(account => keccak256(account + vifMaxAmount));
  console.log(accounts.vif[1])
  console.log(vifAccountsLeafs[1])

  const tree = new MerkleTree(
    vifAccountsLeafs,
    keccak256,
    {hashLeaves: true, sortPairs: true, duplicateOdd: true}
    );

    // console.log(tree.leaves[1]);
    // console.log(keccak256(vifAccountsLeafs[1]))
  const root = tree.getHexRoot();
  // leaf must be a hash of the leaf
  const leaf = keccak256(vifAccountsLeafs[1]);
  console.log(leaf)
  const proof = tree.getHexProof(leaf);

  console.log(tree.verify(proof, leaf, root));
  // console.log(proof)

  /// second take

  // no matter how many times you hash your leaves your leaves will always be the same if you pull from the same array as them.
  const leafes = accounts.vif.map(account => keccak256(keccak256(account)))

  const tree1 = new MerkleTree(
    leafes,
    keccak256,
    {hashLeaves: true, sortPairs: true, duplicateOdd:true}
    );

  const root1 = tree1.getHexRoot();
  // leaf must be a hash of the leaf
  const leaf1 = keccak256(leafes[1]);
  console.log(leaf1)
  const proof1 = tree1.getHexProof(leaf1);

  console.log(tree1.verify(proof1, leaf1, root1));
  // console.log(proof1)

}

main()
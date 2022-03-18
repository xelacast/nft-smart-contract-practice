This is the write up of using a merkle tree to create a VIF list and a fruitylist(presale list)

Instead of using a mapping and writing data to the EVM at a cost I can connect the hash of a merkle tree to the contract. The merkle tree can be deciphered to see which accounts are on it. I must create 2 of these merkle trees. 1 for the VIF sale and 1 for the Fruity/presale. As of March 15th, 2022 I have started my journey of learning how merkle trees work and how to use them in my contract. I will add updates to this file as I learn.

As of now I know I can remove a large portion of code from my contract involving the VIF and Presale creation. Heres for v4 of my contract probably v9 if im being honest. Itll be version 0.09.1.

Merkle trees are precise. The major portion of correctness has to be done on both ends of confirmation. The front end must confirm they are part of the tree and the solidity contract must confirm they are part of the tree. The logic has to be specific on both ends for correctness. As of now I will use one hashing of my leaves. In the creation of the tree the leaves will be hased

I am adding a string to the end of the addresses as a padding to show how many amounts they can mint. I have a problem. When i only use the address to create the tree and the proof, Solidity can verify that. When I add an extra string to the end of each account, make the tree, and get the root of the new tree solidity cannot follow that. Solidity uses abi.encodPacked to concatinate bytes. I am sending in the address and the maximum amount they can mint and concatinating it to then get the keccak256 hash of it to create the leaf. When i send it into the merkle proof it spits out false but when i use it in the js file it spits out true

March 17th i figured out how to encode merkle trees into my contract and track them on the frontend and the smartcontract
This is the write up of using a merkle tree to create a VIF list and a fruitylist(presale list)

Instead of using a mapping and writing data to the EVM at a cost I can connect the hash of a merkle tree to the contract. The merkle tree can be deciphered to see which accounts are on it. I must create 2 of these merkle trees. 1 for the VIF sale and 1 for the Fruity/presale. As of March 15th, 2022 I have started my journey of learning how merkle trees work and how to use them in my contract. I will add updates to this file as I learn.

As of now I know I can remove a large portion of code from my contract involving the VIF and Presale creation. Heres for v4 of my contract probably v9 if im being honest. Itll be version 0.09.1.
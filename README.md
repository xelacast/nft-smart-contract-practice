Functions

mintBundle public (runs out when the bundle supply hits 0)
giveawayBundle onlyOwner/onlyDelegates

setBundleSupply onlyOwner
getBundleSupply public

increaseReceiptSupply onlyOwner
getReceiptSupply public

setSaleTime onlyOwner
getSaleTime public (Do not set until we release the date of sale to the public)

setPresaleTime onlyOwner
getPresaleTime public

cuteeExchange public

setWhiteListMembers onlyOwner
getWhiteListMembers onlyOwner

setBundlePrice onlyOwner
getBundlePrice onlyOwner

getBalance onlyOwner
withdrawBalance onlyOwner

setUri()
setReveal() boolean true it shows the cuties false it shows “hidden.json”

What needs to be tested?
MintAll bundles with no overflow. Check for balances and users can only mint one per account. Must have the right ether to give to the contract.
White list and presale
Public sale
Sale Activation
All token ids shall be used from 0, 1-4000, 10001-101000
Metadata creation must be excellent for 4in1s to correspond to actual pictures and other tokens

What have I tested?
#TODOS
- test everything and report numbers on ropsten testnet

#TODOS
-Season reset all in one call.
-Set Sale time so its openended setSaleEndTime?
-Create dependency Chart for all functionality
-Create Season start and end chat (dependecy)
  - What does it take to create the next season?
    Change the parameters of
    - Fruit and fourInOne upper and lower bounds
      Upper and lower bounds must be exact ids that the last season ended on. This must be set on reveal.
    - Reset VIFs and BundleBalances
    - Set giveaway count
    - Set Presale time and time for actual sale
    - Set bundle balance
    - Set receipt count
    - upload fourInOnes and Fruit metaData to ipfs that corresponds with token Ids
  - What does it take to end the season?

#How to use
Set a Uri with function setUri(string);
Setting a uri for change of pictures. Must use a DNS that points to an ipfs for all pictures.

#URIs IMPORTANT
I must use a DNS that points to an ipfs for all pictures. This allows me to change the ipfs CID of specific metadata to change the 4in1 metadata attributes and picture.
I must change the IPFS of future seasons to the ipfs of a hidden photo or create the DNS and ipfs pointer and change the URI of specific token ids to the hidden.json metadata. How? Is this possible?
The URI will be chosen based on four parameters. The fruitTokenId Upper parameter the fruitTokenId Lower Parameter, fourInOneTokenId Upper paramter and fourInOneTokenId Lower Parameter. These paramters will allow CuteeFruitee to use hidden.json metadata to show NFT preview photo of the current season. Once the prevue and public sale are finished the Parameters must be changed for the next season or are set to abstract numbers representing the end of all seasons. Changing the parameters opens the current season Picture and metadata for reveal.
Upon Creation of the Contract the hidden uri (uriHidden), and actual uri will be set to never needed to be changed again. Both are DNS links that point to ipfs data so we can update data in the future.
  - NOTE: BIG PROBLEM someone can look up the reveals of future season if they have the CID for the previous season. Unless we do not upload them until a few hours before the reveal.
  - NOTE: Problem Fix? set no upper limit to x amount and everything above that will have a hidden.json metadata until the lower parameter is brought forth. Upper params are set because we know all token IDs and how many we will create. This creates less dependecies that can go wrong but this does not solve the issues of sneaking the URI based on the old DNS unless we set all tokenIds for the future seasons and then change the IPFS it points to at the start of everyseason. I can create a javascript script to check for a date and then send a post request to the DNS changing all ipfs in the season parameters.


#GasOptimization
Inside the OpenZeppelin ERC1155 contract there is a mapping of _balances. It looks like this.
  mapping(uint256 => mapping(address => uint256)) private _balances;
When this mapping is incremented on and used in the MintBatch function of the openzeppelin contract it uses a lot of gas. In Hardhat Gas units it uses ~136,000 units for an 8 nft batch mint.
This can be changed by creating an array of structs that holds 2 pieces of data. The address of the owner and an array of token ids they own. or a mapping of the token ids(this will be more expensive). If it is an array of token ids it wouln't be in numerical order and hard to delete unless I incremented over the ids. Using this is more difficult for multiple NFTs and SFTs because there will be more than n ammount of SFTs with the same id value.
the struct can look like this
  struct Cutee {
    address owner;
    uint256[] tokens;
  }

  Cutee[] cuties;

  or

  struct Cutee {
    address owner;
    mapping(uint256 => uint256) tokenToAmmount;
  }

  Cutee[] cuties;

The expense of the mapping in the struct is there will be a creation of a Cutee and the mapping will be expensive

TheOtherSide is using a struct of
  struct Moon {
    address owner;
    bool celestialType;
  }
and an array of
  Moon public moons;
This array holds all the ids of the tokens and the token ids are the indexes of the structs
  example
  address owner = moons[tokenId].owner;
  in their _mint
    function _mint(address to, uint tokenId) internal {
      _beforeTokenTransfer(address(0), to);
      moons.push(Moon(to,false));
      emit Transfer(address(0), to, tokenId);
  }

They are mapping a struct to the index of the moons. This requires all indexes to be corresponding with the tokenIds themselves and the corresponding owner. I can use this and put an ammount in the struct.
ex
  struct Cutee {
    address owner;
    uint256 ammount;
  }

  Cutee[] cuties;

  _mint() {
    cuties.push(Cutee(_to, ammount));
  }

_to is the minting address
ammount is always one unless specified for the receipts

_mintBatch will require me to push n amount of nfts to the array
ex
function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(
            ids.length == amounts.length,
            "ERC1155: ids and amounts length mismatch"
        );

        address operator = _msgSender();

        // this uses 136k gas to mint. ITs a crucial part. Its time to optimize
        //for (uint256 i = 0; i < ids.length; i++) {
        //    _balances[ids[i]][to] += amounts[i];
        //}

        for (uint256 i = 0; i < ids.lenth; i++) {
          cuties.push(to, ammounts[i]);
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(
            operator,
            address(0),
            to,
            ids,
            amounts,
            data
        );
    }

I must change the transfer function to subtract the amount and change the owner.

So all in all the ids of the tokens are mapped to an array corresponding with its index.
I cant do this. The ammount of tokens for 0 changes per owner and supply changes. Also the token ids of the fourInOnes are 100000 and above.
I could create a mapping of structs that correspond with the amount of ids owned per owner. The indexes of ids will correspond with the ammount indexes.
ex
  struct Cutee {
    address owner;
    uint256[] ids;
    uint256[] ammounts;
  }
  mapping(address => Cutee) addressToOwners;

EDIT 02/22/2022
Use two arrays and one struct
One array for fruitIds
one array for fourInOneIds
indexes of array correspond with the token id
zero index of both arrays are filled with filler data
struct holds the owner.
How does the receipt value get implemented? id of receipt is 0, multiple users have multiple receipts. Do i need to map this?

EDIT 02/22/2022 after above
I used the mapping(address => Cutee) addressToTokenIds
and a struct
Cutee {
  uint256[] tokenIds;
  uint256 receiptAmount;
}
to no avail of changing to this or all arrays and structs the gas usage only went up. To view this spreadsheet with little details on gas usage on hardhat (https://docs.google.com/spreadsheets/d/1s34EbMMvwh9FDYPeU7Sh8uJq4qtfzP6GOPcWqWT2374/edit?usp=sharing). Maybe the gas units used on hardhat are different on ropsten? Im unsure at the current moment but i will test it.

#Contract Reformat and Future Season Variable Reset
My motivation to reformat my code is to make it legible. To comment the functions that are crucial for future upgrades and variable redeclaration. To change variable and function names to more appropriate matters and make a dependency chart(ill have to draw this out as i go then digitize it).
- Season Reset
If every season is going to have the same exact variable decarations except the ids, i can have a function that resets it by calling it
ex
function setSeason() {
  variables vifSpots, giveaways, bundleSupply, receiptSupply,
  fruitTokenIdLowerParam, fourInOneTokenIdUpperParam, presaleStartTime, saleStartTime
}
I dont think this would be the best case. To make it dynamic to see how active we are per season will determin giveaways and vif spots.
bundle count will always be the same so ids are set based on finite amount of supply determined for season 1.
- Make a checklist of everything i must do to set the season

TODOS for implementation

#Website Security
  Bot Detector. Only one account address associated with one ip. Look at the ropsten ether faucet source code for reference. They put a 2 week limit on wallet address and the ip associated with them. I can put the limit on the wallets until the next sale. website(https://github.com/wu4f/ropsten_faucet). This technique will stop user from switching their accounts on their wallets to pay for more than one mint. A work around is to use a vpn and another account address.

#Contract Security

#BIG CHANGES
I removed the parameters of the URI. I will implement hidden and prereveal features with the dns and ipfs only. This will save gas on deployment and setting each season. This also makes the deployment of each season a little less dependent on our contract.

I had to remove all mapping of the whitelist features because it would have taken $5k-$7k in adding people to the fruity list. Roughly 800 people.

#MERKLE TREE THOUGHTS

This is the write up of using a merkle tree to create a VIF list and a fruitylist(presale list)

Instead of using a mapping and writing data to the EVM at a cost I can connect the hash of a merkle tree to the contract. The merkle tree can be deciphered to see which accounts are on it. I must create 2 of these merkle trees. 1 for the VIF sale and 1 for the Fruity/presale. As of March 15th, 2022 I have started my journey of learning how merkle trees work and how to use them in my contract. I will add updates to this file as I learn.

As of now I know I can remove a large portion of code from my contract involving the VIF and Presale creation. Heres for v4 of my contract probably v9 if im being honest. Itll be version 0.09.1.

Merkle trees are precise. The major portion of correctness has to be done on both ends of confirmation. The front end must confirm they are part of the tree and the solidity contract must confirm they are part of the tree. The logic has to be specific on both ends for correctness. As of now I will use one hashing of my leaves. In the creation of the tree the leaves will be hased

I am adding a string to the end of the addresses as a padding to show how many amounts they can mint. I have a problem. When i only use the address to create the tree and the proof, Solidity can verify that. When I add an extra string to the end of each account, make the tree, and get the root of the new tree solidity cannot follow that. Solidity uses abi.encodPacked to concatinate bytes. I am sending in the address and the maximum amount they can mint and concatinating it to then get the keccak256 hash of it to create the leaf. When i send it into the merkle proof it spits out false but when i use it in the js file it spits out true

March 17th I learned how to encode merkle trees into my contract and track them on the frontend and the smartcontract allowing myself to create a whitelist and maybe two.
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

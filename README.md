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
-Season reset all in one call
-Set Sale time so its openended setSaleEndTime?


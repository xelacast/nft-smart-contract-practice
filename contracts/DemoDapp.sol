//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";

contract DemoDapp is ERC1155, Ownable {
    uint256 constant receiptTokenId = 0;
    uint256 receiptTotalSupply = 3000;
    uint256 fruitTokenId = 1; // first season will go to 4000
    uint256 fourInOneTokenId = 100001; // first season will go to 101000

    uint256 giveaways = 250;
    uint256 batchSupply = 1000 - giveaways;

    event IncreaseReceiptSupply(address _sender, uint256 _supply);

    mapping(address => uint256) private bundleBalance; // stop people from trading out and buying if nfts are traded to another account the account traded to can still buy
    mapping(uint256 => address) private tokenIdToAddress; // used for cuteeExchange. can use balaneceOf Instead

    constructor(string memory uri) ERC1155(uri) {}

    function mintBundle() external payable {
        require(
            msg.value >= 0.08 ether,
            "Not enough ether in account to transact."
        );
        require(
            bundleBalance[msg.sender] == 0,
            "Cannot purchase more than one batch mint per wallet"
        );
        require(batchSupply > 0, "All Batches have been minted");
        // require(fruitTokenId < 4001, "All tokens have been given away");
        require(
            msg.sender == tx.origin,
            "Contract calls cannot mint our supply"
        );

        // set token ids that are going to be minted
        // uint256[] memory idHolder = batchIdHolder;
        uint256[] memory batchMintAmmount = new uint256[](6);
        batchMintAmmount[0] = 1;
        batchMintAmmount[1] = 1;
        batchMintAmmount[2] = 1;
        batchMintAmmount[3] = 1;
        batchMintAmmount[4] = 1;
        batchMintAmmount[5] = 3;

        uint256[] memory idHolder = new uint256[](6);
        idHolder[0] = fruitTokenId;
        fruitTokenId++;
        idHolder[1] = fruitTokenId;
        fruitTokenId++;
        idHolder[2] = fruitTokenId;
        fruitTokenId++;
        idHolder[3] = fruitTokenId;
        fruitTokenId++;
        idHolder[4] = fourInOneTokenId;
        fourInOneTokenId++;
        idHolder[5] = receiptTokenId;

        bundleBalance[msg.sender]++;

        _mintBatch(msg.sender, idHolder, batchMintAmmount, "");

        receiptTotalSupply = receiptTotalSupply - 3;
        batchSupply--;
    }

    /// @notice This givaway will not impact the presale and sale to minting limit of 1
    /// @dev the parameter is an array to mint multiple batches at once
    function giveawayMintBatch(address[] calldata _to) external onlyOwner {
        require(giveaways > 0, "Out of Giveaways.");

        uint256[] memory batchMintAmmount = new uint256[](6);
        batchMintAmmount[0] = 1;
        batchMintAmmount[1] = 1;
        batchMintAmmount[2] = 1;
        batchMintAmmount[3] = 1;
        batchMintAmmount[4] = 1;
        batchMintAmmount[5] = 3;

        uint256[] memory idHolder = new uint256[](6);

        for (uint256 i = 0; i < _to.length; i++) {
            idHolder[0] = fruitTokenId;
            fruitTokenId++;
            idHolder[1] = fruitTokenId;
            fruitTokenId++;
            idHolder[2] = fruitTokenId;
            fruitTokenId++;
            idHolder[3] = fruitTokenId;
            fruitTokenId++;
            idHolder[4] = fourInOneTokenId;
            fourInOneTokenId++;
            idHolder[5] = receiptTokenId;
            _mintBatch(_to[i], idHolder, batchMintAmmount, "");
            receiptTotalSupply = receiptTotalSupply - 3;
            giveaways--;
            batchSupply--;
        }
    }

    function increaseReceiptSupply(uint256 _supply) external onlyOwner {
        receiptTotalSupply = receiptTotalSupply + _supply;
        emit IncreaseReceiptSupply(msg.sender, _supply);
    }

    // probably dont need this theres no outside test cases
    function getBundleBalance() public view returns (uint256) {
        return bundleBalance[msg.sender];
    }

    function getBatchSupply() public view onlyOwner returns (uint256) {
        return batchSupply;
    }

    function getReceiptSupply() public view onlyOwner returns (uint256) {
        return receiptTotalSupply;
    }

    // can be a seperate contract to inherit
    function getBalanceOfContract() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }

    function withdrawBalance() external onlyOwner {
        require(address(this).balance > 0, "No ether in contract");
        payable(msg.sender).transfer(address(this).balance);
    }

    function cuteeExchange(
        uint256 _fruitTokenId,
        uint256 _fourInOneTokenId,
        uint256 _quadrant
    ) public {
        // if quadrant is a large number send it to the oracle and it will do modulus on it. This will save gas for exchange
        address[] memory accounts = new address[](3);
        uint256[] memory balances = new uint256[](3);
        uint256[] memory balanceCheck = new uint256[](3);

        accounts[0] = msg.sender;
        accounts[1] = msg.sender;
        accounts[2] = msg.sender;

        balances[0] = _fruitTokenId;
        balances[1] = _fourInOneTokenId;
        balances[2] = receiptTokenId;

        balanceCheck = balanceOfBatch(accounts, balances);

        require(balanceCheck[0] > 0, "You do not own the fruittoken");
        require(balanceCheck[1] > 0, "You do not own the fourInOneToken");
        require(balanceCheck[2] > 0, "You do not own a receipt for exchange");
    }
}

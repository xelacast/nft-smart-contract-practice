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

    uint256[] batchMintAmmount = [1, 1, 1, 1, 1, 3];
    uint256[] batchIdHolder = [0, 0, 0, 0, 0, 0];

    event IncreaseReceiptSupply(address _sender, uint256 _supply);

    mapping(address => uint256) private bundleBalance; // stop people from trading out and buying if nfts are traded to another account the account traded to can still buy
    mapping(uint256 => address) private _owners; // Token to wallet address

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
        uint256[] memory idHolder = batchIdHolder;
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
    // Can i make this a multiple match batch to gift multiple people at once?
    function giveawayMintBatch(address _to) external onlyOwner {
        require(giveaways > 0, "Out of Giveaways.");
        uint256[] memory idHolder = batchIdHolder;
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

        _mintBatch(_to, idHolder, batchMintAmmount, "");

        receiptTotalSupply = receiptTotalSupply - 3;
        giveaways--;
        batchSupply--;
    }

    function increaseReceiptSupply(uint256 _supply) external onlyOwner {
        receiptTotalSupply = receiptTotalSupply + _supply;
        emit IncreaseReceiptSupply(msg.sender, _supply);
    }

    function getBundleBalance() public view returns (uint256) {
        return bundleBalance[msg.sender];
    }

    function getBatchSupply() public view onlyOwner returns (uint256) {
        return batchSupply;
    }

    function getReceiptSupply() public view onlyOwner returns (uint256) {
        return receiptTotalSupply;
    }

    function getBalanceOfContract() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }

    function withdrawBalance() external onlyOwner {
        require(address(this).balance > 0, "No ether in contract");
        payable(msg.sender).transfer(address(this).balance);
    }
}

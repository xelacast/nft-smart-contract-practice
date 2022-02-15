//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";

contract DemoDapp is ERC1155, Ownable {
    uint256 constant receiptTokenId = 0;
    uint256 receiptTotalSupply = 3000;
    uint256 fruitTokenId = 1;
    uint256 fourInOneTokenId = 100000;

    uint256 batchSupply = 1000;
    uint256 giveaways = 250;

    uint256[] batchMintAmmount = [1, 1, 1, 1, 1, 3];
    uint256[] batchIdHolder = [0, 0, 0, 0, 0, 0];

    string private _uri;

    event IncreaseReceiptSupply(address _sender, uint256 _supply);

    mapping(uint256 => string) private tokenToUri;
    mapping(address => uint256) private bundleBalance;
    mapping(uint256 => address) private _owners;

    constructor(string memory uri) ERC1155(uri) {
        _uri = uri;
        _setUri(receiptTokenId);
    }

    // this is a hunch that this will populate the nft token name on etherscan
    // but it could be the meta data that does that for erc1155
    // need more info.

    // this was removed for a purpose
    // function name() public view virtual returns (string memory) {
    //     return _name;
    // }
    // this was removed for a purpose
    // function symbol() public view virtual returns (string memory) {
    //     return _symbol;
    // }

    /// @dev Overide _setUri to input the ids into the uris
    function _setUri(uint256 _tokenId) internal virtual {
        tokenToUri[_tokenId] = string(
            abi.encodePacked(_uri, Strings.toString(_tokenId), ".json")
        );
        emit URI(_uri, _tokenId);
    }

    function getUri(uint256 _tokenId)
        public
        view
        virtual
        returns (string memory)
    {
        return tokenToUri[_tokenId];
        // string(abi.encodePacked(_uri, Strings.toString(_tokenId), ".json"));
    }

    // I do not have to set these uris nor do i have to map them to a mapping
    function setBatchUris(uint256[] memory _batchIds)
        internal
        returns (uint256[] memory)
    {
        // must find a way to pad the uri id with 64 characters
        tokenToUri[fruitTokenId] = string(
            abi.encodePacked(_uri, Strings.toString(fruitTokenId), ".json")
        );
        _batchIds[0] = fruitTokenId;
        fruitTokenId++;
        tokenToUri[fruitTokenId] = string(
            abi.encodePacked(_uri, Strings.toString(fruitTokenId), ".json")
        );
        _batchIds[1] = fruitTokenId;
        fruitTokenId++;
        tokenToUri[fruitTokenId] = string(
            abi.encodePacked(_uri, Strings.toString(fruitTokenId), ".json")
        );
        _batchIds[2] = fruitTokenId;
        fruitTokenId++;
        tokenToUri[fruitTokenId] = string(
            abi.encodePacked(_uri, Strings.toString(fruitTokenId), ".json")
        );
        _batchIds[3] = fruitTokenId;
        fruitTokenId++;

        _batchIds[4] = fourInOneTokenId;
        fourInOneTokenId++;
        _batchIds[5] = receiptTokenId;
        return _batchIds;
    }

    function mintBundle() external payable {
        require(
            msg.value >= 0.05 ether,
            "Not enough ether in account to transact."
        );
        require(
            bundleBalance[msg.sender] == 0,
            "Cannot purchase more than one batch mint per wallet"
        );
        require(batchSupply > 0, "All Batches have been minted");
        require(fruitTokenId < 4001, "All tokens have been given away");

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

        // idHolder = setBatchUris(idHolder);
        batchSupply--;
        // check with different logic using balanceOf ERC1155 function
        bundleBalance[msg.sender]++;
        receiptTotalSupply = receiptTotalSupply - 3; // do i need this if im working with batch supply?

        _mintBatch(msg.sender, idHolder, batchMintAmmount, "");

        // console.log("Hash of token id", hashing);
    }

    function increaseReceiptSupply(uint256 _supply) external onlyOwner {
        receiptTotalSupply = receiptTotalSupply + _supply;
        emit IncreaseReceiptSupply(msg.sender, _supply);
    }

    function getBundleBalance() public view returns (uint256) {
        return bundleBalance[msg.sender];
    }

    function getBatchSupply() public view returns (uint256) {
        return batchSupply;
    }

    function getReceiptSupply() public view returns (uint256) {
        return receiptTotalSupply;
    }

    function getBalanceOfContract() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }

    function withdrawBalance(address payable _to) external onlyOwner {
        _to.transfer(address(this).balance);
    }
}

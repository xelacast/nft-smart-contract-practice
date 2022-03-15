//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Context.sol";

// must be revamped for gas optimization
import "./tokens/IERC1155MetadataURI.sol";
import "./tokens/ERC1155.sol";
import "./utils/Ownable.sol";

// import "hardhat/console.sol";

contract DemoOptimized is
    ERC1155,
    Ownable,
    ReentrancyGuard,
    IERC1155MetadataURI
{
    uint256 constant receiptTokenId = 0;
    uint256 fruitTokenId = 1;
    uint256 fourInOneTokenId = 100001;

    /// @dev will always be reset to 1000; when all bundles are sold
    /// NOTE edge case what if all bundles for a season dont sell and you want to mint the new season? how would the ids work? or we must not release a new season unless the last season is sold out.
    uint256 bundleSupply = 1000;
    uint256 receiptSupply = 3000;

    /// @notice @dev 100000000 gwei
    uint256 pricePerBundle = 0.1 ether;

    /// @dev lower params will change with seasons
    // uint256 fruitTokenIdLowerParam = 0;
    // uint256 fourInOneTokenIdLowerParam = 99999;
    // uint256 fruitTokenIdUpperParam = 100001;
    // uint256 fourInOneTokenIdUpperParam = 999999;

    /// @dev presaleStartTime will be set with each season launch
    uint256 vifSaleStartTime;
    uint256 presaleStartTime;
    uint256 publicSaleStartTime;

    string private _uri;
    string private _uriPreview;

    /// @dev array to reset the VIF mapping
    // address[] presaleMembers;
    // address[] veryImportantFruit;

    /// @dev array to show sale options
    // struct CuteeSale {
    //     uint32 vif;
    //     uint32 presale;
    // }

    /// @dev balance of bundles minted
    /// @notice this balance will be tracked and reset for every season
    /// TODO redo this with a struct and one mapping. This might save gas
    mapping(address => uint256) private bundleBalance;
    mapping(address => uint256) private addressToVifMember;
    mapping(address => uint256) private addressToPresaleMember;
    mapping(address => uint256) private addressToMintPass;

    uint256 vifCount;
    address[] presaleMemberList;

    event IncreaseReceiptSupply(address _sender, uint256 _supply);

    constructor(string memory uri1, string memory uriPreview1) ERC1155() {
        _setUri(uri1, uriPreview1);
        vifCount = 0;
    }

    /*
    @dev uses block time stamp to start presale and sale
    based on setPresaleStartTime(uint256 _presaleStartTime, uint256 _timeBetweenSales)
    saleTime will be set with _presaleStartTime+_timeBetweenSales
    */
    // modifier isSaleActive() {
    //     // VIF sale
    //     require(block.timestamp > vifSaleStartTime, "VIF sale has not started");
    //     if (block.timestamp < presaleStartTime) {
    //         require(
    //             addressToVifMember[msg.sender] > 0,
    //             "VIF sale is active but you're are not a VIF, wait for presale"
    //         );
    //     }
    //     // Presale
    //     else if (
    //         block.timestamp > presaleStartTime &&
    //         block.timestamp < publicSaleStartTime
    //     ) {
    //         require(
    //             addressToPresaleMember[msg.sender] > 0 ||
    //                 addressToVifMember[msg.sender] > 0,
    //             "Presale is active but you have not been given a spot in presale"
    //         );
    //     }

    //     _;
    // }
    // TODO make a new modifier to check counts of bunldes.
    modifier isSaleActive() {
        // VIF sale
        require(block.timestamp > vifSaleStartTime, "VIF sale has not started");

        if (block.timestamp < presaleStartTime) {
            require(
                addressToVifMember[msg.sender] > 0,
                "VIF sale is active but you're are not a VIF, wait for presale"
            );
            require(
                bundleBalance[msg.sender] <= 1,
                "You can only mint one fruit basket during VIF sale"
            );
        }
        // Presale
        else if (
            block.timestamp > presaleStartTime &&
            block.timestamp < publicSaleStartTime
        ) {
            require(
                (addressToVifMember[msg.sender] > 0 &&
                    bundleBalance[msg.sender] < 2) ||
                    (addressToPresaleMember[msg.sender] > 0 &&
                        bundleBalance[msg.sender] < 1),
                "Can only mint one fruit basket during presale."
            );
        } else {
            require(
                (addressToVifMember[msg.sender] > 0 &&
                    bundleBalance[msg.sender] < 3) ||
                    (addressToPresaleMember[msg.sender] > 0 &&
                        bundleBalance[msg.sender] < 2) ||
                    bundleBalance[msg.sender] < 1,
                "Can only mint one fruit basket during public sale."
            );
        }

        _;
    }

    /**
        @dev primary mint for all mints
     */
    function mintBundle() public payable nonReentrant isSaleActive {
        require(
            msg.value >= 0.1 ether,
            "Not enough ether was sent to purchase your fruit basket."
        );
        require(bundleSupply > 0, "All Bundles have been minted.");

        address recipient = _msgSender();

        _mintBundle(recipient);
    }

    /*
        @dev mintpassGiveaway will allow the user to mint before anysales
        @notice the mintPass can be used for any of our mints if and only if
        There are any bundles left
    */
    function mintPassGiveaway() public {
        require(bundleSupply > 0, "All bundles have been minted.");
        require(
            addressToMintPass[msg.sender] > 0,
            "You do not have a free mint"
        );

        address recipient = _msgSender();

        addressToMintPass[recipient]--;

        _mintBundle(recipient);
    }

    function mintPass(address[] calldata _giveaways) public onlyOwner {
        for (uint256 i = 0; i < _giveaways.length; i++) {
            addressToMintPass[_giveaways[i]]++;
        }
    }

    /// @dev _mintBundle is used for giveaways and sale mints
    function _mintBundle(address _to) private {
        uint256[] memory batchMintAmmount = new uint256[](6);
        uint256[] memory idHolder = new uint256[](6);

        batchMintAmmount[0] = 1;
        batchMintAmmount[1] = 1;
        batchMintAmmount[2] = 1;
        batchMintAmmount[3] = 1;
        batchMintAmmount[4] = 1;
        batchMintAmmount[5] = 3;

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

        bundleBalance[msg.sender]++;

        _mintBatch(msg.sender, idHolder, batchMintAmmount, "");

        bundleSupply--;
    }

    /*
    @dev sets necessary params to conclude our post season
    These things must be done
    Set Bundle Supply to 1000 only if and only if bundle supply is at 0
    increase the receipt supply by 3000
    reset the presale members for past season
    emit event to document increase in reeipts(burn currency)
    */

    function setSeason() public onlyOwner {
        require(
            bundleSupply <= 0,
            "All bundles have not been given away or sold"
        );

        bundleSupply = 1000;
        receiptSupply = receiptSupply + 3000;

        resetPresaleMembers();

        emit IncreaseReceiptSupply(msg.sender, 3000);
    }

    /// @dev time is in seconds from the January 1st, 1970 Epoch
    function setSaleTime(
        uint256 _vifSaleStartTime,
        uint256 _presaleStartTime,
        uint256 _publicSaleStartTime
    ) public onlyOwner {
        require(
            _presaleStartTime > _vifSaleStartTime,
            "Presale Must be later than Vif Sale"
        );
        require(
            _publicSaleStartTime > _presaleStartTime,
            "Public sale must be later than the presale"
        );

        vifSaleStartTime = _vifSaleStartTime;
        presaleStartTime = _presaleStartTime;
        publicSaleStartTime = _publicSaleStartTime;
    }

    function receiptTotalSupply() public view returns (uint256) {
        return receiptSupply;
    }

    function bundleTotalSupply() public view returns (uint256) {
        return bundleSupply;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdrawBalance() external onlyOwner {
        require(address(this).balance > 0, "No ether in contract");
        payable(msg.sender).transfer(address(this).balance);
    }

    // ------------------------- //
    /// @dev uri section       ///
    // ------------------------- //

    /// @dev The ipfs of all fruit tokens will be updated and secure with a new
    /// CID every season. The cid to the ipfs will be linked used a DNS with
    /// our personal domain name. All metadata and pictures will be hosted
    /// on the IPFS
    function uri(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        if (_tokenId > 100000) {
            return
                string(
                    abi.encodePacked(
                        _uri,
                        "/4in1s/",
                        Strings.toString(_tokenId),
                        ".json"
                    )
                );
        }

        if (_tokenId == 0) {
            return
                string(
                    abi.encodePacked(
                        _uri,
                        "/receipts/",
                        Strings.toString(_tokenId),
                        ".json"
                    )
                );
        }

        return
            string(
                abi.encodePacked(
                    _uri,
                    "/fruits/",
                    Strings.toString(_tokenId),
                    ".json"
                )
            );
    }

    function _setUri(string memory uriSetter, string memory uriPreviewSetter)
        internal
        virtual
    {
        _uri = uriSetter;
        _uriPreview = uriPreviewSetter;
    }

    // ------------------------- //
    /// @dev sale section       ///
    // ------------------------- //

    /// @dev sale start time will set x ammount of time after presale start time.
    /// Leads to less dynamics. The time is in seconds from the 1970 epoch
    /// @param _presaleStartTime argument must be set in seconds
    /// @param _timeBetweenSales argument must be set in seconds
    // function setPresaleStartTime(
    //     uint256 _presaleStartTime,
    //     uint256 _timeBetweenSales
    // ) public onlyOwner {
    //     presaleStartTime = _presaleStartTime;
    //     publicSaleStartTime = _presaleStartTime + _timeBetweenSales;
    //     emit SaleHasBeenSet(presaleStartTime, publicSaleStartTime);
    // }

    // function getSaleStartTimes() public view returns (string memory) {
    //     return
    //         string(
    //             abi.encodePacked(
    //                 "Presale is at",
    //                 Strings.toString(presaleStartTime),
    //                 ", and public sale is at",
    //                 Strings.toString(publicSaleStartTime),
    //                 " seconds from epoch"
    //             )
    //         );
    // }

    /// @dev set this based on volatility of market
    function setPricePerBundle(uint256 _gwei) public onlyOwner {
        pricePerBundle = _gwei;
        // emit PricePerBundle(msg.sender, _gwei);
    }

    function getPricePerBundle() public view returns (uint256) {
        return pricePerBundle;
    }

    // ------------------------------ //
    /// @dev VIF and Presale section ///
    // ------------------------------ //

    /// @dev VIF members will have confirmed spots in minting
    /* @notice VIF members can mint up to three times. Once in VIF sale,
        onces in Presale, and once in public. We did this to let the
        member be as active as they want and removed the ability to
        mint all 3 bundles at once. This leads to ore fairness in minting
    */
    function setVIFMember(address[] memory _vifs) public onlyOwner {
        for (uint256 i = 0; i < _vifs.length; i++) {
            addressToVifMember[_vifs[i]] = 1;
            vifCount++;
        }
    }

    function setFruityMember(address[] memory _fruities) public onlyOwner {
        for (uint256 i = 0; i < _fruities.length; i++) {
            addressToPresaleMember[_fruities[i]] = 1;
            presaleMemberList.push(_fruities[i]);
        }
    }

    /// @dev manualy remove VIF members with given addresses
    function removeVIFMembers(address[] memory _vifs) public onlyOwner {
        for (uint256 i = 0; i < _vifs.length; i++) {
            addressToVifMember[_vifs[i]] = 0;
            vifCount--;
        }
    }

    function resetPresaleMembers() public onlyOwner {
        for (uint256 i = 0; i < presaleMemberList.length; i++) {
            addressToPresaleMember[presaleMemberList[i]] = 0;
        }
        delete presaleMemberList;
    }

    /// NOTE: this can be implemented if the contract has sufficient room to add to
    /// @dev can be used to get a vifMember
    /// @notice if the address you entered returns with 1 it has been VIFed
    // function getMember(address _address) public view returns (string memory) {
    //     if (addressToVifMember[_address] == 1) {
    //         return string(abi.encodePacked("The address entered is VIF'd"));
    //     }
    //     if (addressToPresaleMember[_address] == 1) {
    //         return
    //             string(
    //                 abi.encodePacked("The address entered is a Presale Member")
    //             );
    //     }
    //     return
    //         string(
    //             abi.encodePacked(
    //                 "The address entered is NOT a VIF or Presale Member"
    //             )
    //         );
    // }

    /// @dev used to see how many vifs and fruity members there are
    function getMemberCount() public view onlyOwner returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "There is/are ",
                    Strings.toString(vifCount),
                    " VIF Member(s). There is/are ",
                    Strings.toString(presaleMemberList.length),
                    " Presale Member(s)."
                )
            );
    }
}

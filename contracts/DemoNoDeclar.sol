// //SPDX-License-Identifier: MIT

// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/utils/Strings.sol";
// import "@openzeppelin/contracts/utils/Context.sol";

// // must be revamped for gas optimization
// import "./tokens/IERC1155MetadataURI.sol";
// import "./tokens/ERC1155.sol";
// import "./utils/Ownable.sol";
// import "./VIF.sol";

// import "hardhat/console.sol";

// contract DemoOptimized is
//     ERC1155,
//     Ownable,
//     ReentrancyGuard,
//     IERC1155MetadataURI,
//     VIF
// {
//     uint256 constant receiptTokenId = 0;
//     uint256 fruitTokenId = 1;
//     uint256 fourInOneTokenId = 100001;

//     uint256 giveawayBundleCount;
//     uint256 bundleSupply = 1000;
//     uint256 receiptSupply = 3000;

//     /// @notice @dev 100000000 gwei
//     uint256 pricePerBundle = 0.1 ether;

//     /// @dev lower params will change with seasons
//     uint256 fruitTokenIdLowerParam;
//     uint256 fourInOneTokenIdLowerParam;
//     uint256 fruitTokenIdUpperParam;
//     uint256 fourInOneTokenIdUpperParam;

//     uint256 presaleStartTime;
//     uint256 saleStartTime;

//     string private _uri;
//     string private _uriPreview;

//     /// @dev this array is used to reset the VIF mapping
//     // address[] veryImportantFruit;

//     /// @dev balance of bundles minted
//     /// @notice this balance will be tracked and reset for every season
//     mapping(address => uint256) private bundleBalance;
//     // mapping(address => uint256) addressToVIF;

//     event IncreaseReceiptSupply(address _sender, uint256 _supply);
//     event IncreaseBundleSupply(address _sender, uint256 _supply);
//     // event SaleHasBeenSet(uint256 _presaleStartTime, uint256 _saleStartTime);
//     event PricePerBundle(address _sender, uint256 _gwei);
//     event ChangeFourInOne(
//         address _sender,
//         uint256 _fourInOneToken,
//         uint256 _fruitTokenId,
//         uint256 _quadrant
//     );

//     constructor(string memory uri1, string memory uriPreview1) ERC1155() {
//         fruitTokenIdLowerParam = 0;
//         fruitTokenIdUpperParam = 99999;
//         fourInOneTokenIdLowerParam = 100001;
//         fourInOneTokenIdUpperParam = 999999;
//         presaleStartTime = 1961257932;
//         _setUri(uri1, uriPreview1);
//     }

//     /// @dev uses block time stamp to start presale and sale
//     /// based on setPresaleStartTime(uint256 _presaleStartTime, uint256 _timeBetweenSales)
//     /// saleTime will be set with _presaleStartTime+_timeBetweenSales
//     modifier isSaleActive() {
//         require(block.timestamp > presaleStartTime, "Presale has not started");
//         if (
//             block.timestamp > presaleStartTime &&
//             block.timestamp < saleStartTime
//         ) {
//             require(
//                 addressToVIF[msg.sender] > 0,
//                 "Presale is active but you're are not a VIF, wait for public sale"
//             );
//         }
//         _;
//     }

//     function mintBundle(uint256 _quantity)
//         external
//         payable
//         isSaleActive
//         nonReentrant
//     {
//         require(
//             msg.value >= 0.1 ether * _quantity,
//             "Not enough ether was sent to transaction"
//         );
//         require(
//             bundleBalance[msg.sender] + _quantity <= 2,
//             "Cannot purchase more than two bundle per sender"
//         );
//         require(bundleSupply - _quantity >= 0, "All Bundles have been minted");

//         uint256[] memory batchMintAmmount = new uint256[](6);
//         uint256[] memory idHolder = new uint256[](6);

//         for (uint256 i = 0; i < _quantity; i++) {
//             batchMintAmmount[0] = 1;
//             batchMintAmmount[1] = 1;
//             batchMintAmmount[2] = 1;
//             batchMintAmmount[3] = 1;
//             batchMintAmmount[4] = 1;
//             batchMintAmmount[5] = 3;

//             idHolder[0] = fruitTokenId;
//             fruitTokenId++;
//             idHolder[1] = fruitTokenId;
//             fruitTokenId++;
//             idHolder[2] = fruitTokenId;
//             fruitTokenId++;
//             idHolder[3] = fruitTokenId;
//             fruitTokenId++;
//             idHolder[4] = fourInOneTokenId;
//             fourInOneTokenId++;
//             idHolder[5] = receiptTokenId;
//             bundleBalance[msg.sender]++;
//             _mintBatch(msg.sender, idHolder, batchMintAmmount, "");

//             bundleSupply--;
//         }
//     }

//     /// @notice This givaway will not impact the minting quantity
//     /// @dev the parameter is an array to mint batches for each address
//     function giveawayBundle(address[] calldata _to) external onlyOwner {
//         require(
//             bundleSupply - _to.length >= 0,
//             "Not enough bundles for giveaways."
//         );

//         uint256[] memory batchMintAmmount = new uint256[](6);
//         batchMintAmmount[0] = 1;
//         batchMintAmmount[1] = 1;
//         batchMintAmmount[2] = 1;
//         batchMintAmmount[3] = 1;
//         batchMintAmmount[4] = 1;
//         batchMintAmmount[5] = 3;

//         uint256[] memory idHolder = new uint256[](6);

//         for (uint256 i = 0; i < _to.length; i++) {
//             idHolder[0] = fruitTokenId;
//             fruitTokenId++;
//             idHolder[1] = fruitTokenId;
//             fruitTokenId++;
//             idHolder[2] = fruitTokenId;
//             fruitTokenId++;
//             idHolder[3] = fruitTokenId;
//             fruitTokenId++;
//             idHolder[4] = fourInOneTokenId;
//             fourInOneTokenId++;
//             idHolder[5] = receiptTokenId;
//             _mintBatch(_to[i], idHolder, batchMintAmmount, "");
//             bundleSupply--;
//         }
//         giveawayBundleCount = giveawayBundleCount + _to.length;
//     }

//     /// @dev the cuteeEchange uses an oracle to contact an outside server
//     /// @notice this will be the exchange of fruit for your four in one
//     function cuteeExchange(
//         uint256 _fruitTokenId,
//         uint256 _fourInOneTokenId,
//         uint256 _quadrant
//     ) public nonReentrant {
//         require(_quadrant < 5, "Quadrant out of range");
//         address operator = _msgSender();
//         address[] memory accounts = new address[](3);
//         uint256[] memory balances = new uint256[](3);
//         uint256[] memory balanceCheck = new uint256[](3);

//         accounts[0] = operator;
//         accounts[1] = operator;
//         accounts[2] = operator;

//         balances[0] = _fruitTokenId;
//         balances[1] = _fourInOneTokenId;
//         balances[2] = receiptTokenId;

//         balanceCheck = balanceOfBatch(accounts, balances);

//         require(balanceCheck[0] > 0, "You do not own the Fruit Token");
//         require(balanceCheck[1] > 0, "You do not own the FourInOne Token");
//         require(balanceCheck[2] > 0, "You do not own a Receipt");

//         // send to oracle

//         // return oracle boolean.

//         // emit event and burn token
//         emit ChangeFourInOne(
//             operator,
//             _fourInOneTokenId,
//             _fruitTokenId,
//             _quadrant
//         );
//         _burn(operator, 0, 1);
//         receiptSupply--;
//     }

//     ///@dev the receipt supply will increase every season 3000 per season
//     // function increaseReceiptSupply(uint256 _supply) public onlyOwner {
//     //     receiptSupply = receiptSupply + _supply;
//     //     emit IncreaseReceiptSupply(msg.sender, _supply);
//     // }

//     /// @dev bundleSupply will be set for every season
//     // function setBundleSupply(uint256 _bundleSupply) public onlyOwner {
//     //     bundleSupply = _bundleSupply;
//     //     emit IncreaseBundleSupply(msg.sender, _bundleSupply);
//     // }
//     /// @dev sets necessary params to conclude our post season
//     function setSeason() external onlyOwner {
//         bundleSupply = bundleSupply + 1000;
//         receiptSupply = receiptSupply + 3000;
//         // @dev this is set 40 years from Feb 24th, 2022
//         presaleStartTime = 7845031728;
//         emit IncreaseBundleSupply(msg.sender, 1000);
//         emit IncreaseReceiptSupply(msg.sender, 3000);
//     }

//     function getReceiptSupply() public view returns (uint256) {
//         return receiptSupply;
//     }

//     function getBundleSupply() public view returns (uint256) {
//         return bundleSupply;
//     }

//     function getBalance() public view returns (uint256) {
//         return address(this).balance;
//     }

//     function withdrawBalance() external onlyOwner {
//         require(address(this).balance > 0, "No ether in contract");
//         payable(msg.sender).transfer(address(this).balance);
//     }

//     // ------------------------- //
//     /// @dev uri section       ///
//     // ------------------------- //

//     /// @dev to reveal the current season Pictures must change the lower params
//     function setSeasonLowerParams(
//         uint256 _fruitTokenIdLowerParam,
//         uint256 _fourInOneTokenIdLowerParam
//     ) public onlyOwner {
//         fruitTokenIdLowerParam = _fruitTokenIdLowerParam;
//         fourInOneTokenIdLowerParam = _fourInOneTokenIdLowerParam;
//     }

//     function uri(uint256 _tokenId)
//         public
//         view
//         virtual
//         override
//         returns (string memory)
//     {
//         if (
//             (_tokenId > fruitTokenIdLowerParam &&
//                 _tokenId < fruitTokenIdUpperParam) ||
//             (_tokenId > fourInOneTokenIdLowerParam &&
//                 _tokenId < fourInOneTokenIdUpperParam)
//         ) {
//             return _uriPreview;
//         } else {
//             return
//                 string(
//                     abi.encodePacked(_uri, Strings.toString(_tokenId), ".json")
//                 );
//         }
//     }

//     /// @dev change uri incase we have any technical error. LikelyHood: VeryUnlikely
//     // function setUri(string memory uriSetter, string memory uriPreviewSetter)
//     //     public
//     //     onlyOwner
//     // {
//     //     _uri = uriSetter;
//     //     _uriPreview = uriPreviewSetter;
//     // }

//     function _setUri(string memory uriSetter, string memory uriPreviewSetter)
//         internal
//         virtual
//     {
//         _uri = uriSetter;
//         _uriPreview = uriPreviewSetter;
//     }

//     // ------------------------- //
//     /// @dev sale section       ///
//     // ------------------------- //

//     /// @dev sale start time will set x ammount of time after presale start time.
//     /// Leads to less dynamics. Can set time and use modifier to start the sale.
//     /// Sale ends when all bundles are sold.
//     /// @param _presaleStartTime argument must be set in seconds
//     /// @param _timeBetweenSales argument must be set in seconds
//     /// @dev can define the entirety of our season sale in this one function call?
//     // function setSaleTimeAndBundleSupply
//     function setPresaleStartTime(
//         uint256 _presaleStartTime,
//         uint256 _timeBetweenSales
//     ) public onlyOwner {
//         presaleStartTime = _presaleStartTime;
//         saleStartTime = _presaleStartTime + _timeBetweenSales;
//         // emit SaleHasBeenSet(presaleStartTime, saleStartTime);
//     }

//     function setPricePerBundle(uint256 _gwei) public onlyOwner {
//         pricePerBundle = _gwei;
//         emit PricePerBundle(msg.sender, _gwei);
//     }

//     function getPricePerBundle() public view returns (uint256) {
//         return pricePerBundle;
//     }

// //     // ------------------------- //
// //     /// @dev VIF section       ///
// //     // ------------------------- //

// //     function setVIFMember(address[] memory _vifs) public onlyOwner {
// //         for (uint256 i = 0; i < _vifs.length; i++) {
// //             if (addressToVIF[_vifs[i]] == 1) {
// //                 continue;
// //             } else {
// //                 addressToVIF[_vifs[i]] = 1;
// //                 veryImportantFruit.push(_vifs[i]);
// //             }
// //         }
// //     }

// //     /// @dev all vif members will be reset at the end of every sale
// //     /// We will start fresh before every mint
// //     function resetVIF() public onlyOwner {
// //         for (uint256 i = 0; i < veryImportantFruit.length; i++) {
// //             addressToVIF[veryImportantFruit[i]] = 0;
// //         }
// //         delete veryImportantFruit;
// //     }

// //     /// @dev can be used to get a vifMember
// //     /// @notice if the address you entered returns with 1 it has been VIFed
// //     function getVIFMember(address _address)
// //         public
// //         view
// //         returns (address, string memory)
// //     {
// //         return (
// //             _address,
// //             string(abi.encodePacked(Strings.toString(addressToVIF[_address])))
// //         );
// //     }

// //     /// @dev used to see how many vifs we have given out
// //     function getVIFCount() public view onlyOwner returns (string memory) {
// //         return
// //             string(
// //                 abi.encodePacked(Strings.toString(veryImportantFruit.length))
// //             );
// //     }
// // }

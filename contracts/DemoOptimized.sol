//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

// must be revamped for gas optimization
import "./tokens/IERC1155MetadataURI.sol";
import "./tokens/ERC1155.sol";
import "./utils/Ownable.sol";

import "hardhat/console.sol";

contract DemoOptimized is
    ERC1155,
    Ownable,
    ReentrancyGuard,
    IERC1155MetadataURI
{
    using Strings for uint256;

    uint256 constant receiptTokenId = 0;
    uint256 fruitTokenId = 1;
    uint256 fourInOneTokenId = 100001;

    uint256 bundleSupply;
    uint256 receiptSupply;

    /// @notice @dev 100000000 gwei
    uint256 pricePerBundle = 0.1 ether;

    // @dev merkleRoots for members
    bytes32 merkleRoot;
    // NOTE make these booleans and create an api that interacts with them
    // this method might be safer to do.
    uint256 vifSaleStartTime;
    uint256 presaleStartTime;
    uint256 publicSaleStartTime;
    bool vifSaleIsActive = false;
    bool fruitiesSaleIsActive = false;
    bool publicSaleIsActive = false;

    string private _uri;

    uint256 public presaleMintCount;
    uint256 public vifMintCount;

    address[] public mintersList;

    mapping(address => uint256) private bundleBalance;
    mapping(address => uint256) public addressToMintPass;

    event IncreaseReceiptSupply(address _sender, uint256 _supply);

    constructor(string memory uri1) ERC1155() {
        _setUri(uri1);
        vifMintCount = 100;
        presaleMintCount = 345;
        receiptSupply = 3000;
        bundleSupply = 1000;
    }

    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function _verifyMerkle(bytes32[] memory _merkleProof, uint256 _maxAmount)
        internal
        view
        returns (bool)
    {
        address sender = _msgSender();

        bytes32 leaf = keccak256(abi.encode(sender, _maxAmount.toString()));

        return MerkleProof.verify(_merkleProof, merkleRoot, leaf);
    }

    // ---------------- //
    // ----- MINT ----- //
    // ---------------- //

    /*
        @dev uses block time stamp to start presale and sale
        based on setPresaleStartTime(uint256 _presaleStartTime, uint256 _timeBetweenSales)
        saleTime will be set with _presaleStartTime+_timeBetweenSales
    */

    // bool vifSaleIsActive;
    // bool fruitiesSaleIsActive;
    // bool publicSaleIsActive;

    //TODO set merkleTreeRoot
    modifier isSaleActive(bytes32[] memory _merklyProof, uint256 _maxAmount) {
        // TODO logic in timing and verifying merkle tree
        address sender = _msgSender();
        if (vifSaleIsActive && _verifyMerkle(_merkleProof, 30)) {
            require(
                bundleBalance[sender] < 1,
                "You have bought the max amount of fruit baskets for the VIF sale. Wait until Fruity sale to purchase more."
            );
        }
        if (fruitiesSaleIsActive && _verifyMerkle(_merkleProof, _maxAmount)) {
            if (_maxAmount == 30) {
                require(
                    bundleBalance[sender] < 2,
                    "You have bought the max amount of fruit baskets as a VIF member. Wait until public sale to purchase more."
                );
            }
        }
        if (_maxAmount == 20) {
            require(
                bundleBalance[sender] < 1,
                "You have bought the max amount of fruit baskets as a Fruity Member. Wait until public sale."
            );
        }
        if (publicSaleIsActive) {
            if (_maxAmount == 30 && _verifyMerkle(_merkleProof, _maxAmount)) {
                require(
                    bundleBalance[sender] < 3,
                    "You have bought the max amount of fruit baskets as a VIF member."
                );
            } else if (
                _maxAmount == 20 && _verifyMerkle(_merkleProof, _maxAmount)
            ) {
                require(
                    bundleBalance[sender] < 2,
                    "You have bought the max amount of fruit baskets as a Fruity Member."
                );
            } else {
                require(
                    bundleBalance[sender] < 1,
                    "Only allowed one purchase of a fruitbasket during presale"
                );
            }
        }
        _;
    }

    function setVifSale() public onlyOwner {
        vifSaleIsActive = !vifSaleIsActive;
    }

    function setFruitieSale() public onlyOwner {
        fruitiesSaleIsActive = !fruitiesSaleIsActive;
    }

    function setPublicSale() public onlyOwner {
        publicSaleIsActive = !publicSaleIsActive;
    }

    /**
        @dev primary mint for all mints
     */
    function mintBundle()
        public
        payable
        isSaleActive(_merkleProof, _maxAmount)
        nonReentrant
    {
        address sender = _msgSender();

        // I have to activate and reactivate sales. When VIF ends
        // set it false and set fruities sale to true
        // When fruity sale ends set fruity to false and activate
        // public sale

        require(
            msg.value >= 0.1 ether,
            "Not enough ether was sent to purchase your fruit basket."
        );
        require(bundleSupply > 0, "All Bundles have been minted.");

        address recipient = _msgSender();

        _mintBundle(recipient);

        if (bundleBalance[recipient] < 1) {
            mintersList.push(recipient);
        }

        bundleBalance[recipient]++;
    }

    /*
        @dev mintpassGiveaway will allow the user to mint before anysales
        @notice the mintPass can be used for any of our mints if and only if
        There are any bundles left
    */
    function useMintPass() public {
        require(bundleSupply > 0, "All bundles have been minted.");
        require(
            addressToMintPass[msg.sender] > 0,
            "You do not have a free mint"
        );

        address recipient = _msgSender();

        addressToMintPass[recipient]--;

        _mintBundle(recipient);
    }

    function mintPassGiveaway(address[] calldata _giveaways) public onlyOwner {
        for (uint256 i = 0; i < _giveaways.length; i++) {
            addressToMintPass[_giveaways[i]]++;
        }
    }

    function getMintPassCount(address _recipient)
        public
        view
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    Strings.toString(addressToMintPass[_recipient])
                )
            );
    }

    /**
        @dev _mintBundle is used for giveaways and sale mints
    */

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

        _mintBatch(_to, idHolder, batchMintAmmount, "");

        bundleSupply--;
    }

    // ---------------- //
    // ---- SEASON ---- //
    // ---------------- //

    /*
        @dev sets necessary params
        These things must be done
        Set Bundle Supply to 1000 only if and only if bundle supply is at 0
        increase the receipt supply by 3000
        reset the presale members for past season
        emit event to document increase in reeipts(burn currency)
    */

    function setSeason(uint256 _vifMintAmount, uint256 _presaleMintAmount)
        public
        onlyOwner
    {
        require(
            bundleSupply <= 0,
            "All bundles have not been given away or sold"
        );

        bundleSupply = 1000;
        receiptSupply = receiptSupply + 3000;

        vifMintCount = _vifMintAmount;
        presaleMintCount = _presaleMintAmount;

        _resetBundleBalances();

        emit IncreaseReceiptSupply(msg.sender, 3000);
    }

    function _resetBundleBalances() internal {
        for (uint256 i = 0; i < mintersList.length; i++) {
            bundleBalance[mintersList[i]] = 0;
        }
        delete mintersList;
    }

    // ---------------- //
    // ----- SALE ----- //
    // ---------------- //

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

    function setPricePerBundle(uint256 _gwei) public onlyOwner {
        pricePerBundle = _gwei;
    }

    function getPricePerBundle() public view returns (uint256) {
        return pricePerBundle;
    }

    function withdrawBalance() external onlyOwner {
        require(address(this).balance > 0, "No ether in contract");
        payable(msg.sender).transfer(address(this).balance);
    }

    // ---------------- //
    // ----- URI ------ //
    // ---------------- //

    /// @dev uri will point to a dns all all data is stored on the ipfs
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

    function _setUri(string memory uriSetter) internal virtual {
        _uri = uriSetter;
    }
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

// must be revamped for gas optimization
import "./tokens/IERC1155MetadataURI.sol";
import "./tokens/ERC1155.sol";
import "./utils/Ownable.sol";

import "hardhat/console.sol";

contract CuteeFruitee is
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

    // @dev modifier to check sale activation and member status
    modifier isSaleActive(bytes32[] memory _merkleProof, uint256 _maxAmount) {
        require(
            vifSaleIsActive || fruitiesSaleIsActive || publicSaleIsActive,
            "Sales have not started yet."
        );
        address sender = _msgSender();
        if (vifSaleIsActive) {
            require(vifMintCount > 0, "Out of VIF Mints");
            if (_verifyMerkle(_merkleProof, 30)) {
                require(
                    bundleBalance[sender] < 1,
                    "You have bought the max amount of fruit baskets for the VIF sale. Wait until Fruity sale to purchase more."
                );
                vifMintCount--;
            } else {
                require(false, "You are not a VIF member.");
            }
        }
        if (fruitiesSaleIsActive) {
            require(presaleMintCount > 0, "Presale Mint Has Concluded");
            if (_verifyMerkle(_merkleProof, _maxAmount)) {
                if (_maxAmount == 30) {
                    require(
                        bundleBalance[sender] < 2,
                        "You have bought the max amount of fruit baskets as a VIF member. Wait until public sale to purchase more."
                    );
                }

                if (_maxAmount == 20) {
                    require(
                        bundleBalance[sender] < 1,
                        "You have bought the max amount of fruit baskets as a Fruity Member. Wait until public sale."
                    );
                }
                presaleMintCount--;
            } else {
                require(
                    false,
                    "You are not a Presale or VIF member. Wait until public sale."
                );
            }
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
                    "Only allowed one purchase of a fruitbasket during public sale."
                );
            }
        }
        _;
    }

    /**
        @dev primary mint for all mints
     */
    function mintBundle(bytes32[] memory _merkleProof, uint256 _maxAmount)
        public
        payable
        isSaleActive(_merkleProof, _maxAmount)
        nonReentrant
    {
        require(
            msg.value >= 0.1 ether,
            "Not enough ether was sent to purchase your fruit basket."
        );
        require(bundleSupply > 0, "All Bundles have been minted.");

        address sender = _msgSender();

        _mintBundle(sender);

        if (bundleBalance[sender] < 1) {
            mintersList.push(sender);
        }

        bundleBalance[sender]++;
    }

    /*
        @dev mintpassGiveaway will allow the user to mint before anysales
        @notice the mintPass can be used for any of our mints if and only if
        There are any bundles left
    */
    function useMintPass() public {
        require(bundleSupply > 0, "All bundles have been minted.");

        address sender = _msgSender();

        require(addressToMintPass[sender] > 0, "You do not have a free mint.");

        addressToMintPass[sender]--;

        _mintBundle(sender);
    }

    function mintPassGiveaway(address[] calldata _giveaways) public onlyOwner {
        for (uint256 i = 0; i < _giveaways.length; i++) {
            addressToMintPass[_giveaways[i]]++;
        }
    }

    function getMintPassCount(address _recipient)
        public
        view
        returns (uint256)
    {
        return addressToMintPass[_recipient];
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
        // require(
        //     bundleSupply <= 0,
        //     "All bundles have not been given away or sold"
        // );

        bundleSupply = 1000;
        receiptSupply = receiptSupply + 3000;

        vifMintCount = _vifMintAmount;
        presaleMintCount = _presaleMintAmount;

        _resetBundleBalances();

        emit IncreaseReceiptSupply(msg.sender, 3000);
    }

    /// NOTE planning on sending in a list
    /// NOTE how expensive will this be?
    /// NOTE Can i compute do this in one block??
    function _resetBundleBalances() internal {
        for (uint256 i = 0; i < mintersList.length; i++) {
            bundleBalance[mintersList[i]] = 0;
        }
        delete mintersList;
    }

    // ---------------- //
    // ----- SALE ----- //
    // ---------------- //

    function setVifSale() public onlyOwner {
        vifSaleIsActive = !vifSaleIsActive;
    }

    function setFruitySale() public onlyOwner {
        fruitiesSaleIsActive = !fruitiesSaleIsActive;
    }

    function setPublicSale() public onlyOwner {
        publicSaleIsActive = !publicSaleIsActive;
    }

    function setPricePerBundle(uint256 _gwei) public onlyOwner {
        pricePerBundle = _gwei;
    }

    function receiptTotalSupply() public view returns (uint256) {
        return receiptSupply;
    }

    function bundleTotalSupply() public view returns (uint256) {
        return bundleSupply;
    }

    function getPricePerBundle() public view returns (uint256) {
        return pricePerBundle;
    }

    function getVifMintCount() public view returns (uint256) {
        return vifMintCount;
    }

    function getPresaleMintCount() public view returns (uint256) {
        return presaleMintCount;
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

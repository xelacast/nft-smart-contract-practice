pragma solidity ^0.8.9;

contract MintMapping {
    mapping(string => uint256) bundleBalance;
    string[] mintersList;

    function addToList(string[] memory _addressList) public {
        for (uint256 i = 0; i < 250; i++) {
            bundleBalance[_addressList[i]] = 1;
            mintersList.push(_addressList[i]);
        }
    }

    function removeBalances(string[] memory _addressList) public {
        for (uint256 i = 0; i < 1000; i++) {
            bundleBalance[_addressList[i]] = 0;
        }

        delete mintersList;
    }
}

// //SPDX-License-Identifier: MIT

// pragma solidity ^0.8.0;

// import "./utils/Ownable.sol";

// contract VIF is Ownable {
//     mapping(address => uint256) addressToVIF;
//     address[] veryImportantFruit;

//     // ------------------------- //
//     /// @dev VIF section       ///
//     // ------------------------- //

//     function setVIFMember(address[] memory _vifs) public onlyOwner {
//         for (uint256 i = 0; i < _vifs.length; i++) {
//             if (addressToVIF[_vifs[i]] == 1) {
//                 continue;
//             } else {
//                 addressToVIF[_vifs[i]] = 1;
//                 veryImportantFruit.push(_vifs[i]);
//             }
//         }
//     }

//     /// @dev all vif members will be reset at the end of every sale
//     /// We will start fresh before every mint
//     function resetVIF() public onlyOwner {
//         for (uint256 i = 0; i < veryImportantFruit.length; i++) {
//             addressToVIF[veryImportantFruit[i]] = 0;
//         }
//         delete veryImportantFruit;
//     }

//     /// @dev can be used to get a vifMember
//     /// @notice if the address you entered returns with 1 it has been VIFed
//     function getVIFMember(address _address)
//         public
//         view
//         returns (address, string memory)
//     {
//         return (
//             _address,
//             string(abi.encodePacked(Strings.toString(addressToVIF[_address])))
//         );
//     }

//     /// @dev used to see how many vifs we have given out
//     function getVIFCount() public view onlyOwner returns (string memory) {
//         return
//             string(
//                 abi.encodePacked(Strings.toString(veryImportantFruit.length))
//             );
//     }
// }

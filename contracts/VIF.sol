// //SPDX-License-Identifier: MIT

// pragma solidity ^0.8.0;

// import "./utils/Ownable.sol";

// contract VIF is Ownable {
//     mapping(address => uint256) addressToVIF;
//     address[] veryImportantFruit;
//     uint256 VIFCount = 500;

//     // this is an expensive task to run
//     function setVIF(address[] memory _vifs) public onlyOwner {
//         require(VIFCount >= _vifs.length, "Not Enough VIF spots left");
//         for (uint256 i = 0; i < _vifs.length; i++) {
//             addressToVIF[_vifs[i]] = 1;
//             veryImportantFruit.push(_vifs[i]);
//             // console.log(addressToVIF[_VIFs[i]]);
//         }
//         VIFCount = VIFCount - _vifs.length;
//     }

//     function resetVIF(uint256 _VIFCount) public onlyOwner {
//         for (uint256 i = 0; i < veryImportantFruit.length; i++) {
//             addressToVIF[veryImportantFruit[i]] = 0;
//         }
//         delete veryImportantFruit;
//         VIFCount = _VIFCount;
//     }

//     function getVIF(address _address) public view onlyOwner returns (uint256) {
//         return addressToVIF[_address];
//     }

//     function getVIFLeft() public view onlyOwner returns (uint256) {
//         return VIFCount;
//     }
// }

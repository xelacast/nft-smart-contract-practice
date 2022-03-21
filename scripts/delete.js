const hre = require('hardhat');
const { keccak256 } = require('ethers/lib/utils');

async function main() {
  let start = "0x";
  let word1 = "abcde";
  let word2 = "ghijkl";
  let letters = "abcdefghijklmnopqrstuvwxyz";
  let nums = "123456";
  let length = 6;
  let addressList = [];


  for (let j = 0; j < letters.length; j++){
    let letter1 = letters[j];
    for (let k = 0; k < letters.length; k++) {
      let letter2 = letters[k];
      for (let l = 0; l < 2; l++) {
        let letter3 = letters[l];
        // for (let m = 0; m < nums.length; m++) {
        //   let num3 = letters[m];
          addressList.push(letter1 + letter2 + letter3)
        // }
      }
    }
  }

  // console.log(addressList.splice(0, 250).length)
  // console.log(addressList.splice(250, 250).length)
  // console.log(addressList.splice(500, 250).length)
  // console.log(addressList.splice(-250).length)
  // let array = new ;
  let array1 = addressList.slice(0,250);
  let array2 = addressList.slice(250,500);
  let array3 = addressList.slice(500,750);
  let array4 = addressList.slice(-250);
  console.log(array1.length)
  console.log(array2.length)
  console.log(array3.length)
  console.log(array4.length)

  console.log(addressList.length)
  const Contract = await hre.ethers.getContractFactory("MintMapping");
  const contract = await Contract.deploy();

  const [owner] = await ethers.getSigners();

  await contract.addToList(array1);
  await contract.addToList(array2);
  await contract.addToList(array3);
  await contract.addToList(array4);

  await contract.removeBalances(addressList);


}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.log(error);
    process.exit(1)
  })
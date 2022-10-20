const hre = require('hardhat');

async function main() {
    const API3QRNG = await hre.deployments.get('API3QRNG');
    const qrngExample = await hre.ethers.Contract(API3QRNG.address, API3QRNG.abi, (await hre.ethers.getSigners())[0]);

    //Make Request for Randomness and mint NFT
    const receipt = await qrngExample.requestNewRandomCharacter();
    console.log('Created a request transaction, waiting for it to be confirmed...');
    // and read the logs once it gets confirmed to get the request ID

}
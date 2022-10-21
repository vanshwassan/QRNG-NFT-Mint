const hre = require('hardhat');

async function main() {
    const API3QRNG = await hre.deployments.get('API3QRNG');
    const qrngExample = new hre.ethers.Contract(API3QRNG.address, API3QRNG.abi, (await hre.ethers.getSigners())[0]);

    //Make Request for Randomness and mint NFT
    const receipt = await qrngExample.requestNewRandomCharacter("NFTCharacter");
    console.log('Created a request transaction, waiting for it to be confirmed...');
  // and read the logs once it gets confirmed to get the request ID
  const requestId = await new Promise((resolve) =>
    hre.ethers.provider.once(receipt.hash, (tx) => {
      // We want the log from API3QRNG, not AirnodeRrp
      const log = tx.logs.find((log) => log.address === qrngExample.address);
      const parsedLog = qrngExample.interface.parseLog(log);
      resolve(parsedLog.args.requestId);
    })
  );
  console.log(`Transaction is confirmed, request ID is ${requestId}`);

  // Wait for the fulfillment transaction to be confirmed and mint the NFT
  console.log('Waiting for the fulfillment transaction...');
  const log = await new Promise((resolve) =>
    hre.ethers.provider.once(qrngExample.filters.ReceivedUint256(requestId, null), resolve)
  );
  const parsedLog = qrngExample.interface.parseLog(log);
  const randomNumber = parsedLog.args.response;
  const txhash = log.transactionHash;
  console.log(`Fulfillment is confirmed, your NFT is minted ${txhash.toString()}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
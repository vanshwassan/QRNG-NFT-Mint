const hre = require('hardhat');
const airnodeProtocol = require('@api3/airnode-protocol');

module.exports = async () => {
  // https://docs.api3.org/airnode/latest/reference/airnode-addresses.html
  const airnodeRrpAddress = airnodeProtocol.AirnodeRrpAddresses[await hre.getChainId()];

  const API3QRNG = await hre.deployments.deploy('API3QRNG', {
    args: [airnodeRrpAddress],
    from: (await getUnnamedAccounts())[0],
    log: true,
  });
  console.log(`Deployed API3QRNG at ${API3QRNG.address}`);
};
module.exports.tags = ['deploy'];
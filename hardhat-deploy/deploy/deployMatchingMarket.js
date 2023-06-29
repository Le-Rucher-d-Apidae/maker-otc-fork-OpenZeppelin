const params = require("../deploy-params/RestrictedSuspendableMatchingMarket-params")

const contractName = params.contractName;
const log = params.log;
const args = params.args;

module.exports = async (
  {
  getNamedAccounts,
  deployments,
  getChainId,
  getUnnamedAccounts,
}) => {
  const {deploy, getNetworkName} = deployments;
  getChainId().then( (chainId) => {
    console.log( `Deploying ${contractName} on network ${getNetworkName()} (chainId:${chainId})  with args:` );
    console.dir( args );
    console.log( "TODO" );
    console.log( "TODO" );
    console.log( "TODO" );
    console.log( "TODO" );
  });
/*
  const {deployer} = await getNamedAccounts();
  // the following will only deploy "{contractName}" if the contract was never deployed or if the code changed since last deployment
  const deployResult = await deploy(
    contractName,
    {
      from: deployer,
      gasLimit: 4000000,
      args: args,
      log: log,
    }
  );

  if (deployResult.newlyDeployed) {
    console.log(
      `${contractName} deployed at ${deployResult.address} using ${deployResult.receipt.gasUsed} gas`
    );
  }
*/

};

module.exports.tags = ['MatchingMarket'];
module.exports.dependencies = ['Oracle'];
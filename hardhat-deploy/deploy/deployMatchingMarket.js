const { getContractName, getDeployArgs, getParamsArgs } = require("../deploy-tools/deployFn")

const matchingMarket_params = require("../deploy-params/MatchingMarket-params")
const token_params = require("../deploy-params/ApidaeToken-params")
// const uniswapV3Oracle_params = require("../deploy-params/UniswapV3Oracle-params")

const matchingMarketConfiguration_params = require("../deploy-params/MatchingMarketConfiguration-params")


module.exports = async (
  {
  getNamedAccounts,
  deployments,
  getChainId,
  getUnnamedAccounts,
}) => {
  const {deploy, getNetworkName} = deployments;
  const chainId = await getChainId();
  const networkName = getNetworkName()
  const {deployer} = await getNamedAccounts();

  const matchingMarket_contractName = getContractName(matchingMarket_params);
  // const matchingMarket_paramsArgs = getParamsArgs(matchingMarket_params, chainId); // empty
  const matchingMarket_deployArgs = getDeployArgs(matchingMarket_params, chainId);

  const matchingMarketConfiguration_contractName = matchingMarketConfiguration_params.contractName;
  const matchingMarketConfiguration_deployment = await deployments.get(matchingMarketConfiguration_contractName);
  const matchingMarketConfiguration_address = matchingMarketConfiguration_deployment.address;

  const matchingMarket_allParamsArgs = [ 
    matchingMarketConfiguration_address // matchingMarketConfiguration address
   ];

  console.log();
  console.log( `Deploying ${matchingMarket_contractName} on network ${networkName} (chainId:${chainId})  with args:` );
  const argsArrayLogs = { matchingMarketConfigurationAddress: matchingMarketConfiguration_address };
  console.dir( argsArrayLogs );

  console.log( `deployArgs:` );
  console.dir( matchingMarket_deployArgs );

  // the following will only deploy "{contractName}" if the contract was never deployed or if the code changed since last deployment

  const deployResult = await deploy(
    matchingMarket_contractName,
    {
      from: deployer,
      gasLimit: 4000000,
      args: matchingMarket_allParamsArgs,
      deployArgs: matchingMarket_deployArgs,
    }
  );

  if (deployResult.newlyDeployed) {
    console.log(
      `${matchingMarket_contractName} deployed at ${deployResult.address} using ${deployResult.receipt.gasUsed} gas`
    );
  } else {
    console.log(
      `${matchingMarket_contractName} deployment skipped with no changes`
    );
  }

};

module.exports.tags = ['MatchingMarket'];
module.exports.dependencies = [ 'Token', 'Oracle', 'MatchingMarketConfiguration'];
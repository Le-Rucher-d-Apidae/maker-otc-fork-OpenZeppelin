const { getContractName, getDeployArgs, getParamsArgs } = require("../deploy-tools/deployFn")

const matchingMarketConfiguration_params = require("../deploy-params/MatchingMarketConfiguration-params.js")
// const token_params = require("../deploy-params/ApidaeToken-params")
const uniswapV3Oracle_params = require("../deploy-params/UniswapV3Oracle-params")

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

  const matchingMarketConfiguration_contractName = getContractName(matchingMarketConfiguration_params);
  const uniswapV3Oracle_contractName = uniswapV3Oracle_params.contractName;
  
  const oracle_deployment = await deployments.get(uniswapV3Oracle_contractName);
  const oracle_address = oracle_deployment.address;

  const matchingMarket_paramsArgs = getParamsArgs(matchingMarketConfiguration_params, chainId);
  const dustLimit = matchingMarket_paramsArgs[1];

console.debug( `dustLimit: ${dustLimit}` );


  const oracle_args_token_address = oracle_deployment.args[1];
console.debug(`oracle_args_token_address: ${oracle_args_token_address} `);

  const dustToken = oracle_args_token_address;

  const matchingMarketConfiguration_allParamsArgs = [ 
    dustToken, // dustToken address
    dustLimit, // dustLimit
    oracle_address // oracle address
   ];
  const matchingMarketConfiguration_deployArgs = getDeployArgs(matchingMarketConfiguration_params, chainId);
  console.log();
  console.log( `Deploying ${matchingMarketConfiguration_contractName} on network ${networkName} (chainId:${chainId})  with args:` );
  const argsArrayLogs = { dustToken_address: dustToken, dust_limit: dustLimit, oracle_address: oracle_address };
  console.dir( argsArrayLogs );

  console.log( `deployArgs:` );
  console.dir( matchingMarketConfiguration_deployArgs );

  // the following will only deploy "{contractName}" if the contract was never deployed or if the code changed since last deployment

  const deployResult = await deploy(
    matchingMarketConfiguration_contractName,
    {
      from: deployer,
      gasLimit: 4000000,
      args: matchingMarketConfiguration_allParamsArgs,
      deployArgs: matchingMarketConfiguration_deployArgs,
    }
  );

  if (deployResult.newlyDeployed) {
    console.log(
      `${matchingMarketConfiguration_contractName} deployed at ${deployResult.address} using ${deployResult.receipt.gasUsed} gas`
    );
  } else {
    console.log(
      `${matchingMarketConfiguration_contractName} deployment skipped with no changes`
    );
  }

};

module.exports.tags = ['MatchingMarketConfiguration'];
module.exports.dependencies = [ 'Token', 'Oracle'];
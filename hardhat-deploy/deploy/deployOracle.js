const { getContractName, getDeployArgs, getParamsArgs } = require("../deploy-tools/deployFn")

const token_params = require("../deploy-params/ApidaeToken-params")
const oracle_params = require("../deploy-params/UniswapV3Oracle-params")

const oracle_contractName = getContractName(oracle_params);

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

  const oracle_paramsArgs = getParamsArgs(oracle_params, chainId);
  const oracle_deployArgs = getDeployArgs(oracle_params, chainId);

  const token_contractName = getContractName(token_params);
  const token_deployment = await deployments.get(token_contractName);
  const token_address = token_deployment.address
  const mainTradableToken = token_address;

  const uniswapV3Factory_addr = oracle_paramsArgs[0];
  const matchingMarket_allParamsArgs = [ uniswapV3Factory_addr, mainTradableToken ];

  console.log();
  console.log( `Deploying ${oracle_contractName} on network ${networkName} (chainId:${chainId})  with args:` );
  const oracle_argsArrayLogs = { uniswapV3FactoryAddress: matchingMarket_allParamsArgs[0], tokenAddress: matchingMarket_allParamsArgs[1] };
  console.dir( oracle_argsArrayLogs );

  console.log( `deployArgs:` );
  console.dir( oracle_deployArgs );

  // the following will only deploy "{contractName}" if the contract was never deployed or if the code changed since last deployment
  const deployResult = await deploy(
    oracle_contractName,
    {
      from: deployer,
      gasLimit: 4000000,
      args: matchingMarket_allParamsArgs,
      deployArgs: oracle_deployArgs,
    }
  );

  if (deployResult.newlyDeployed) {
    console.log(
      `${oracle_contractName} deployed at ${deployResult.address} using ${deployResult.receipt.gasUsed} gas`
    );
  } else {
    console.log(
      `${oracle_contractName} deployment skipped with no changes`
    );
  }

};

module.exports.tags = ['Oracle'];
module.exports.dependencies = ['Token'];
const { getContractName, getDeployArgs, getParamsArgs } = require("../deploy-tools/deployFn")

const token_params = require("../deploy-params/ApidaeToken-params")

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

  const token_contractName = getContractName(token_params);
  const token_paramsArgs = getParamsArgs(token_params, chainId);
  const token_deployArgs = getDeployArgs(token_params, chainId);
  console.log();
  console.log( `Deploying ${token_contractName} on network ${networkName} (chainId:${chainId})  with args:` );
  const token_argsArrayLogs = { tokenName: token_paramsArgs[0], tokenSymbol: token_paramsArgs[1], tokenSupply: token_paramsArgs[2] };
  console.dir( token_argsArrayLogs );

  console.log( `deployArgs:` );
  console.dir( token_deployArgs );

  // the following will only deploy "{contractName}" if the contract was never deployed or if the code changed since last deployment
  const deployResult = await deploy(
    token_contractName,
    {
      from: deployer,
      gasLimit: 4000000,
      args: token_paramsArgs,
      deployArgs: token_deployArgs,
    }
  );

  if (deployResult.newlyDeployed) {
    console.log(
      `${token_contractName} deployed at ${deployResult.address} using ${deployResult.receipt.gasUsed} gas`
    );
  } else {
    console.log(
      `${token_contractName} deployment skipped with no changes`
    );
  }


};

module.exports.tags = ['Token'];
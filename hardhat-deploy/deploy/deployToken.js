const { getContractName, getDeployArgs, getParamsArgs } = require("./deployFn")

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

  const contractName = getContractName(token_params);
  const args = getParamsArgs(token_params, chainId);
  const deployArgs = getDeployArgs(token_params, chainId);
  console.log( `Deploying ${contractName} on network ${networkName} (chainId:${chainId})  with args:` );
  const argsArrayLogs = { tokenName: args[0], tokenSymbol: args[1], tokenSupply: args[2] };
  console.dir( argsArrayLogs );

  console.log( `deployArgs:` );
  console.dir( deployArgs );

  // the following will only deploy "{contractName}" if the contract was never deployed or if the code changed since last deployment
  const deployResult = await deploy(
    contractName,
    {
      from: deployer,
      gasLimit: 4000000,
      args: args,
      deployArgs,
    }
  );

  if (deployResult.newlyDeployed) {
    console.log(
      `${contractName} deployed at ${deployResult.address} using ${deployResult.receipt.gasUsed} gas`
    );
  }


};

module.exports.tags = ['Token'];
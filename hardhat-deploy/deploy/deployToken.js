
const params = require("../deploy-params/ApidaeToken-params")

const contractName = params.contractName;
const log = params.log;

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


  const getParamsArgs = (chainId) => {
      return params.args[chainId];
  };

  const args = getParamsArgs(chainId);
  console.log( `Deploying ${contractName} on network ${networkName} (chainId:${chainId})  with args:` );
  const argsArrayLogs = { tokenName: args[0], tokenSymbol: args[1], tokenSupply: args[2] };
  console.dir( argsArrayLogs );

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


};

module.exports.tags = ['Token'];
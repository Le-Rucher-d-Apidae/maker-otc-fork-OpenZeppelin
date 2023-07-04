
const oracle_params = require("../deploy-params/UniswapV3Oracle-params")

const oracle_contractName = oracle_params.contractName;
const oracle_log = oracle_params.log;

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

  const getArgs = (chainId) => {
      return oracle_params.args[chainId];
  };

  const args = getArgs(chainId);
  console.log( `Deploying ${oracle_contractName} on network ${networkName} (chainId:${chainId})  with args:` );
  const argsArrayLogs = { uniswapV3FactoryAddress: args[0], tokenAddress: args[1] };
  console.dir( argsArrayLogs );


  // the following will only deploy "{contractName}" if the contract was never deployed or if the code changed since last deployment
  const deployResult = await deploy(
    oracle_contractName,
    {
      from: deployer,
      gasLimit: 4000000,
      args: args,
      log: oracle_log,
    }
  );

  if (deployResult.newlyDeployed) {
    console.log(
      `${oracle_contractName} deployed at ${deployResult.address} using ${deployResult.receipt.gasUsed} gas`
    );
  }


};

module.exports.tags = ['Oracle'];
module.exports.dependencies = ['Token'];
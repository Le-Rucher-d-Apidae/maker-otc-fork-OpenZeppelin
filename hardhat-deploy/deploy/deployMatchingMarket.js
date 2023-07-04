const { getContractName, getDeployArgs, getParamsArgs } = require("./deployFn")

const matchingMarket_params = require("../deploy-params/RestrictedSuspendableMatchingMarket-params")
const token_params = require("../deploy-params/ApidaeToken-params")
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

  const contractName = getContractName(matchingMarket_params);
  const token_contractName = getContractName(token_params);
  const uniswapV3Oracle_contractName = uniswapV3Oracle_params.contractName;
  
  const token_deployment = await deployments.get(token_contractName);
  const token_address = token_deployment.address
  const mainTradableToken = token_address;

  const oracle_deployment = await deployments.get(uniswapV3Oracle_contractName);
  const oracle_address = oracle_deployment.address;

  const matchingMarket_args = getParamsArgs(matchingMarket_params, chainId);
  const isMarketSuspended = matchingMarket_args[0];
  const dustLimit = matchingMarket_args[1];

  const oracle_args_token_address = oracle_deployment.args[1];
  const dustToken = oracle_args_token_address;

  // constructor(IERC20 _mainTradableToken, bool _suspended, IERC20 _dustToken, uint128 _dustLimit, address _priceOracle) RestrictedSuspendableSimpleMarket(_mainTradableToken, _suspended) {
  const args = [ mainTradableToken, isMarketSuspended, dustToken, dustLimit, oracle_address ];
  const deployArgs = getDeployArgs(matchingMarket_params, chainId);
  console.log( `Deploying ${contractName} on network ${networkName} (chainId:${chainId})  with args:` );
  const argsArrayLogs = { mainTradableToken: mainTradableToken, isMarketSuspended: isMarketSuspended, dustToken: dustToken, dustLimit: dustLimit, oracle_address: oracle_address };
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

module.exports.tags = ['MatchingMarket'];
module.exports.dependencies = [ 'Token', 'Oracle'];
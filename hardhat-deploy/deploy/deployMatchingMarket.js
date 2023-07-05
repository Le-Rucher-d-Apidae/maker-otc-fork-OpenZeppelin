const { getContractName, getDeployArgs, getParamsArgs } = require("../deploy-tools/deployFn")

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

  const matchingMarket_contractName = getContractName(matchingMarket_params);
  const token_contractName = getContractName(token_params);
  const uniswapV3Oracle_contractName = uniswapV3Oracle_params.contractName;
  
  const token_deployment = await deployments.get(token_contractName);
  const token_address = token_deployment.address
  const mainTradableToken = token_address;

  const oracle_deployment = await deployments.get(uniswapV3Oracle_contractName);
  const oracle_address = oracle_deployment.address;

  const matchingMarket_paramsArgs = getParamsArgs(matchingMarket_params, chainId);
  const isMarketSuspended = matchingMarket_paramsArgs[0];
  const dustLimit = matchingMarket_paramsArgs[1];

  const oracle_args_token_address = oracle_deployment.args[1];
  const dustToken = oracle_args_token_address;

  // constructor(IERC20 _mainTradableToken, bool _suspended, IERC20 _dustToken, uint128 _dustLimit, address _priceOracle) RestrictedSuspendableSimpleMarket(_mainTradableToken, _suspended) {
  const matchingMarket_allArgs = [ mainTradableToken, isMarketSuspended, dustToken, dustLimit, oracle_address ];
  const matchingMarket_deployArgs = getDeployArgs(matchingMarket_params, chainId);
  console.log();
  console.log( `Deploying ${matchingMarket_contractName} on network ${networkName} (chainId:${chainId})  with args:` );
  const argsArrayLogs = { mainTradableToken: mainTradableToken, isMarketSuspended: isMarketSuspended, dustToken: dustToken, dustLimit: dustLimit, oracle_address: oracle_address };
  console.dir( argsArrayLogs );

console.log( `deployArgs:` );
console.dir( matchingMarket_deployArgs );

  // the following will only deploy "{contractName}" if the contract was never deployed or if the code changed since last deployment

  const deployResult = await deploy(
    matchingMarket_contractName,
    {
      from: deployer,
      gasLimit: 4000000,
      args: matchingMarket_allArgs,
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
module.exports.dependencies = [ 'Token', 'Oracle'];
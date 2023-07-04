const matchingMarket_params = require("../deploy-params/RestrictedSuspendableMatchingMarket-params")

const token_params = require("../deploy-params/ApidaeToken-params")
const token_contractName = token_params.contractName;


const uniswapV3Oracle_params = require("../deploy-params/UniswapV3Oracle-params")
const uniswapV3Oracle_contractName = uniswapV3Oracle_params.contractName;

const contractName = matchingMarket_params.contractName;
const log = matchingMarket_params.log;

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
    return matchingMarket_params.args[chainId];
  };

  const token_deployment = await deployments.get(token_contractName);
  const token_address = token_deployment.address

  const oracle_deployment = await deployments.get(uniswapV3Oracle_contractName);
  const oracle_address = oracle_deployment.address;

  const matchingMarket_args = getParamsArgs(chainId);
  const isMarketSuspended = matchingMarket_args[0];
  const dustLimit = matchingMarket_args[1];

  // console.log( `Oracle address: ${oracle_address}` );
  // console.log( `oracle_deployment.args:` );
  // console.dir( oracle_deployment.args );
  const oracle_args_token_address = oracle_deployment.args[1];

  // constructor(IERC20 _mainTradableToken, bool _suspended, IERC20 _dustToken, uint128 _dustLimit, address _priceOracle) RestrictedSuspendableSimpleMarket(_mainTradableToken, _suspended) {
  const args = [ token_address, isMarketSuspended, oracle_args_token_address, dustLimit, oracle_address ];

  console.log( `Deploying ${contractName} on network ${networkName} (chainId:${chainId})  with args:` );
  const argsArrayLogs = { token_address: token_address, isMarketSuspended: isMarketSuspended, oracle_args_token_address: oracle_args_token_address, dustLimit: dustLimit, oracle_address: oracle_address };
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

module.exports.tags = ['MatchingMarket'];
module.exports.dependencies = [ 'Token', 'Oracle'];
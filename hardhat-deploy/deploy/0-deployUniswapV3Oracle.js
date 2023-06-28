
const params = require("../deploy-params/deployUniswapV3Oracle-params")

const contractName = params.contractName;
const log = params.log;
const args = params.args;

console.log( `Deploying ${contractName} with args:` );
console.dir( args );

module.exports = async (
  {
  getNamedAccounts,
  deployments,
  getChainId,
  getUnnamedAccounts,
}) => {
  const {deploy} = deployments;
  const {deployer} = await getNamedAccounts();
  // const args = [
  //   "Hello, Hardhat! (deployed with hardhat-deploy)",
  // ];

  // the following will only deploy "{contractName}" if the contract was never deployed or if the code changed since last deployment
  await deploy(
    contractName,
    {
      from: deployer,
      gasLimit: 4000000,
      args: args,
      log: log,
    }
  );

  getChainId().then( (chainId) => {
    console.log( `chainId = ${chainId}` );
  });
};
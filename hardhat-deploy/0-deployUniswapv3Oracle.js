module.exports = async (
  {
  getNamedAccounts,
  deployments,
  getChainId,
  getUnnamedAccounts,
}) => {
  const {deploy} = deployments;
  const {deployer} = await getNamedAccounts();
  const args = [
    "Hello, Hardhat! (deployed with hardhat-deploy)",
  ];

  // the following will only deploy "Greeter" if the contract was never deployed or if the code changed since last deployment
  await deploy(
    'Greeter',
    {
      from: deployer,
      gasLimit: 4000000,
      args: args,
    }
  );
};
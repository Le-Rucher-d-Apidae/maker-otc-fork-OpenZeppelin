const getParamsArgs = (params, chainId) => {
  return params.args[chainId];
};

const getDeployArgs = (params, chainId) => {
return params.deploy[chainId];
};

const getContractName = (params) => {
  return params.contractName;
};

module.exports = {
  getDeployArgs, getParamsArgs, getContractName
};
// https://hardhat.org/guides/scripts

// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const args = require("./arguments/deployUniswapV3Oracle-arguments")
// const fs = require('fs');
const fs = require('fs/promises');

const listArgs = function (obj)
{
  console.log( `---------` );
  console.log( `args:` );
  for (var key in obj)
    { console.log( `args[ '${key}' ]= '${obj[key]}'` ); }
    console.log( `---------` );
} // listArgs

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');
  
  listArgs( args );
  // ethers is available in the global scope
  const [deployer] = await ethers.getSigners();
  // console.dir( deployer)
  console.log(
    `Deploying the contract ${args["contractName"]} with the account:`,
    await deployer.getAddress()
  );

  const { getChainId } = hre
  const chainId = await getChainId()
  console.log( `chainId = ${chainId}` );

  // We get the contract to deploy
  const UniswapV3Twap_CF = await hre.ethers.getContractFactory(args["contractName"]);

  const UniswapV3Twap = await UniswapV3Twap_CF.deploy(
    args[ "factory" ],
    args[ "token0" ],
    args[ "token1" ],
    args[ "fee" ],
    {
    // from: deployer,
    // log: true,
    // value: hre.ethers.utils.parseEther("0.001"),
    }
  );

  console.debug(typeof(args));
  const contractArgs = { ...args }
  delete contractArgs.contractName
  jsonArgs = JSON.stringify(contractArgs)

  // const d = new Date();
  let dateText = new Date().toLocaleString();


  await UniswapV3Twap.deployed();

  const deploymentResult = `${dateText}: ${args["contractName"]} deployed to: ${UniswapV3Twap.address} with args: ${jsonArgs} on chain ${chainId}\n`

  console.info( deploymentResult );

  await fs.appendFile(`./scripts/deployments/deployments-${args["contractName"]}.txt`, deploymentResult);
} // main

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

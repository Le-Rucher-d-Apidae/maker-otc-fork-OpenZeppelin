// https://hardhat.org/guides/scripts

// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

const args = require("./arguments/deployPayableGreeter-arguments")

const DEFAULT_ARG_MESSAGE = "Hello, Hardhat! (default)"
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

  // console.log( `deployGreeter.js: args: ${args}` );
  listArgs( args );

  // We get the contract to deploy
  const PayableGreeter_CF = await hre.ethers.getContractFactory("PayableGreeter");

  const [addr0_Deployer] = await ethers.getSigners();
  
  console.log( `deployPayableGreeter.js: args["message"] = ${args["message"]}` );

  const message = args["message"] ? args["message"] : DEFAULT_ARG_MESSAGE
  console.log( `deployPayableGreeter.js: args: message = ${message}` );

  // const payableGreeter = await PayableGreeter_CF.deploy( /*args*/ message );

  const payableGreeter = await PayableGreeter_CF.deploy(
    message,
    {
    // from: deployer,
    // log: true,
      value: hre.ethers.utils.parseEther("0.1"),
    }
  );

  await payableGreeter.deployed();

  console.log("PayableGreeter deployed to:", payableGreeter.address)

  const provider = ethers.getDefaultProvider()
  const initialBalance_wei = await provider.getBalance( payableGreeter.address )
  console.log( `deployPayableGreeter.js: initialBalance(wei) = ${initialBalance_wei}` )

  console.log( `deployPayableGreeter.js: initialBalance = ${hre.ethers.utils.formatEther (initialBalance_wei)}` )

  const deployerBalance = hre.ethers.utils.formatEther (await provider.getBalance( addr0_Deployer.address ))
  console.log( `deployPayableGreeter.js: deployerBalance = ${deployerBalance}` )

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

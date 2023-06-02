// https://hardhat.org/guides/scripts

// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

const args = require("./arguments/deployGreeter-arguments")

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
  
  listArgs( args );
  // ethers is available in the global scope
  const [deployer] = await ethers.getSigners();
  console.dir( deployer)
  console.log(
    "Deploying the contracts with the account:",
    await deployer.getAddress()
  );
  // We get the contract to deploy
  const Greeter_CF = await hre.ethers.getContractFactory("Greeter");

  
  console.log( `deployGreeter.js: args["message"] = ${args["message"]}` );

  const message = args["message"] ? args["message"] : DEFAULT_ARG_MESSAGE
  console.log( `deployGreeter.js: args: message = ${message}` );

  // const greeter = await Greeter_CF.deploy( /*args*/ message );

  const greeter = await Greeter_CF.deploy(
    message,
    {
    // from: deployer,
    // log: true,
    // value: hre.ethers.utils.parseEther("0.001"),
    }
  );

  await greeter.deployed();

  console.log("Greeter deployed to:", greeter.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

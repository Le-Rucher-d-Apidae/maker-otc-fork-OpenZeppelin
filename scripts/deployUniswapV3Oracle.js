// https://hardhat.org/guides/scripts

// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

// const args = require("./arguments/deployUniswapV3Oracle-arguments")

UniswapV3Factory_addr ="0x1F98431c8aD98523631AE4a59f267346ea31F984"; // UniswapV3Factory Address on Mainnet, Goerli, Arbitrum, Optimism, Polygon Address
wEth = "0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa" // wEth Address on Polygon Mumbai Testnet
wMatic = "0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889" // wMatic Address on Polygon Mumbai Testnet
fee = 3000 // 0.3% Fee

const args = [
  // address _factory,
  UniswapV3Factory_addr,
  // address _token0,
  wEth,
  // address _token1,
  wMatic,
  // uint24 _fee
  fee
];



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
  const UniswapV3Twap_CF = await hre.ethers.getContractFactory("UniswapV3Twap");

  
  // console.log( `deployUniswapV3Oracle.js: args["message"] = ${args["message"]}` );
  // const message = args["message"] ? args["message"] : DEFAULT_ARG_MESSAGE
  // console.log( `deployUniswapV3Oracle.js: args: message = ${message}` );

  // const greeter = await UniswapV3Twap_CF.deploy( /*args*/ message );

  const UniswapV3Twap = await UniswapV3Twap_CF.deploy(
    // message,
    UniswapV3Factory_addr,
    wEth,
    wMatic,
    fee,
    {
    // from: deployer,
    // log: true,
    // value: hre.ethers.utils.parseEther("0.001"),
    }
  );

  await UniswapV3Twap.deployed();

  console.log("deployUniswapV3Oracle deployed to:", UniswapV3Twap.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

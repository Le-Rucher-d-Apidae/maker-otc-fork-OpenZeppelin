// HIDDEN
// .env
require("dotenv").config()

// PUBLIC
// params-defaults.env
require('dotenv').config({path: './params-defaults.env'})
// params-local.env
require('dotenv').config({path: './params-local.env'})

// PRIVATE
// .env-local
require('dotenv').config({path: './.env-local'})
// .env-project
require('dotenv').config({path: './.env-project'})

require('hardhat-deploy');
require("@nomiclabs/hardhat-ethers"); // require('hardhat-deploy-ethers');

// https://github.com/ItsNickBarry/hardhat-contract-sizer
require("hardhat-contract-sizer");

const Path = require("path");
const createDirAndSubdirsIfNotExists = require("./js/tools").createDirAndSubdirsIfNotExists

require("@nomiclabs/hardhat-etherscan")
//require("@nomiclabs/hardhat-waffle")
require("@nomicfoundation/hardhat-toolbox");
// require("@nomicfoundation/hardhat-verify"); // Unable to verify contract on Sepolia due to Error HH210: Redefinition of task verify failed
require("hardhat-gas-reporter")
require("solidity-docgen")
// require("solidity-coverage")

require("@nomicfoundation/hardhat-foundry");

// https://www.npmjs.com/package/hardhat-tracer
require("hardhat-tracer")

// https://www.npmjs.com/package/@primitivefi/hardhat-dodoc
require('@primitivefi/hardhat-dodoc')

// # Defaults
const DEFAULT_SOLIDITY_VERSION = "0.8.0"
const DEFAULT_GENERATE_DOCS = false
const DEFAULT_DOCS_OUTPUT_PATH = "./docs"
const DEFAULT_DOCS_HH_OUTPUT_PATH = DEFAULT_DOCS_OUTPUT_PATH + "/hh"
const DEFAULT_DOCS_PRIMITIVEFI_HH__DOCS_OUTPUT_PATH = DEFAULT_DOCS_OUTPUT_PATH + "/oz"
const DEFAULT_CONTRACTS_BUILD_DIR = "./artifacts"

const DEFAULT_HARDHAT_MNEMONIC = "test test test test test test test test test test test junk"
const ETH_10000 = "10000000000000000000000" // 10,000 ETH
const ETH_10 = "10000000000000000000" // 10 ETH
// const DEFAULT_HARDHAT_BALANCE = ETH_10000
const DEFAULT_BALANCE = ETH_10
const ACCOUNT_START_ETH_BALANCE = ETH_10

const OPTIMIZER_SETTINGS = {
    optimizer: {
      enabled: true,
      runs: 200
      },
      // viaIR: true,
  }

console.log('-------------------------------------')

// Solidity
// const SOLIDITY_VERSION = ( process.env.SOLIDITY_VERSION !== undefined ? process.env.SOLIDITY_VERSION : DEFAULT_SOLIDITY_VERSION )
// console.log(`SOLIDITY_VERSION = "${SOLIDITY_VERSION}"`)
const SOLIDITY_VERSIONS = ( process.env.SOLIDITY_VERSIONS !== undefined ? process.env.SOLIDITY_VERSIONS : DEFAULT_SOLIDITY_VERSIONS )
console.log(`SOLIDITY_VERSIONS = "${SOLIDITY_VERSIONS}"`)

// const COMPILER_VERSIONS = ["0.7.6", "0.8.21"]
const COMPILER_VERSIONS = SOLIDITY_VERSIONS.replace(/\s/g, "").split(",").sort()
console.log(`COMPILER_VERSIONS = ${COMPILER_VERSIONS.map((version) => `"${version}"`).join(", ")}`)

// Contracts Build Dir
const CONTRACTS_BUILD_DIR = ( process.env.CONTRACTS_BUILD_DIR !== undefined ? ( process.env.CONTRACTS_BUILD_DIR.trim() !== "" ? Path.join(__dirname, process.env.CONTRACTS_BUILD_DIR ) : DEFAULT_CONTRACTS_BUILD_DIR ) : DEFAULT_CONTRACTS_BUILD_DIR )
// console.debug(" ****process.env.CONTRACTS_BUILD_DIR= ", process.env.CONTRACTS_BUILD_DIR)
console.log(`CONTRACTS_BUILD_DIR = "${CONTRACTS_BUILD_DIR}"`)

// Docs
const GENERATE_DOCS = ( process.env.GENERATE_DOCS !== undefined ? process.env.GENERATE_DOCS === "true" : DEFAULT_GENERATE_DOCS )
// console.debug(" ****process.env.GENERATE_DOCS= ", process.env.Generate_Docs)
console.log(`GENERATE_DOCS = "${GENERATE_DOCS}"`)

const DOCS_PRIMITIVEFI_HH__DOCS_OUTPUT_PATH = ( process.env.DOCS_PRIMITIVEFI_HH__DOCS_OUTPUT_PATH !== undefined ? process.env.DOCS_PRIMITIVEFI_HH__DOCS_OUTPUT_PATH : DEFAULT_DOCS_PRIMITIVEFI_HH__DOCS_OUTPUT_PATH )
// console.debug(" ****process.env.GENERATE_DOCS= ", process.env.Generate_Docs)
console.log(`DOCS_PRIMITIVEFI_HH__DOCS_OUTPUT_PATH = "${DOCS_PRIMITIVEFI_HH__DOCS_OUTPUT_PATH}"`)

const DOCS_OPENZEPPLIN_GENDOCS_OUTPUT_PATH = ( process.env.DOCS_OPENZEPPLIN_GENDOCS_OUTPUT_PATH !== undefined ? process.env.DOCS_OPENZEPPLIN_GENDOCS_OUTPUT_PATH : DEFAULT_DOCS_HH_OUTPUT_PATH )
// console.debug(" ****process.env.GENERATE_DOCS= ", process.env.Generate_Docs)
console.log(`DOCS_OPENZEPPLIN_GENDOCS_OUTPUT_PATH = "${DOCS_OPENZEPPLIN_GENDOCS_OUTPUT_PATH}"`)


if (GENERATE_DOCS) {
  if (DOCS_PRIMITIVEFI_HH__DOCS_OUTPUT_PATH) {
    // console.log(`DOCS_PRIMITIVEFI_HH__DOCS_OUTPUT_PATH = "${DOCS_PRIMITIVEFI_HH__DOCS_OUTPUT_PATH}"`)
    createDirAndSubdirsIfNotExists(DOCS_PRIMITIVEFI_HH__DOCS_OUTPUT_PATH)
  }
  if (DOCS_OPENZEPPLIN_GENDOCS_OUTPUT_PATH) {
    // console.log(`DOCS_OPENZEPPLIN_GENDOCS_OUTPUT_PATH = "${DOCS_OPENZEPPLIN_GENDOCS_OUTPUT_PATH}"`)
    createDirAndSubdirsIfNotExists(DOCS_OPENZEPPLIN_GENDOCS_OUTPUT_PATH)
  } 
}


const LOCAL_PRIVATE_KEY = process.env.LOCAL_PRIVATE_KEY
const msgLocPK=`LOCAL_PRIVATE_KEY is ${LOCAL_PRIVATE_KEY===undefined?"UNDEFINED ❌":" DEFINED ✔️" }`
if (LOCAL_PRIVATE_KEY) {
  console.log(msgLocPK)
} else {
  console.error(msgLocPK)
}

const LOCAL_WALLET_MNEMONIC = process.env.LOCAL_WALLET_MNEMONIC
const msgLocWlltMnmc=`LOCAL_WALLET_MNEMONIC is ${LOCAL_WALLET_MNEMONIC===undefined?"UNDEFINED ❌":" DEFINED ✔️" }`
if (LOCAL_WALLET_MNEMONIC) {
  console.log(msgLocWlltMnmc)
} else {
  console.error(msgLocWlltMnmc)
}

const PROJECT_WALLET_MNEMONIC = process.env.PROJECT_WALLET_MNEMONIC
const msgPrjWlltMnmc=`PROJECT_WALLET_MNEMONIC is ${PROJECT_WALLET_MNEMONIC===undefined?"UNDEFINED ❌":" DEFINED ✔️" }`
if (PROJECT_WALLET_MNEMONIC) {
  console.log(msgPrjWlltMnmc)
} else {
  console.error(msgPrjWlltMnmc)
}

const PROJECT_PRIVATE_KEY = process.env.PROJECT_PRIVATE_KEY
const msgPjPK=`PROJECT_PRIVATE_KEY is ${PROJECT_PRIVATE_KEY===undefined?"UNDEFINED ❌":" DEFINED ✔️" }`
if (PROJECT_PRIVATE_KEY) {
  console.log(msgPjPK)
} else {
  console.error(msgPjPK)
}

const WALLET_MNEMONIC=(LOCAL_WALLET_MNEMONIC?LOCAL_WALLET_MNEMONIC:PROJECT_WALLET_MNEMONIC)
const PRIVATE_KEY=(LOCAL_PRIVATE_KEY?LOCAL_PRIVATE_KEY:PROJECT_PRIVATE_KEY)

const msgMNEMONIC=`MNEMONIC: ${(WALLET_MNEMONIC!==undefined&&WALLET_MNEMONIC===LOCAL_WALLET_MNEMONIC)?"LOCAL_WALLET_MNEMONIC ✔️": ((WALLET_MNEMONIC!==undefined&&WALLET_MNEMONIC===PROJECT_WALLET_MNEMONIC)?"PROJECT_WALLET_MNEMONIC ✔️":"NONE ❌") }`
console.log(msgMNEMONIC)

const msgPK=`PRIVATE KEY: ${(PRIVATE_KEY!==undefined&&PRIVATE_KEY===LOCAL_PRIVATE_KEY)?"LOCAL_PRIVATE_KEY ✔️": ((PRIVATE_KEY!==undefined&&PRIVATE_KEY===PROJECT_PRIVATE_KEY)?"PROJECT_PRIVATE_KEY ✔️":"NONE ❌") }`
console.log(msgPK)

const msgUsing=`Using ${WALLET_MNEMONIC!==undefined?"MNEMONIC":(PRIVATE_KEY!==undefined?"PRIVATE KEY":"DEFAULT MENMONIC")} for deployment`
console.info(msgUsing)

const PROVIDER_NAME__ALCHEMY = "ALCHEMY"
const PROVIDER_NAME__INFURA = "INFURA"
const DEFAULT_PROVIDER_NAME = PROVIDER_NAME__INFURA

const PROVIDER_CONFIG__LOCAL = "LOCAL"
const PROVIDER_CONFIG__PROJECT = "PROJECT"

const PROVIDER_NAME = ( process.env.PROVIDER_NAME !== undefined ? process.env.PROVIDER_NAME : DEFAULT_PROVIDER_NAME )
const PROVIDER_CONFIG = ( process.env.PROVIDER_CONFIG !== undefined ? process.env.PROVIDER_CONFIG : PROVIDER_CONFIG__LOCAL )

/*
console.debug(`PROVIDER_NAME = "${PROVIDER_NAME}"`)
console.debug(`PROVIDER_CONFIG = "${PROVIDER_CONFIG}"`)

console.debug(`process.env.LOCAL__TESTNET_GOERLI__ALCHEMY__RPC_URL = "${process.env.LOCAL__TESTNET_GOERLI__ALCHEMY__RPC_URL}"`)
console.debug(`process.env.LOCAL__TESTNET_GOERLI__INFURA__RPC_URL = "${process.env.LOCAL__TESTNET_GOERLI__INFURA__RPC_URL}"`)

console.debug(`process.env.LOCAL__TESTNET_POLYGON_MUMBAI__ALCHEMY__RPC_URL = "${process.env.LOCAL__TESTNET_POLYGON_MUMBAI__ALCHEMY__RPC_URL}"`)
console.debug(`process.env.LOCAL__TESTNET_POLYGON_MUMBAI__INFURA__RPC_URL = "${process.env.LOCAL__TESTNET_POLYGON_MUMBAI__INFURA__RPC_URL}"`)
 */
const TESTNET_GOERLI_RPC = ( PROVIDER_CONFIG == PROVIDER_CONFIG__LOCAL ?
    (PROVIDER_NAME == PROVIDER_NAME__ALCHEMY ? process.env.LOCAL__TESTNET_GOERLI__ALCHEMY__RPC_URL : process.env.LOCAL__TESTNET_GOERLI__INFURA__RPC_URL ) :
    (PROVIDER_NAME == PROVIDER_NAME__ALCHEMY ? process.env.PROJECT__TESTNET_GOERLI__ALCHEMY__RPC_URL : process.env.PROJECT__TESTNET_GOERLI__INFURA__RPC_URL )
  )

const TESTNET_SEPOLIA_RPC = ( PROVIDER_CONFIG == PROVIDER_CONFIG__LOCAL ?
    (PROVIDER_NAME == PROVIDER_NAME__ALCHEMY ? process.env.LOCAL__TESTNET_SEPOLIA__ALCHEMY__RPC_URL : process.env.LOCAL__TESTNET_SEPOLIA__INFURA__RPC_URL ) :
    (PROVIDER_NAME == PROVIDER_NAME__ALCHEMY ? process.env.PROJECT__TESTNET_SEPOLIA__ALCHEMY__RPC_URL : process.env.PROJECT__TESTNET_SEPOLIA__INFURA__RPC_URL )
  )

const TESTNET_POLYGON_MUMBAI_RPC = ( PROVIDER_CONFIG == PROVIDER_CONFIG__LOCAL ?
    (PROVIDER_NAME == PROVIDER_NAME__ALCHEMY ? process.env.LOCAL__TESTNET_POLYGON_MUMBAI__ALCHEMY__RPC_URL : process.env.LOCAL__TESTNET_POLYGON_MUMBAI__INFURA__RPC_URL ) :
    (PROVIDER_NAME == PROVIDER_NAME__ALCHEMY ? process.env.PROJECT__TESTNET_POLYGON_MUMBAI__ALCHEMY__RPC_URL : process.env.PROJECT__TESTNET_POLYGON_MUMBAI__INFURA__RPC_URL )
  )
  
const MAINNET_POLYGON__RPC = ( PROVIDER_CONFIG == PROVIDER_CONFIG__LOCAL ?
    (PROVIDER_NAME == PROVIDER_NAME__ALCHEMY ? process.env.LOCAL__MAINNET_POLYGON__ALCHEMY__RPC_URL : process.env.LOCAL__MAINNET_POLYGON__INFURA__RPC_URL ) :
    (PROVIDER_NAME == PROVIDER_NAME__ALCHEMY ? process.env.PROJECT__MAINNET_POLYGON__ALCHEMY__RPC_URL : process.env.PROJECT__MAINNET_POLYGON__INFURA__RPC_URL )
  )

console.debug(`TESTNET_GOERLI_RPC = "${TESTNET_GOERLI_RPC}"`)
console.debug(`TESTNET_SEPOLIA_RPC = "${TESTNET_SEPOLIA_RPC}"`)
console.debug(`TESTNET_POLYGON_MUMBAI_RPC = "${TESTNET_POLYGON_MUMBAI_RPC}"`)
console.debug(`MAINNET_POLYGON__RPC = "${MAINNET_POLYGON__RPC}"`)

// Hardhat Network forking
const HARDHAT_FORK_NETWORK = process.env.HARDHAT_FORK_NETWORK
console.debug(`HARDHAT_FORK_NETWORK = "${HARDHAT_FORK_NETWORK}"`)
const HARDHAT_FORK_NETWORK_URL = process.env[HARDHAT_FORK_NETWORK]
console.info(`HARDHAT_FORK_NETWORK_URL = "${HARDHAT_FORK_NETWORK_URL}"`)

const HARDHAT_FORK_NETWORK_BLOCK_NUMBER = (process.env.HARDHAT_FORK_NETWORK_BLOCK_NUMBER?parseInt(process.env.HARDHAT_FORK_NETWORK_BLOCK_NUMBER):undefined)
console.debug(`HARDHAT_FORK_NETWORK_BLOCK_NUMBER = ${HARDHAT_FORK_NETWORK_BLOCK_NUMBER}`)

const FORKING_CONFIG = HARDHAT_FORK_NETWORK_URL ? 
  {
    url: HARDHAT_FORK_NETWORK_URL,
    blockNumber: HARDHAT_FORK_NETWORK_BLOCK_NUMBER
  } :
  undefined
  ;

const getAccountsConfig = (network) => {
  
  if (PRIVATE_KEY !== undefined) {
    if (network == "hardhat") {
      return [ {privateKey: PRIVATE_KEY, balance: ACCOUNT_START_ETH_BALANCE}, 
        // {privateKey: PRIVATE_KEY2, balance: string}, ...
        ]
    }
    return [ PRIVATE_KEY,
      // PRIVATE_KEY2, ...
      ]
  }
  if (WALLET_MNEMONIC !== undefined) {
    return {
      mnemonic: WALLET_MNEMONIC,
      passphrase: "",

      path: "m/44'/60'/0'/0",
      initialIndex: 0,
      count: 20,
      accountsBalance: ACCOUNT_START_ETH_BALANCE, // n ETH
    }
  }
  if (network == "hardhat") {
    return {mnemonic: DEFAULT_HARDHAT_MNEMONIC }
  }
  return []
 
}

const ACCOUNTS_CONFIG = getAccountsConfig()
// console.debug(`ACCOUNTS_CONFIG = ${JSON.stringify(ACCOUNTS_CONFIG)}`)
const ACCOUNTS_CONFIG_HH = getAccountsConfig("hardhat")
// console.debug(`ACCOUNTS_CONFIG_HH = ${JSON.stringify(ACCOUNTS_CONFIG_HH)}`)


const POLYGONSCAN_API_KEY = ( PROVIDER_CONFIG == PROVIDER_CONFIG__LOCAL ?
  process.env.LOCAL__POLYGONSCAN_API_KEY :
  process.env.PROJECT__POLYGONSCAN_API_KEY
)
console.debug(`POLYGONSCAN_API_KEY = "${POLYGONSCAN_API_KEY}"`)

const TESTNET_POLYGON_MUMBAI__API_URL = ( PROVIDER_CONFIG == PROVIDER_CONFIG__LOCAL ?
  process.env.LOCAL__TESTNET_POLYGON_MUMBAI__API_URL :
  process.env.PROJECT__TESTNET_POLYGON_MUMBAI__API_URL
)
console.debug(`TESTNET_POLYGON_MUMBAI__API_URL = "${TESTNET_POLYGON_MUMBAI__API_URL}"`)

const MAINNET_POLYGON_MUMBAI__API_URL = ( PROVIDER_CONFIG == PROVIDER_CONFIG__LOCAL ?
  process.env.LOCAL__MAINNET_POLYGON__API_URL :
  process.env.PROJECT__MAINNET_POLYGON_MUMBAI__API_URL
)
console.debug(`MAINNET_POLYGON_MUMBAI__API_URL = "${MAINNET_POLYGON_MUMBAI__API_URL}"`)



const MAINNET_ETHERSCAN_API_KEY = undefined;
console.debug(`MAINNET_ETHERSCAN_API_KEY = "${MAINNET_ETHERSCAN_API_KEY}"`)
const GOERLI_ETHERSCAN_API_KEY = undefined;
console.debug(`GOERLI_ETHERSCAN_API_KEY = "${GOERLI_ETHERSCAN_API_KEY}"`)
const SEPOLIA_ETHERSCAN_API_KEY = undefined;
console.debug(`SEPOLIA_ETHERSCAN_API_KEY = "${SEPOLIA_ETHERSCAN_API_KEY}"`)


console.log('-------------------------------------')

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

task("accountsDetails", "Prints the list of accounts", async (taskArgs, hre) =>
{
  // console.log("taskArgs=", taskArgs)
  
  const networkName= hre.network.name
  console.log(`networkName=${networkName}`)
  const networkAccounts= config.networks[networkName].accounts
  
  const accounts = await hre.ethers.getSigners()
  // console.log(  hre.ethers )

  // const provider = hre.ethers.getDefaultProvider()
  // console.log(  await provider.getNetwork() )

  const provider = hre.ethers.provider
  console.log(  provider )

  console.log(`${accounts.length} account${accounts.length>1?"s":""} :` )
  const accountsPadding = Math.log10(accounts.length)+1
  /*
  accounts.forEach(function (account, i) {
    if (networkAccounts.mnemonic)
    {
      const wallet = ethers.Wallet.fromMnemonic(networkAccounts.mnemonic, networkAccounts.path + `/${i}`);
      let balance = provider.getBalance( accounts[0] ); // await
      console.log('account[%d] address= %s pk= %s, balance = ', i, account.address, wallet.privateKey, balance);
    }
    else
    {
      console.log('account[%d] address= %s', i, account.address);
    }
  });
  */

await Promise.all( accounts.map(async (account, idx) => {
  let str = `account[${String(idx).padStart(accountsPadding, ' ')}] address= ${account.address}`
  if (networkAccounts.mnemonic)
  {
    const wallet = ethers.Wallet.fromMnemonic(networkAccounts.mnemonic, networkAccounts.path + `/${idx}`);
    str+= ` pk= ${wallet.privateKey}`
  }
  const balance = await provider.getBalance( account.address );
  str+= ` , balance = ${ethers.utils.formatEther(balance)}`
  console.log(str)
}));



}) // task

// task("docx", "compile", async (taskArgs, hre) => {
//   await hre.run("compile");
// })

// console.dir(
//   task("x", "y", async (taskArgs, hre) => {
//     await hre.run("compile");
//   })
// )

task("comp", "Compile")
  // .addParam("generatedoc", "generate solidity docs")
  .addOptionalParam("generatedoc", "generate solidity docs")
  .setAction(async (taskArgs) => {
    // const account = web3.utils.toChecksumAddress(taskArgs.account);
    // const balance = await web3.eth.getBalance(account);
    // console.log(web3.utils.fromWei(balance, "ether"), "ETH");
    // taskArgs.generateDoc

    generateDoc = (taskArgs.generatedoc == "true" || taskArgs.generatedoc == "y")
    // console.log(`taskArgs.generatedoc=${taskArgs.generatedoc}`)
    // console.log(`generateDoc=${generateDoc}`)

    await hre.run("compile");
  });



// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {

  defaultNetwork: "hardhat",
  // defaultNetwork: "goerli",
  // defaultNetwork: "sepolia",
  // defaultNetwork: "mumbai",
  
  dodoc: {
    runOnCompile: GENERATE_DOCS||false,
    debugMode: false,
    freshOutput: true, // clean before generate
    outputDir: DOCS_PRIMITIVEFI_HH__DOCS_OUTPUT_PATH,
    // More options...
    // https://www.npmjs.com/package/@primitivefi/hardhat-dodoc
    // include
    // exclude
    // keepFileStructure
  },
  docgen: { 
    outputDir: DOCS_OPENZEPPLIN_GENDOCS_OUTPUT_PATH,
    // More options...
    // templates
    // pages (default: 'single')
    // theme
    // exclude
    // pageExtension (default: 'md')
    // https://github.com/OpenZeppelin/solidity-docgen/blob/master/src/config.ts
  }, 

  solidity: {

    compilers:
      COMPILER_VERSIONS.map( (version) => {
        return {
          version,
          settings: OPTIMIZER_SETTINGS
        }
      }),
    // compilers: [
    // // Market
    // {
    //     version: SOLIDITY_VERSION,
    //     settings: OPTIMIZER_SETTINGS_0_8_x
    //   },
    //   // Oracle
    //   {
    //     version: "0.7.6",
    //     settings: OPTIMIZER_SETTINGS_0_7_6
    //   },
    // ],

  },

  networks: {
    hardhat: {
      live: false,
      saveDeployments: false,
      tags: ["test", "local"],
      accounts: ACCOUNTS_CONFIG_HH,
      // hardfork: string;
      forking: FORKING_CONFIG,
      verify: {
        etherscan: {
          apiUrl: TESTNET_POLYGON_MUMBAI__API_URL,
          apiKey: POLYGONSCAN_API_KEY
        }
      },
    },
    // Goerli Testnet
    goerli: {
      live: true,
      saveDeployments: true,
      url: TESTNET_GOERLI_RPC || "",
      accounts: ACCOUNTS_CONFIG,
      // gasPrice: 8000000000, // default is 'auto' which breaks chains without the london hardfork
    },
    // Sepolia Testnet
    sepolia: {
      live: true,
      saveDeployments: true,
      url: TESTNET_SEPOLIA_RPC || "",
      accounts: ACCOUNTS_CONFIG,
    },
    // Polygon Mumbai Testnet
    mumbai: {
      live: true,
      saveDeployments: true,
      tags: ["staging"],
      url: TESTNET_POLYGON_MUMBAI_RPC || "",
      accounts: ACCOUNTS_CONFIG,
      verify: {
        etherscan: {
          apiUrl: TESTNET_POLYGON_MUMBAI__API_URL,
          apiKey: POLYGONSCAN_API_KEY
        }
      },
    },
    // Polygon Mainnet
    polygon: {
      live: true,
      saveDeployments: true,
      url: MAINNET_POLYGON__RPC || "",
      accounts: ACCOUNTS_CONFIG,
      verify: {
        etherscan: {
          apiUrl: MAINNET_POLYGON_MUMBAI__API_URL,
          apiKey: POLYGONSCAN_API_KEY
        }
      },
    },

  },

  paths: {
    // hardhat default
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    // artifacts: "./artifacts"
    artifacts: CONTRACTS_BUILD_DIR,

    // hardhat-deploy plugin
    deploy: 'hardhat-deploy/deploy',
    deployments: 'hardhat-deploy/deployments',
    imports: 'hardhat-deploy/imports'

  },

    //This is the part you need to verify
    namedAccounts: {
      deployer: {
          default: 0,
      },
      tokenOwner: {
        default: 1,
      }
      // player: {
      //     default: 1,
      // },
  },

  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },

  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: true,
    strict: true,
    // only: [':ERC20$'],
    // except: [':ERC20$'],
  },

  etherscan: {
    apiKey: {
        mainnet: MAINNET_ETHERSCAN_API_KEY,
        goerli: GOERLI_ETHERSCAN_API_KEY,
        sepolia: SEPOLIA_ETHERSCAN_API_KEY,
/*
        // binance smart chain
        bsc: "YOUR_BSCSCAN_API_KEY",
        bscTestnet: "YOUR_BSCSCAN_API_KEY",
        // huobi eco chain
        heco: "YOUR_HECOINFO_API_KEY",
        hecoTestnet: "YOUR_HECOINFO_API_KEY",
        // fantom mainnet
        opera: "YOUR_FTMSCAN_API_KEY",
        ftmTestnet: "YOUR_FTMSCAN_API_KEY",
        // optimism
        optimisticEthereum: "YOUR_OPTIMISTIC_ETHERSCAN_API_KEY",
        optimisticKovan: "YOUR_OPTIMISTIC_ETHERSCAN_API_KEY",
        // arbitrum
        arbitrumOne: "YOUR_ARBISCAN_API_KEY",
        arbitrumTestnet: "YOUR_ARBISCAN_API_KEY",
        // avalanche
        avalanche: "YOUR_SNOWTRACE_API_KEY",
        avalancheFujiTestnet: "YOUR_SNOWTRACE_API_KEY",
        // moonbeam
        moonbeam: "YOUR_MOONBEAM_MOONSCAN_API_KEY",
        moonriver: "YOUR_MOONRIVER_MOONSCAN_API_KEY",
        moonbaseAlpha: "YOUR_MOONBEAM_MOONSCAN_API_KEY",
        // harmony
        harmony: "YOUR_HARMONY_API_KEY",
        harmonyTest: "YOUR_HARMONY_API_KEY",
        // xdai and sokol don't need an API key, but you still need
        // to specify one; any string placeholder will work
        xdai: "api-key",
        sokol: "api-key",
        aurora: "api-key",
        auroraTestnet: "api-key",
*/
        // polygon
        polygon: POLYGONSCAN_API_KEY,
        polygonMumbai: POLYGONSCAN_API_KEY,
      }
    },
  
  mocha: {
    timeout: 40000
  }
}

// console.debug("hardhat.config.js: module.exports", module.exports);

const contractName = "UniswapV3Twap"

const UniswapV3Factory_addr ="0x1F98431c8aD98523631AE4a59f267346ea31F984"; // UniswapV3Factory Address on Mainnet, Goerli, Arbitrum, Optimism, Polygon

const wEth_PolygonMumbaiTestnet = "0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa" // wEth Address on Polygon Mumbai Testnet
const wMatic_PolygonMumbaiTestnet = "0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889" // wMatic Address on Polygon Mumbai Testnet

const USDC_PolygonMainnet = "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174" // USDC Address on Polygon Mainnet ; 6 decimals
// const USDT_PolygonMainnet = "0xc2132D05D31c914a87C6611C10748AEb04B58e8F" // USDT Address on Polygon Mainnet ; 6 decimals
// const BUSD_PolygonMainnet = "0xdAb529f40E671A1D4bF91361c21bf9f0C9712ab7" // BUSD Address on Polygon Mainnet ; 18 decimals
// const DAI_PolygonMainnet = "0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063" // DAI Address on Polygon Mainnet ; 18 decimals
// const wMatic_PolygonMainnet = "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270" // wMatic Address on Polygon Mainnet ; 18 decimals

// Uniswap pools fees // Polygon Mumbai addresses
// const FEE_1_00 = 10000 // 0x2710 1% Fee // v3-pool 0x99D59d73bAd8BE070FeA364717400043490866c9
// const FEE_0_30 = 3000 // 0x0bb8 0.30% Fee // v3-pool 0xc1FF5D622aEBABd51409e01dF4461936b0Eb4E43
// const FEE_0_05 = 500 // 0x01f4 0.05% Fee // v3-pool 0x85bc6CBFb02a110D5839b344545B02fB6cb70cD5
// const FEE_0_001 = 100 // 0x0064 0.001% Fee // v3-pool 0x765fDB41ea7Fd9fF26C8DD4eEa20A4248f106622

// const FEE =  '0x' + FEE_0_001.toString(16) // convert to hex
// console.debug( `FEE = ${FEE}` );

// Arguments:
// 0 : address _factory,
// 1 : address _token

const args_PolygonMumbaiTestnet = [UniswapV3Factory_addr, wEth_PolygonMumbaiTestnet]; // Polygon Mumbai Testnet
const args_PolygonMainnet = [UniswapV3Factory_addr, USDC_PolygonMainnet]; // Polygon Mainnet

let params ={
  contractName: contractName,
  args: {
    // 31337:  args_PolygonMumbaiTestnet, // HardHat fork on Polygon Mumbai Testnet
    31337:  args_PolygonMainnet, // HardHat fork on Polygon Mainnet
    80001:  args_PolygonMumbaiTestnet, // Polygon Mumbai Testnet
    137:    args_PolygonMainnet, // Polygon Mainnet
    },
  deploy: {
    31337:  { log: true, waitConfirmations: 1 }, // HardHat fork on Polygon Mumbai Testnet
    31337:  { log: true, waitConfirmations: 1 }, // HardHat fork on Polygon Mainnet
    80001:  { log: true, waitConfirmations: 6 }, // Polygon Mumbai Testnet
    137:    { log: true, waitConfirmations: 6 }, // Polygon Mainnet
  },
    // log: true,
    // waitConfirmations: 1, // Number of confirmations to wait between deployments (default: 1)
}

module.exports = params;
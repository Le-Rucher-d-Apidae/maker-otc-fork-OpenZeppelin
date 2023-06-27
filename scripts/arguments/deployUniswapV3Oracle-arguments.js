
const contractName = "UniswapV3Twap"
const UniswapV3Factory_addr ="0x1F98431c8aD98523631AE4a59f267346ea31F984"; // UniswapV3Factory Address on Mainnet, Goerli, Arbitrum, Optimism, Polygon Address
const wEth = "0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa" // wEth Address on Polygon Mumbai Testnet
const wMatic = "0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889" // wMatic Address on Polygon Mumbai Testnet

const FEE_0_30 = 3000 // 0x0bb8 0.30% Fee
const FEE_1_00 = 10000 // 0x2710 1% Fee
const FEE_0_05 = 500 // 0x01f4 0.05% Fee

const FEE =  '0x' + FEE_0_30.toString(16) // convert to hex
// console.debug( `FEE = ${FEE}` );

let params ={
  contractName: contractName,
  factory: UniswapV3Factory_addr,
  token0: wEth,
  token1: wMatic,
  fee: FEE
}

module.exports = params;
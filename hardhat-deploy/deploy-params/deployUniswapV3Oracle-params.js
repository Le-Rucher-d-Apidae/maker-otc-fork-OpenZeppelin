
const contractName = "UniswapV3Twap"
const UniswapV3Factory_addr ="0x1F98431c8aD98523631AE4a59f267346ea31F984"; // UniswapV3Factory Address on Mainnet, Goerli, Arbitrum, Optimism, Polygon Address
const wEth = "0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa" // wEth Address on Polygon Mumbai Testnet
const wMatic = "0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889" // wMatic Address on Polygon Mumbai Testnet

const FEE_0_30 = 3000 // 0x0bb8 0.30% Fee // v3-pool 0xc1FF5D622aEBABd51409e01dF4461936b0Eb4E43
const FEE_1_00 = 10000 // 0x2710 1% Fee
const FEE_0_05 = 500 // 0x01f4 0.05% Fee // v3-pool 0x85bc6CBFb02a110D5839b344545B02fB6cb70cD5
const FEE_0_001 = 100 // 0x0064 0.001% Fee // v3-pool 0x765fDB41ea7Fd9fF26C8DD4eEa20A4248f106622

const FEE =  '0x' + FEE_0_001.toString(16) // convert to hex
// console.debug( `FEE = ${FEE}` );

let params ={
  contractName: contractName,
  args: [UniswapV3Factory_addr, wEth, wMatic, FEE],
  log: true,
}

module.exports = params;
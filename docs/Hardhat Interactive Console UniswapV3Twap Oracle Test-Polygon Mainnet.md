# Advanced Sample Hardhat Project

[Using the Hardhat console](https://hardhat.org/hardhat-runner/docs/guides/hardhat-console/)

[Deploying and interacting with smart contracts](https://docs.openzeppelin.com/learn/deploying-and-interacting#querying-state)


launch local node in a shell (HardHat configuration must fork Polygon Mumbai)
```shell
npx hardhat node
```


start console on local node in another shell window
```shell
npx hardhat console --network localhost
```
  

Get contract Factory
```shell
const UniswapV3Twap_CF = await ethers.getContractFactory("UniswapV3Twap");

```

Deploy Oracles : UniswapV3Twap contracts
```shell
const UniswapV3Factory_addr ="0x1F98431c8aD98523631AE4a59f267346ea31F984";

const USDC_PolygonMainnet = "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174" // USDC Address on Polygon Mainnet
const USDT_PolygonMainnet = "0xc2132D05D31c914a87C6611C10748AEb04B58e8F" // USDT Address on Polygon Mainnet
const BUSD_PolygonMainnet = "0xdAb529f40E671A1D4bF91361c21bf9f0C9712ab7" // BUSD Address on Polygon Mainnet
const DAI_PolygonMainnet = "0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063" // DAI Address on Polygon Mainnet
const wMatic_PolygonMainnet = "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270" // wMatic Address on Polygon Mainnet

// Uniswap v3 pools fees // Polygon Mumbai addresses
const FEE_1_00 = 10000 // 0x2710 1% Fee // v3-pool 0x99D59d73bAd8BE070FeA364717400043490866c9
const FEE_0_30 = 3000; // 0x0bb8 0.30% Fee // v3-pool 0xc1FF5D622aEBABd51409e01dF4461936b0Eb4E43
const FEE_0_05 = 500; // 0x01f4 0.05% Fee // v3-pool 0x85bc6CBFb02a110D5839b344545B02fB6cb70cD5
const FEE_0_01 = 100; // 0x0064 0.001% Fee // v3-pool 0x765fDB41ea7Fd9fF26C8DD4eEa20A4248f106622

const FEE_1 =  '0x' + FEE_1_00.toString(16); // convert to hex
const FEE_030 =  '0x' + FEE_0_30.toString(16); // convert to hex
const FEE_0005 =  '0x' + FEE_0_05.toString(16); // convert to hex
const FEE_0001 =  '0x' + FEE_0_01.toString(16); // convert to hex

// Polygon Mumbai existing pools
// const univ3Oracle3000 = await UniswapV3Twap_CF.deploy( UniswapV3Factory_addr, wEth, wMatic, FEE_030);
// const univ3Oracle500 = await UniswapV3Twap_CF.deploy( UniswapV3Factory_addr, wEth, wMatic, FEE_0005);
// const univ3Oracle100 = await UniswapV3Twap_CF.deploy( UniswapV3Factory_addr, wEth, wMatic, FEE_0001);
const univ3OracleUSDC = await UniswapV3Twap_CF.deploy( UniswapV3Factory_addr, USDC_PolygonMainnet );
const univ3OracleUSDT = await UniswapV3Twap_CF.deploy( UniswapV3Factory_addr, USDT_PolygonMainnet );
const univ3OracleBUSD = await UniswapV3Twap_CF.deploy( UniswapV3Factory_addr, BUSD_PolygonMainnet );
const univ3OracleDAI = await UniswapV3Twap_CF.deploy( UniswapV3Factory_addr, DAI_PolygonMainnet );
```

Get univ3Oracles addresses
```shell
// console.log("univ3Oracle3000.address", univ3Oracle3000.address);
// console.log("univ3Oracle500.address", univ3Oracle500.address);
// console.log("univ3Oracle100.address", univ3Oracle100.address);
console.log("univ3Oracle.address", univ3Oracle.address);
console.log("univ3OracleUSDC.address", univ3OracleUSDC.address);
console.log("univ3OracleUSDT.address", univ3OracleUSDT.address);
console.log("univ3OracleBUSD.address", univ3OracleBUSD.address);
console.log("univ3OracleDAI.address", univ3OracleDAI.address);

```


Call univ3Oracle's estimateAmountOut()
```shell

// Amounts in wei
const amount_100WETH = "100000000000000000000"; // 100_000_000_000_000_000_000; // 100 ETH
const amount_10WETH = "10000000000000000000"; // 10_000_000_000_000_000_000; // 10 ETH
const amount_1WETH = "1000000000000000000"; // 1_000_000_000_000_000_000; // 1 ETH
const amount_0_01WETH = "10000000000000000"; // 10_000_000_000_000_000 // 0.01 ETH
const amount_0_015WETH = "15000000000000000"; // 15_000_000_000_000_000 // 0.015 ETH
const amount_0_0001WETH = "100000000000000"; // 10_000_000_000_000_000 // 0.0001 ETH
const amount_0_00000000000001 = "10000"; // 10_000 // 0.00000000000001 ETH

// Amounts for stable coins
const amount_1USDC = "1000000"; // 1_000_000; // 1 USDC
const amount_10USDC = "10000000"; // 10_000_000; // 10 USDC
const amount_100USDC = "100000000"; // 100_000_000; // 100 USDC

const amount_1USDT = "1000000"; // 1_000_000; // 1 USDT
const amount_10USDT = "10000000"; // 10_000_000; // 10 USDT
const amount_100USDT = "100000000"; // 100_000_000; // 100 USDT

const amount_1BUSD = "1000000000000000000"; // 1_000_000_000_000_000_000; // 1 BUSD
const amount_10BUSD = "10000000000000000000"; // 10_000_000_000_000_000_000; // 10 BUSD
const amount_100BUSD = "100000000000000000000"; // 100_000_000_000_000_000_000; // 100 BUSD

const amount_1DAI = "1000000000000000000"; // 1_000_000_000_000_000_000; // 1 DAI
const amount_10DAI = "10000000000000000000"; // 10_000_000_000_000_000_000; // 10 DAI
const amount_100DAI = "100000000000000000000"; // 100_000_000_000_000_000_000; // 100 DAI

// TIME
const LAST_HOUR = 3600;


(await univ3OracleUSDC.estimateAmountOut(USDT_PolygonMainnet, FEE_0001, amount_1USDT, LAST_HOUR)).toString()
(await univ3OracleUSDC.estimateAmountOut(USDT_PolygonMainnet, FEE_0001, amount_10USDT, LAST_HOUR)).toString()
(await univ3OracleUSDC.estimateAmountOut(USDT_PolygonMainnet, FEE_0001, amount_100USDT, LAST_HOUR)).toString()

(await univ3OracleUSDC.estimateAmountOut(BUSD_PolygonMainnet, FEE_0001, amount_1BUSD, LAST_HOUR)).toString()
(await univ3OracleUSDC.estimateAmountOut(BUSD_PolygonMainnet, FEE_0001, amount_10BUSD, LAST_HOUR)).toString()
(await univ3OracleUSDC.estimateAmountOut(BUSD_PolygonMainnet, FEE_0001, amount_100BUSD, LAST_HOUR)).toString()

(await univ3OracleUSDC.estimateAmountOut(DAI_PolygonMainnet, FEE_0001, amount_1DAI, LAST_HOUR)).toString()
(await univ3OracleUSDC.estimateAmountOut(DAI_PolygonMainnet, FEE_0001, amount_10DAI, LAST_HOUR)).toString()
(await univ3OracleUSDC.estimateAmountOut(DAI_PolygonMainnet, FEE_0001, amount_100DAI, LAST_HOUR)).toString()

// revert: invalid token
(await univ3Oracle.estimateAmountOut(USDC_PolygonMainnet, FEE_0001, amount_1USDC, LAST_HOUR)).toString()


// let tokenIn = USDT_PolygonMainnet;
// let average_weighted_time = LAST_HOUR;
// let amountIn = amount_1USDT;


Exit Hh console
```shell
.exit

```

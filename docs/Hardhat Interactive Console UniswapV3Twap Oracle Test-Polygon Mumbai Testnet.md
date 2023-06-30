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
const wEth = "0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa";
const wMatic = "0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889";

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
const univ3Oracle = await UniswapV3Twap_CF.deploy( UniswapV3Factory_addr, wEth );

```

Get univ3Oracles addresses
```shell
// console.log("univ3Oracle3000.address", univ3Oracle3000.address);
// console.log("univ3Oracle500.address", univ3Oracle500.address);
// console.log("univ3Oracle100.address", univ3Oracle100.address);
console.log("univ3Oracle.address", univ3Oracle.address);

```


Call univ3Oracle's estimateAmountOut()
```shell


let tokenIn = wEth;
const amount_100WETH = "100000000000000000000"; // 100_000_000_000_000_000_000; // 100 ETH
const amount_10WETH = "10000000000000000000"; // 10_000_000_000_000_000_000; // 10 ETH
const amount_1WETH = "1000000000000000000"; // 1_000_000_000_000_000_000; // 1 ETH
const amount_0_01WETH = "10000000000000000"; // 10_000_000_000_000_000 // 0.01 ETH
const amount_0_015WETH = "15000000000000000"; // 15_000_000_000_000_000 // 0.015 ETH
const amount_0_0001WETH = "100000000000000"; // 10_000_000_000_000_000 // 0.0001 ETH
const amount_0_00000000000001 = "10000"; // 10_000 // 0.00000000000001 ETH

0.015

let amountInWETH = amount_0_0001WETH;

const LAST_HOUR = 3600;
let average_weighted_time = LAST_HOUR;

// revert: invalid token
await univ3Oracle.estimateAmountOut(tokenIn, FEE_0001, amountInWETH,average_weighted_time);

tokenIn = wMatic;
let amountOutWMatic = await univ3Oracle.estimateAmountOut(tokenIn, FEE_0001, amountInWETH,average_weighted_time);



amountIn = amount_0_0001WETH;
amountIn = amount_0_00000000000001;
amountIn = amount_1WETH;
amountIn = amount_0_01WETH;
amountIn = amount_0_015WETH;

fee = FEE_1;
fee = FEE_0_30;
fee = FEE_0_05;

(await univ3Oracle.estimateAmountOut(tokenIn, fee, amountIn,average_weighted_time)).toString()

let amountOutWMatic5 = await univ3Oracle.estimateAmountOut(tokenIn, fee, amountIn,average_weighted_time);


(await univ3Oracle.estimateAmountOut(tokenIn, fee, amountIn,average_weighted_time)).toString()


let amountOutWMatic2 = await univ3Oracle.estimateAmountOut(tokenIn, FEE_0001, amountIn,average_weighted_time);
console.log(amountOutWMatic);
console.log( amountOutWMatic.toString() ); // ethers.BigNumber.toString()


let amountOutWMatic1 = await univ3Oracle100.estimateAmountOut(tokenIn,amountInWETH,average_weighted_time);
console.log(amountOutWMatic1);
console.log( amountOutWMatic1.toString() ); // ethers.BigNumber.toString()

let amountOutWMatic2 = await univ3Oracle500.estimateAmountOut(tokenIn,amountInWETH,average_weighted_time);
console.log(amountOutWMatic2);
console.log( amountOutWMatic2.toString() ); // ethers.BigNumber.toString()

let amountOutWMatic3 = await univ3Oracle3000.estimateAmountOut(tokenIn,amountInWETH,average_weighted_time);
console.log(amountOutWMatic3);
console.log( amountOutWMatic3.toString() ); // ethers.BigNumber.toString()

console.log(amountOutWMatic4);
console.log( amountOutWMatic4.toString() ); // ethers.BigNumber.toString()

console.log(amountOutWMatic5);
console.log( amountOutWMatic5.toString() ); // ethers.BigNumber.toString()


Exit Hh console
```shell
.exit

```

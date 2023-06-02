# Advanced Sample Hardhat Project

[Using the Hardhat console](https://hardhat.org/hardhat-runner/docs/guides/hardhat-console/)

[Deploying and interacting with smart contracts](https://docs.openzeppelin.com/learn/deploying-and-interacting#querying-state)


launch local node in a shell
```shell
npx hardhat node --verbose
```

start console on local node in another shell window
```shell
npx hardhat console --network localhost
```
  

Get contract Factory
```shell
const Greeter = await ethers.getContractFactory("Greeter");

```

Deploy Greeter
```shell
const greeter = await Greeter.deploy( "Hello, Hh !" );

```

Get greeter address
```shell
const gAddress = greeter.address;
const sameGreeter = await ethers.getContractAt("Greeter", gAddress);

```


const sameGreeter = await ethers.getContractAt("Greeter", gAddress);


Call greeter greet(), set value, check value set
```shell
await greeter.greet();
const txReceipt = await sameGreeter.setGreeting("Another Hh greeting");
txReceipt;
await greeter.greet();

```

List accounts
```shell
let accounts = await ethers.provider.listAccounts();
const provider = ethers.provider;
let balance = await provider.getBalance( accounts[0] );

```


All
```shell
const Greeter = await ethers.getContractFactory("Greeter");
const greeter = await Greeter.deploy( "Hello, Hh !" );
greeter.address;
await greeter.greet();

```



PayableGreeter
```shell
const PayableGreeter = await ethers.getContractFactory("PayableGreeter");
const payGreeter = await PayableGreeter.deploy( "Hello, Hh !", { value: hre.ethers.utils.parseEther("0.1") } );
payGreeter.address;
await payGreeter.greet();
const provider = ethers.provider;
await provider.getBalance( payGreeter.address )

```










Exit Hh console
```shell
.exit

```

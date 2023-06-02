const { expect } = require("chai");
// const { ethers } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

const ETH_ONE_TENTH = hre.ethers.utils.parseEther("0.1")

const PayableGreeterClassName = "PayableGreeter"

describe("PayableGreeter", function () {

  const INITIAL_GREETER_MESSAGE = "Hello, world!"
  const SPANISH_GREETER_MESSAGE = "Hola, mundo!"

  async function deployContractFixture() {

    const provider = ethers.provider;

    const Greeter = await ethers.getContractFactory(PayableGreeterClassName);
    const greeter = await Greeter.deploy(INITIAL_GREETER_MESSAGE, {value: ETH_ONE_TENTH,});
    await greeter.deployed();

    const initialBalance_Wei = await provider.getBalance( greeter.address );
    // console.log( `initialBalance_Wei=${initialBalance_Wei}` )
    const initialBalance_Eth = ethers.utils.formatUnits(initialBalance_Wei.toString(), "ether")
    console.log( `initialBalance_Eth=${initialBalance_Eth} ETH` )

    return { greeter, provider };
  }


  it("Should return the new greeting once it's changed", async function () {

    const {greeter} = await loadFixture(deployContractFixture);

    expect(await greeter.greet()).to.equal( INITIAL_GREETER_MESSAGE );

    const setGreetingTx = await greeter.setGreeting(SPANISH_GREETER_MESSAGE);

    // wait until the transaction is mined
    await setGreetingTx.wait();

    expect(await greeter.greet()).to.equal(SPANISH_GREETER_MESSAGE);
  });

  // ---

  it("Should return the money to the owner", async function () {

    const [addr0] = await ethers.getSigners();

    const {greeter, provider} = await loadFixture(deployContractFixture);

    const initialBalance_Wei = await provider.getBalance( greeter.address );
    expect( initialBalance_Wei ).to.be.greaterThan( 0 );
    // console.log( `initialBalance_Wei=${initialBalance_Wei}` )

    const setWithdrawAllTx = await greeter.withdrawAllMoney( addr0.address );
    // wait until the transaction is mined
    await setWithdrawAllTx.wait();
    const finalBalance_Wei = await provider.getBalance( greeter.address );
    // console.log( `finalBalance=${finalBalance}` )

    expect( finalBalance_Wei ).to.equal( 0 );
  })

  // ---

  it("Should return the money to anyone if called by the owner", async function () {
    

    const [, addr1] = await ethers.getSigners();
    const {greeter, provider} = await loadFixture(deployContractFixture);

    const contract_initialBalance_Wei = await provider.getBalance( greeter.address );
    const addr1_initialBalance_Wei = await provider.getBalance( addr1.address );
    console.log( `contract_initialBalance_Wei=${contract_initialBalance_Wei}` )
    console.log( `addr1_initialBalance_Wei=${addr1_initialBalance_Wei}` )

    const contract_initialBalance_Eth = ethers.utils.formatUnits(contract_initialBalance_Wei.toString(), "ether")
    console.log( `contract_initialBalance_Wei_Eth=${contract_initialBalance_Eth} ETH` )

    expect( contract_initialBalance_Wei ).to.be.greaterThan( 0 );

    // const setWithdrawAllTx = await greeter.withdrawAllMoney( addr1.address );
    // // wait until the transaction is mined
    // await setWithdrawAllTx.wait();
    /*
    const contract_initialBalance_Wei_sub = ethers.BigNumber.from("0").sub(contract_initialBalance_Wei)
    await expect(
      greeter.withdrawAllMoney( addr1.address )
     ).to.changeEtherBalance( [greeter.address, addr1.address], [contract_initialBalance_Wei_sub, contract_initialBalance_Wei], {includeFee: false});
    */
    const contract_initialBalance_Wei_sub = ethers.BigNumber.from("0").sub( contract_initialBalance_Wei)
    await expect(
      greeter.withdrawAllMoney( addr1.address )
     ).to.changeEtherBalances( [greeter, addr1], [contract_initialBalance_Wei_sub, contract_initialBalance_Wei], {includeFee: false} );


    const contract_finalBalance_Wei = await provider.getBalance( greeter.address );
    const addr1_finalBalance_Wei = await provider.getBalance( addr1.address );

    expect( contract_finalBalance_Wei ).to.equal( 0 );
    expect( addr1_finalBalance_Wei ).to.be.greaterThan( addr1_initialBalance_Wei );



  })

  // ---

  it("Should NOT return the money to anyone if not called by the owner", async function () {
    

    const [, addr1] = await ethers.getSigners();
    const {greeter, provider} = await loadFixture(deployContractFixture);

    const contract_initialBalance_Wei = await provider.getBalance( greeter.address );
    const addr1_initialBalance_Wei = await provider.getBalance( addr1.address );
    console.log( `contract_initialBalance_Wei=${contract_initialBalance_Wei}` )
    console.log( `addr1_initialBalance_Wei=${addr1_initialBalance_Wei}` )

    expect( contract_initialBalance_Wei ).to.be.greaterThan( 0 );

    // const setWithdrawAllTx = await greeter.connect(addr1).withdrawAllMoney( addr1.address );
    // wait until the transaction is mined
    // await setWithdrawAllTx.wait();
    await expect(
      greeter.connect(addr1).withdrawAllMoney( addr1.address )
    ).to.be.revertedWith("You cannot withdraw.");


    const contract_finalBalance_Wei = await provider.getBalance( greeter.address );
    const addr1_finalBalance_Wei = await provider.getBalance( addr1.address );

    expect( contract_finalBalance_Wei ).to.equal( contract_initialBalance_Wei );
    expect( addr1_finalBalance_Wei ).to.equal( addr1_initialBalance_Wei );
  })

});

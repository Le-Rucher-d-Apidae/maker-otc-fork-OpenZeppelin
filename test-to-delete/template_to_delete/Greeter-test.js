const { expect } = require("chai");
// const { ethers } = require("hardhat");
// const hre = require("hardhat");

const INITIAL_GREETER_MESSAGE = "Hello, world!"
const SPANISH_GREETER_MESSAGE = "Hola, mundo!"
const DEUTSCH_GREETER_MESSAGE = "Hallo, Erde!"

describe("Greeter", function () {
  it("Should return the new greeting once it's changed", async function () {

    const [owner, addr1] = await ethers.getSigners();

    const Greeter = await ethers.getContractFactory("Greeter");
    const greeter = await Greeter.deploy(INITIAL_GREETER_MESSAGE);
    await greeter.deployed();

    expect(await greeter.greet()).to.equal(INITIAL_GREETER_MESSAGE);

    const setSpanishGreetingTx = await greeter.setGreeting(SPANISH_GREETER_MESSAGE);

    // wait until the transaction is mined
    await setSpanishGreetingTx.wait();

    expect(await greeter.greet()).to.equal(SPANISH_GREETER_MESSAGE);

    const setDeutschGreetingTx = await greeter.connect(addr1).setGreeting(DEUTSCH_GREETER_MESSAGE);
    // wait until the transaction is mined
    await setDeutschGreetingTx.wait();

    expect(await greeter.greet()).to.equal(DEUTSCH_GREETER_MESSAGE);
  });
});

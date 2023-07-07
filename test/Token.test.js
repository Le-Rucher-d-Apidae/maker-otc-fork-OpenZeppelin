const {expect} = require("./chai-setup.cjs");
const token_params = require("../hardhat-deploy/deploy-params/ApidaeToken-params");
const {ethers, deployments, getNamedAccounts} = require("hardhat");

describe("Token contract", function() {
  it("Deployment should assign the total supply of tokens to the owner", async function() {
    await deployments.fixture(["Token"]);
    const {deployer, tokenOwner} = await getNamedAccounts();
    const Token = await ethers.getContract( token_params.contractName );
    const ownerBalance = await Token.balanceOf(tokenOwner);
    const supply = await Token.totalSupply();
    expect(ownerBalance).to.equal(supply);

    // const deployerBalance = await Token.balanceOf(deployer);
    // expect(deployerBalance).to.equal(0);

  });
  it("Deployment should not assign the total supply of tokens to the deployer unless they are the same", async function() {
    await deployments.fixture(["Token"]);
    const {deployer, tokenOwner} = await getNamedAccounts();
    const Token = await ethers.getContract( token_params.contractName );

    const deployerBalance = await Token.balanceOf(deployer);
    const supply = await Token.totalSupply();

    if (deployer != tokenOwner) {
      expect(deployerBalance).to.equal(0);
    } else {
      expect(deployerBalance).to.equal(supply);
    }

  });
});

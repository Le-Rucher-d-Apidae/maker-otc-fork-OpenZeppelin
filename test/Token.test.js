import {expect} from "./chai-setup";

import {token_params} from "../deploy-params/ApidaeToken-params"
// const token_params = require("../deploy-params/ApidaeToken-params")


import {ethers, deployments, getNamedAccounts} from 'hardhat';

describe("Token contract", function() {
  it("Deployment should assign the total supply of tokens to the owner", async function() {
    await deployments.fixture(["Token"]);
    const {deployer, tokenOwner} = await getNamedAccounts();
    const Token = await ethers.getContract( token_params.contractName );
    const ownerBalance = await Token.balanceOf(tokenOwner);
    const supply = await Token.totalSupply();
    expect(ownerBalance).to.equal(supply);

    const deployerBalance = await Token.balanceOf(deployer);
    expect(deployerBalance).to.equal(0);

  });
});

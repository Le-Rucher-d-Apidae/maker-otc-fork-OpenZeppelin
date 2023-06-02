//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract PayableGreeter {
    string private greeting;
    address payable public owner;

    constructor(string memory _greeting) payable  {
        console.log("Deploying a Greeter with greeting:", _greeting);
        owner = payable(msg.sender);
        greeting = _greeting;
    }

    function greet() public view returns (string memory) {
        return greeting;
    }

    function setGreeting(string memory _greeting) public {
        console.log("Changing greeting from '%s' to '%s'", greeting, _greeting);
        greeting = _greeting;
    }

    function withdrawAllMoney(address payable _to) public {
    require(owner == msg.sender, "You cannot withdraw.");
    _to.transfer(address(this).balance);
    }

    function contractBalance() public view returns (uint) {
    return address(this).balance;
  }

}

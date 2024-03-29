// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "forge-std/console2.sol";

contract ApidaeERC20 is ERC20, ERC20Burnable, Ownable {

    constructor(string memory name_, string memory symbol_, uint256 _totalSupply, address _totalSupplyOwner) ERC20(name_, symbol_) {
        uint256 mintAmount = _totalSupply * 10 ** decimals();
        address _mintSupplyTo = (_totalSupplyOwner != address(0) ? _totalSupplyOwner : msg.sender);

        _mint( _mintSupplyTo, mintAmount);
        // console2.log( "ApidaeERC20 constructor:_mint ", _totalSupply, "tokens (#tokens units: ", mintAmount, ") to ", _mintSupplyTo );
        console2.log( "ApidaeERC20 constructor:_mint (", _totalSupply, " tokens) to; ", _mintSupplyTo );
        console2.log( "ApidaeERC20 constructor:_mint tokens units:", mintAmount );
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

}
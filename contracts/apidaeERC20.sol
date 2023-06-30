// SPDX-License-Identifier: MIT
// pragma solidity >= 0.8.18 < 0.9.0;
// pragma solidity ^0.8.20;
pragma solidity ^0.8.18; // latest HH supported version

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "forge-std/console2.sol";

contract ApidaeERC20 is ERC20, ERC20Burnable, Ownable {

    constructor(string memory name_, string memory symbol_, uint256 _totalSupply) ERC20(name_, symbol_) {
        console2.log( "ApidaeERC20 constructor:_mint tokens #", _totalSupply);
        console2.log( "ApidaeERC20 constructor:_mint tokens units #", _totalSupply * 10 ** decimals() );
        _mint(msg.sender, _totalSupply * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

}
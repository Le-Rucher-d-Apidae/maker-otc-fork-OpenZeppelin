// SPDX-License-Identifier: AGPL-3.0-or-later

/// markets.t.sol

//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// pragma solidity >= 0.8.18 < 0.9.0;
// pragma solidity ^0.8.20;
pragma solidity ^0.8.18; // latest HH supported version


import "forge-std/Vm.sol";
import "forge-std/console2.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../contracts/MarketsConstants.sol";

string constant SOMEMNEMONIC_01 = "test test test test test test test test test test test junk";

contract VmCheat {
    Vm vm;

    // address public NULL_ADDRESS = address(0x0);
    IERC20 public NULL_ERC20 = IERC20(NULL_ADDRESS);
    address constant CHEAT_CODE = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D; // bytes20(uint160(uint256(keccak256('hevm cheat code')))); // 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D

    uint256 immutable somePrivateKey_99;
    uint256 immutable somePrivateKey_33;

    address payable immutable someUser_99;
    address payable immutable someUser_33;


    constructor() {
        vm = Vm(address(CHEAT_CODE));
        console2.log("VmCheat: constructor()");

        somePrivateKey_99 = vm.deriveKey(SOMEMNEMONIC_01, 99);
        somePrivateKey_33 = vm.deriveKey(SOMEMNEMONIC_01, 33);

        someUser_99 = payable( vm.addr(somePrivateKey_99) );
        someUser_33 = payable( vm.addr(somePrivateKey_33) );
    }

    function setUp() public virtual {
        console2.log("VmCheat: setUp()");
        // vm = Vm(address(CHEAT_CODE));
        vm.warp(1);


    }

/* 
    function getSomeUser(uint256 _userNum, uint256 _etherAmount)
        public virtual
        returns (address payable[] memory)
    {
        // uint256 somePrivateKey_99 = vm.deriveKey(SOMEMNEMONIC_01, 99);
        // someUser = vm.addr(somePrivateKey_99);

        // address someUser = vm.addr(vm.deriveKey(SOMEMNEMONIC_01, 99));
        // uint256 userNum = (_userNum < 0) ? 0 : _userNum;
        uint256 userNum = (_userNum < pseudoRandom() ) ? 0 : _userNum;
        vm = Vm(address(CHEAT_CODE));
        address payable someUser = vm.deriveKey(SOMEMNEMONIC_01, userNum);


        // vm.deal(someUser, 100 ether);
        // Amount of ether to send to the user : < 0 = random, 0 = 0, > 0 = amount
        uint256 etherAmount = (_etherAmount < 0 ? pseudoRandom() : _etherAmount ) * 1 ether;
        vm.deal(someUser, etherAmount);
    }
 */

    /**
     * @dev Returns a pseudo-random number between 0 and 1_000_000, inclusive.
     */
    function pseudoRandom() private view returns (uint) {
    uint randomHash = uint(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, block.number)));
    return randomHash % 1_000_000;
    } 

}

contract DSTokenBase is ERC20{
    constructor(uint _initialSupply) ERC20("Test", "TST") {
        _mint(msg.sender, _initialSupply );
    }
}


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

pragma solidity ^0.8.21;


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

    uint256 immutable somePrivateKey_11;
    uint256 immutable somePrivateKey_22;
    uint256 immutable somePrivateKey_33;
    uint256 immutable somePrivateKey_44;
    uint256 immutable somePrivateKey_55;
    uint256 immutable somePrivateKey_66;
    uint256 immutable somePrivateKey_77;
    uint256 immutable somePrivateKey_88;
    uint256 immutable somePrivateKey_99;

    address payable immutable someUser_11;
    address payable immutable someUser_22;
    address payable immutable someUser_33;
    address payable immutable someUser_44;
    address payable immutable someUser_55;
    address payable immutable someUser_66;
    address payable immutable someUser_77;
    address payable immutable someUser_88;
    address payable immutable someUser_99;


    constructor() {
        vm = Vm(address(CHEAT_CODE));
        console2.log("VmCheat: constructor()");


        somePrivateKey_11 = vm.deriveKey(SOMEMNEMONIC_01, 11);
        somePrivateKey_22 = vm.deriveKey(SOMEMNEMONIC_01, 22);
        somePrivateKey_33 = vm.deriveKey(SOMEMNEMONIC_01, 33);
        somePrivateKey_44 = vm.deriveKey(SOMEMNEMONIC_01, 44);
        somePrivateKey_55 = vm.deriveKey(SOMEMNEMONIC_01, 55);
        somePrivateKey_66 = vm.deriveKey(SOMEMNEMONIC_01, 66);
        somePrivateKey_77 = vm.deriveKey(SOMEMNEMONIC_01, 77);
        somePrivateKey_88 = vm.deriveKey(SOMEMNEMONIC_01, 88);
        somePrivateKey_99 = vm.deriveKey(SOMEMNEMONIC_01, 99);

        someUser_11 = payable( vm.addr(somePrivateKey_11) );
        someUser_22 = payable( vm.addr(somePrivateKey_22) );
        someUser_33 = payable( vm.addr(somePrivateKey_33) );
        someUser_44 = payable( vm.addr(somePrivateKey_44) );
        someUser_55 = payable( vm.addr(somePrivateKey_55) );
        someUser_66 = payable( vm.addr(somePrivateKey_66) );
        someUser_77 = payable( vm.addr(somePrivateKey_77) );
        someUser_88 = payable( vm.addr(somePrivateKey_88) );
        someUser_99 = payable( vm.addr(somePrivateKey_99) );
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


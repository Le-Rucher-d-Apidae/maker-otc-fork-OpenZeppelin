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

contract VmCheat {
    Vm vm;

    address public NULL_ADDRESS = address(0x0);
    IERC20 public NULL_ERC20 = IERC20(NULL_ADDRESS);
    address constant CHEAT_CODE = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D; // bytes20(uint160(uint256(keccak256('hevm cheat code')))); // 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D

    function setUp() public virtual {
        console2.log("VmCheat: setUp()");
        vm = Vm(address(CHEAT_CODE));
        vm.warp(1);
    }
}

contract DSTokenBase is ERC20{
    constructor(uint _initialSupply) ERC20("Test", "TST") {
        _mint(msg.sender, _initialSupply );
    }
}
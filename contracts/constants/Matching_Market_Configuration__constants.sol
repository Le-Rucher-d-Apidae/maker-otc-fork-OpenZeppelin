// SPDX-License-Identifier: AGPL-3.0-or-later

/// Matching_Market_Configuration__constants.sol

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

// Limits
string constant _MMLMTBLW001 = "dustLimit_ is below threshold";

// Zero address
string constant _MMDST000 = "Dust token address can not be 0x0.";

string constant _MMPOR000 = "Price oracle address can not be 0x0.";

uint8 constant DUST_LIMIT = 100;
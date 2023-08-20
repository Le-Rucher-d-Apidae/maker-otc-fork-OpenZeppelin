// SPDX-License-Identifier: AGPL-3.0-or-later

/// Simple_Market_With_Fees__constants.sol


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
string constant _SMWFZCFG000 = "SimpleMarketWithFees: Configuration cannot be zero address";
string constant _SMWFZSEC001 = "Only fee collector or owner can call withdraw fees";
string constant _SMWFZNTFND001 = "Nothing to collect for this token address";
string constant _SMWFZZRO001 = "No amount to collect for this token address";
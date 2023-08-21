// SPDX-License-Identifier: AGPL-3.0-or-later

/// Simple_Market_Configuration_With_Fees__constants.sol

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
string constant _MMWFLMT010 = "Market max fee too high.";
string constant _MMWFLMT011 = "Market fee too high.";
string constant _MMWFLMT000 = "Market fee too low. Must be at least 2 (= 0.0002%) or set it to zero.";
string constant _MMWFLMT020 = "Market buyFeeRatio fee too high.";
string constant _MMWFLMT021 = "Market sellFeeRatio fee too high.";
// Zero address
string constant _MMWFZ000 = "Fee collector cannot be zero address.";

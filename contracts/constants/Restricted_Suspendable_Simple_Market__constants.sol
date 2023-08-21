// SPDX-License-Identifier: AGPL-3.0-or-later

/// Restricted_Suspendable_Simple_Market__constants.sol

// fork of expiring_market.sol Dai Foundation

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

import "forge-std/console2.sol";


// S Series = Security/Authorization

// T Series = Trades/Offers
string constant _RSSM_T000 = "T000_TOKEN NOT AUTHORIZED";
string constant _RSSM_T001 = "T001_BUY_TOKEN_NOT_ALLOWED";
string constant _RSSM_T002 = "T002_SELL_TOKEN_NOT_ALLOWED";

// AL Series = Allowances
string constant _RSSM_AL000 = "Can't revoke mainTradableToken";
string constant _RSSM_AL001 = "No need to allow mainTradableToken";

string constant _RSSM_AL010 = "Already allowed";
string constant _RSSM_AL100 = "mainTradableToken must be set first";
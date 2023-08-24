// SPDX-License-Identifier: AGPL-3.0-or-later

/// Matching_Market__constants.sol

// Copyright (C) 2017 - 2021 Dai Foundation

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


// S Series = Security/Authorization
string constant _RSS001 = "RS001_REENTRANCY";

string constant _MM_SEC001 = "No indirect calls please";

string constant _MM_CFG001 = "Can't set dust for the dustToken";

// T Series = Trades/Offers
string constant _RST001 = "RST001_NOT_OWNER_OR_DUST";
string constant _RST104 = "RST104_OFFER_AMOUNT_LOW";
string constant _MM_TRD005 = "not enough offers to fulfill";
string constant _MM_OFR001 = "offer is already sorted";
string constant _MM_OFR002 = "offer must be active";

string constant _MM_OFR101 = "Offer was deleted or taken, or never existed";
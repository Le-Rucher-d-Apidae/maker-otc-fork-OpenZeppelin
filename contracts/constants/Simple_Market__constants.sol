// SPDX-License-Identifier: AGPL-3.0-or-later

/// Simple_Market__constants.sol

// Copyright (C) 2016 - 2021 Dai Foundation

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


// S Series = Security
string constant _S000 = "S000_REENTRANCY_ATTEMPT";
// A Series = Authorization
string constant _A100 = "A100_CANCEL_NOT_AUTHORIZED";

// T Series = Trades/Offers
string constant _T101 = "T101_OFFER_NOT_PRESENT";
string constant _T107 = "T107_TOKENS_CANT_BE_THE_SAME";

// F Series = Funds
string constant _F102 = "F102_ADDRESS_CANT_BE_0X";
string constant _F111 = "F111_BUY_QUANTITY_TOO_HIGH";
string constant _F112 = "F112_SPENT_QUANTITY_TOO_HIGH";

/*
    string constant _S101 = "S101_NOT_AUTHORIZED";

    string constant _F101 = "F101_BALANCE_NOT_ENOUGH";
    string constant _F103 = "F103_TOKEN_NOT_ALLOWED";
    string constant _F104 = "F104_TRANSFER_FAILED";

    // T Series = Trades/Offers

    string constant _T102 = "T102_OFFER_ID_NOT_VALID";
    string constant _T103 = "T103_OFFER_TYPE_NOT_VALID";
    string constant _T104 = "T104_OFFER_AMOUNT_LOW";
    string constant _T105 = "T105_OFFER_AMOUNT_HIGH";
    string constant _T106 = "T106_OFFER_AMOUNT_NOT_VALID";
    string constant _T108 = "T108_NOT_ENOUGH_OFFERS_PRESENT";
    string constant _T109 = "T109_BUY_FAILED";
    string constant _T110 = "T110_UNSORT_FAILED";
    string constant _T111 = "T111_FILL_AMOUNT_LOW";
    string constant _T112 = "T112_FILL_AMOUNT_HIGH";
*/

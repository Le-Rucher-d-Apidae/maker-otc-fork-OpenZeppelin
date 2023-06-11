// SPDX-License-Identifier: AGPL-3.0-or-later

/// suspendable_market.sol

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

// pragma solidity >= 0.8.18 < 0.9.0;
// pragma solidity ^0.8.20;
pragma solidity ^0.8.18; // latest HH supported version

// import "hardhat/console.sol";
import "forge-std/console2.sol";

import "./suspendable_simple_market.sol";

contract RestrictedSuspendableSimpleMarketErrorCodes {
    // S Series = Security/Authorization

    // T Series = Trades/Offers
    string internal constant _T001 = "T001_BUY_TOKEN_NOT_ALLOWED";
    string internal constant _T002 = "T002_SELL_TOKEN_NOT_ALLOWED";
    // string internal constant _T003 = "T003_WRONG_TRADING_PAIR";

/*
    string internal constant _S101 = "S101_NOT_AUTHORIZED";
    // F Series = Funds

    string internal constant _F101 = "F101_BALANCE_NOT_ENOUGH";
    string internal constant _F102 = "F102_ADDRESS_CANT_BE_0";
    string internal constant _F103 = "F103_TOKEN_NOT_ALLOWED";
    string internal constant _F104 = "F104_TRANSFER_FAILED";

    // T Series = Trades/Offers

    string internal constant _T101 = "T101_OFFER_NOT_PRESENT";
    string internal constant _T102 = "T102_OFFER_ID_NOT_VALID";
    string internal constant _T103 = "T103_OFFER_TYPE_NOT_VALID";
    string internal constant _T104 = "T104_OFFER_AMOUNT_LOW";
    string internal constant _T105 = "T105_OFFER_AMOUNT_HIGH";
    string internal constant _T106 = "T106_OFFER_AMOUNT_NOT_VALID";
    string internal constant _T107 = "T107_TOKENS_CANT_BE_THE_SAME";
    string internal constant _T108 = "T108_NOT_ENOUGH_OFFERS_PRESENT";
    string internal constant _T109 = "T109_BUY_FAILED";
    string internal constant _T110 = "T110_UNSORT_FAILED";
    string internal constant _T111 = "T111_FILL_AMOUNT_LOW";
    string internal constant _T112 = "T112_FILL_AMOUNT_HIGH";
*/

}

contract RestrictedSuspendableSimpleMarket is SuspendableSimpleMarket, RestrictedSuspendableSimpleMarketErrorCodes {

    ERC20 mainTradableToken; // ApidaeToken
    mapping (ERC20=>bool) tradableTokens; // mainTradableToken must not be in this list

    // Invalid Trading pair
    // @param buyToken token to buy.
    // @param sellToken token to sell.
    error InvalidTradingPair(ERC20 buyToken, ERC20 sellToken);
    
    constructor(ERC20 _mainTradableToken, bool _suspended) SuspendableSimpleMarket(_suspended) {
        mainTradableToken = _mainTradableToken;
    }

    // Tokens checks

    modifier tokenAllowed(ERC20 erc20) {
        require(tradableTokens[erc20], "Token not authorized");
        _;
    }

    modifier checkOfferTokens(ERC20 _pay_gem, ERC20 _buy_gem) override {
        // Since tradable tokens are whitelisted, no need to check for address(0x0)
        // Check for token : one must be mainTradableToken, other must be tradable
        console2.log( "checkOfferTokens RestrictedSuspendableSimpleMarket" );

        // Sell mainTradableToken
        if (_pay_gem==mainTradableToken) {
            // Buy token must be tradable
            require(tradableTokens[_buy_gem], _T001);
        // Buy mainTradableToken
        } else if (_buy_gem==mainTradableToken) {
            // Sold token must be tradable
            require(tradableTokens[_pay_gem], _T002);
        } else {
            // mainTradableToken is neither sold or bought : revert
            revert InvalidTradingPair(_pay_gem, _buy_gem);
        }
        _;
    }

    function setmainTradableToken(ERC20 _erc20) public onlyOwner {
        // Allow to set only once
        if (address(mainTradableToken) == NULL_ADDRESS) {
            mainTradableToken = _erc20;
        }
    }

    function allowToken(ERC20 _erc20) public onlyOwner {
        require(_erc20!=mainTradableToken,"No need to allow mainTradableToken");
        require(!tradableTokens[_erc20],"Already allowed");
        require(address(_erc20) != address(0x0));
        // TODO: check is ERC20
        // TODO: check is ERC20
        // TODO: check is ERC20
        // TODO: check is ERC20
        // TODO: check is ERC20
        // TODO: check is ERC20
        tradableTokens[_erc20] = true;
    }

    function revokeToken(ERC20 _erc20) public onlyOwner tokenAllowed(_erc20) {
        // Allow to remove all tradable tokens
        // existing orders will remain active (no checks are made on buys)
        delete tradableTokens[_erc20];
    }

    // TODO function offer(uint _pay_amt, ERC20 _pay_gem, uint _buy_amt, ERC20 _buy_gem)

}
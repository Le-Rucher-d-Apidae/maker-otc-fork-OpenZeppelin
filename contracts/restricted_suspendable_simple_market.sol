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

pragma solidity ^0.8.21;

// import "hardhat/console.sol";
import "forge-std/console2.sol";

import "./suspendable_simple_market.sol";

contract RestrictedSuspendableSimpleMarketErrorCodes {
    // S Series = Security/Authorization

    // T Series = Trades/Offers
    string internal constant _T001 = "T001_BUY_TOKEN_NOT_ALLOWED";
    string internal constant _T002 = "T002_SELL_TOKEN_NOT_ALLOWED";
}

// Invalid Trading pair
// @notice mean mùain token is missing from the pair
// @param buyToken token to buy.
// @param sellToken token to sell.
error InvalidTradingPair(IERC20 buyToken, IERC20 sellToken);

contract RestrictedSuspendableSimpleMarket is SuspendableSimpleMarket, RestrictedSuspendableSimpleMarketErrorCodes {

    IERC20 public mainTradableToken; // ApidaeToken
    mapping (IERC20=>bool) tradableTokens; // mainTradableToken must not be in this list

    
    /// @notice inherits from SuspendableSimpleMarket
    /// @notice mainTradableToken may be null at construction time, but must be set before any offer
    /// @dev 
    constructor(IERC20 _mainTradableToken, bool _suspended) SuspendableSimpleMarket(_suspended) {
        mainTradableToken = _mainTradableToken;
    }

    // Tokens checks
    modifier tokenAllowed(IERC20 erc20) {
        require(tradableTokens[erc20], "Token not authorized");
        _;
    }


    /// @notice overrides checkOfferTokens to enforce only one token to be "mainTradableToken" and the other to be an allowed token
    /// @dev checkOfferTokens is called by offer function
    /// @dev no need to check for address(0x0) since tradable tokens are whitelisted
    /// @dev if mainTradableToken has not been set (address(0x0)), no tradable token may have been set modifier will fail properly (e.g.checkOfferTokens( 0x0, 0x0)) with InvalidTradingPair error
    /// @param _pay_gem token to check
    /// @param _buy_gem token to check
    modifier checkOfferTokens(IERC20 _pay_gem, IERC20 _buy_gem) override {
        // Since tradable tokens are whitelisted, no need to check for address(0x0)
        // Check for token : one must be mainTradableToken, other must be tradable
        // console2.log( "modifier checkOfferTokens:RestrictedSuspendableSimpleMarket" );

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

    function setmainTradableToken(IERC20 _erc20) public onlyOwner {
        // Allow to set only once
        if (address(mainTradableToken) == NULL_ADDRESS) {
            mainTradableToken = _erc20;
        }
    }

    /// @notice allows to trade a token
    /// @notice 1 mainTradableToken must be set (not null) before allowing any other token
    /// @notice 2 mainTradableToken and at least one tradableTokens must be set before any offer
    /// @dev 
    /// @param _erc20 token to check
    function allowToken(IERC20 _erc20) public onlyOwner {
        require(address(mainTradableToken) != NULL_ADDRESS,"mainTradableToken must be set first");
        require(_erc20!=mainTradableToken,"No need to allow mainTradableToken");
        require(!tradableTokens[_erc20],"Already allowed");
        require(address(_erc20) != NULL_ADDRESS);
        // TODO: check is ERC20
        // TODO: check is ERC20
        // TODO: check is ERC20
        // TODO: check is ERC20
        // TODO: check is ERC20
        // TODO: check is ERC20
        tradableTokens[_erc20] = true;
    }

    function revokeToken(IERC20 _erc20) public onlyOwner tokenAllowed(_erc20) {
        // Allow to remove all tradable tokens
        // existing orders will remain active (no checks are made on buys)
        delete tradableTokens[_erc20];
    }

    // TODO function offer(uint _pay_amt, ERC20 _pay_gem, uint _buy_amt, ERC20 _buy_gem)

}
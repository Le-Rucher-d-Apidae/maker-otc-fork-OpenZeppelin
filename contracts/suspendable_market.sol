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

import "./simple_market.sol";


contract SuspendableMarket is SimpleMarket {
    bool public closed;
    bool public suspended;

    constructor(ERC20 _mainTradableToken, bool _suspended) SimpleMarket(_mainTradableToken) {
        suspended = _suspended;
    }

    // after close_time has been reached, no new offers are allowed
    modifier can_offer override {
        // require(!isClosed());
        // require(!isSuspended());
        require(isMarketActive());
        _;
    }

    // after close, no new buys are allowed
    modifier can_buy(uint id) override {
        // require(isActive(id));
        require(isOrderActive(id));
        require(isMarketActive());
        _;
    }

    // after close, anyone can cancel an offer
    modifier can_cancel(uint id) override {
        // require(isActive(id));
        require(isOrderActive(id));
        require((msg.sender == getOwner(id)) || isMarketClosed());
        _;
    }


    function isMarketClosed() public view returns (bool) {
        return closed;
    }

    function unsuspendMarket() public onlyOwner {
        suspended = false;
    }

    function suspendMarket() public onlyOwner {
        suspended = true;
    }

    function isMarketActive() public view returns (bool) {
        return !suspended&&!closed;
    }

    function closeMarket() public onlyOwner {
        closed = true;
    }
}
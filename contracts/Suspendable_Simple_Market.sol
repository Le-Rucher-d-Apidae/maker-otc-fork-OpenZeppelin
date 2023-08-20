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

import "./constants/Suspendable_Simple_Market__constants.sol";

import "./Simple_Market.sol";

contract SuspendableSimpleMarket is SimpleMarket {
    bool public closed;
    bool public suspended;

    constructor(bool _suspended) SimpleMarket() {
        suspended = _suspended;
    }

    // Allow new offers only when market is active (not closed/suspended)
    modifier can_offer override {
        require(isMarketActive(), _SS201);
        _;
    }

    // Allow buys only when market is active (not closed/suspended)
    modifier can_buy(uint id) override {
        require(isOrderActive(id),_T101); 
        require(isMarketActive(), _SS201);
        _;
    }

    // after close, anyone can cancel an offer
    modifier can_cancel(uint id) virtual override {
        require(isOrderActive(id),_T101); 
        require((msg.sender == getOwner(id)) || isMarketClosed());
        _;
    }

    function isMarketClosed() public view returns (bool) {
        return closed;
    }

    function unsuspendMarket() public onlyOwner {
        require(!closed, _SS299);
        require(suspended, _SS202);
        suspended = false;
    }

    function suspendMarket() public onlyOwner {
        require(!suspended, _SS203);
        suspended = true;
    }

    function isMarketActive() public view returns (bool) {
        return !suspended && !closed;
    }

    function closeMarket() public onlyOwner {
        require(!closed, _SS299);
        closed = true;
    }
}
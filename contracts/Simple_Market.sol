// SPDX-License-Identifier: AGPL-3.0-or-later

/// Simple_Market.sol

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


import "forge-std/console2.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./constants/Markets__constants.sol";
import "./constants/Simple_Market__constants.sol";

contract EventfulMarket {
    event LogItemUpdate(uint id);
    event LogTrade(uint pay_amt, address indexed pay_gem,
                   uint buy_amt, address indexed buy_gem);

    event LogMake(
        bytes32  indexed  id,
        bytes32  indexed  pair,
        address  indexed  maker,
        IERC20             pay_gem,
        IERC20             buy_gem,
        uint128           pay_amt,
        uint128           buy_amt,
        uint64            timestamp
    );

    event LogBump(
        bytes32  indexed  id,
        bytes32  indexed  pair,
        address  indexed  maker,
        IERC20             pay_gem,
        IERC20             buy_gem,
        uint128           pay_amt,
        uint128           buy_amt,
        uint64            timestamp
    );

    event LogTake(
        bytes32           id,
        bytes32  indexed  pair,
        address  indexed  maker,
        IERC20             pay_gem,
        IERC20             buy_gem,
        address  indexed  taker,
        uint128           take_amt,
        uint128           give_amt,
        uint64            timestamp
    );

    event LogKill(
        bytes32  indexed  id,
        bytes32  indexed  pair,
        address  indexed  maker,
        IERC20             pay_gem,
        IERC20             buy_gem,
        uint128           pay_amt,
        uint128           buy_amt,
        uint64            timestamp
    );

} // contract EventfulMarket

contract SimpleMarket is EventfulMarket, Ownable {

    using SafeERC20 for IERC20;
    // address public constant NULL_ADDRESS = address(0x0);

    uint public last_offer_id; // defaults to 0 when deployed

    mapping (uint => OfferInfo) public offers;

    bool locked; // Flag to re-entrancy attacks ; defaults to false when deployed

    struct OfferInfo {
        uint     pay_amt;
        IERC20    pay_gem;
        uint     buy_amt;
        IERC20    buy_gem;
        address  owner;
        uint64   timestamp;
    }

    modifier can_buy(uint id) virtual {
        require(isOrderActive(id),_T101); 
        _;
    }

    modifier can_cancel(uint id) virtual {
        require(isOrderActive(id),_T101); 
        require(getOwner(id) == msg.sender/* _msgSender() */, _A100);
        _;
    }

    modifier can_offer virtual{
        _;
    }

    modifier synchronized {
        require(!locked, _S000);
        locked = true;
        _;
        locked = false;
    }

    // Tokens checks

    modifier checkOfferAmounts(uint _pay_amt, uint _buy_amt) {
        require(uint128(_pay_amt) == _pay_amt);
        require(uint128(_buy_amt) == _buy_amt);
        require(_pay_amt > 0);
        require(_buy_amt > 0);
        _;
    }

    modifier checkOfferTokens(IERC20 _pay_gem, IERC20 _buy_gem) virtual {
        // console2.log( "modifier checkOfferTokens:SimpleMarket" );

        require(address(_pay_gem) != NULL_ADDRESS, _F102);
        require(address(_buy_gem) != NULL_ADDRESS, _F102);
        // Tokens must be different
        require(_pay_gem != _buy_gem, _T107);
        _;
    }

    function isOrderActive(uint id) public view returns (bool active) {
        return offers[id].timestamp > 0;
    }

    function getOwner(uint id) public view returns (address owner) {
        return offers[id].owner;
    }

    function getOffer(uint id) public view returns (uint, IERC20, uint, IERC20) {
      OfferInfo memory offerInfo = offers[id];
      return (offerInfo.pay_amt, offerInfo.pay_gem,
              offerInfo.buy_amt, offerInfo.buy_gem);
    }

    // ---- Public entrypoints ---- //

    function bump(bytes32 id_)
        public
        can_buy(uint256(id_))
    {
        uint256 id = uint256(id_);
        emit LogBump(
            id_,
            keccak256(abi.encodePacked(offers[id].pay_gem, offers[id].buy_gem)),
            offers[id].owner,
            offers[id].pay_gem,
            offers[id].buy_gem,
            uint128(offers[id].pay_amt),
            uint128(offers[id].buy_amt),
            offers[id].timestamp
        );
    }

    // Accept given `quantity` of an offer. Transfers funds from caller to
    // offer maker, and from market to caller.
    function buy(uint id, uint quantity)
        public
        can_buy(id)
        synchronized
        virtual
        returns (bool)
    {
        require(uint128(quantity) == quantity, _F111);

        OfferInfo memory offerInfo = offers[id];
        uint spend = quantity * offerInfo.buy_amt / offerInfo.pay_amt;

        require(uint128(spend) == spend, _F112);

        // For backwards semantic compatibility.
        if (quantity == 0 || spend == 0 ||
            quantity > offerInfo.pay_amt || spend > offerInfo.buy_amt)
        {
            return false;
        }

        offers[id].pay_amt = offerInfo.pay_amt - quantity;
        offers[id].buy_amt = offerInfo.buy_amt - spend;
        // address msgSender = _msgSender();
        offerInfo.buy_gem.safeTransferFrom(msg.sender /*msgSender*/, offerInfo.owner, spend);
        offerInfo.pay_gem.safeTransfer(msg.sender /*msgSender*/, quantity);

        emit LogItemUpdate(id);
        emit LogTake(
            bytes32(id),
            keccak256(abi.encodePacked(offerInfo.pay_gem, offerInfo.buy_gem)),
            offerInfo.owner,
            offerInfo.pay_gem,
            offerInfo.pay_gem,
            msg.sender,
            uint128(quantity),
            uint128(spend),
            uint64(block.timestamp)
        );
        emit LogTrade(quantity, address(offerInfo.pay_gem), spend, address(offerInfo.buy_gem));

        if (offers[id].pay_amt == 0) {
          delete offers[id];
        }

        return true;
    }

    // Cancel an offer. Refunds offer maker.
    function cancel(uint id)
        public
        can_cancel(id)
        synchronized
        virtual
        returns (bool success)
    {
        // read-only offer. Modify an offer by directly accessing offers[id]
        OfferInfo memory offerInfo = offers[id];
        delete offers[id];

        offerInfo.pay_gem.safeTransfer(offerInfo.owner, offerInfo.pay_amt);

        emit LogItemUpdate(id);
        emit LogKill(
            bytes32(id),
            keccak256(abi.encodePacked(offerInfo.pay_gem, offerInfo.buy_gem)),
            offerInfo.owner,
            offerInfo.pay_gem,
            offerInfo.buy_gem,
            uint128(offerInfo.pay_amt),
            uint128(offerInfo.pay_amt),
            uint64(block.timestamp)
        );

        success = true;
    }

    function kill(bytes32 id)
        public
        virtual
    {
        require(cancel(uint256(id)));
    }

    function make(
        IERC20    pay_gem,
        IERC20    buy_gem,
        uint128  pay_amt,
        uint128  buy_amt
    )
        public
        virtual
        returns (bytes32 id)
    {
        return bytes32(offer(pay_amt, pay_gem, buy_amt, buy_gem));
    }

    // Make a new offer. Takes funds from the caller into market escrow.
    function offer(uint _pay_amt, IERC20 _pay_gem, uint _buy_amt, IERC20 _buy_gem)
        public
        can_offer
        checkOfferAmounts(_pay_amt, _buy_amt)
        checkOfferTokens(_pay_gem, _buy_gem)
        synchronized
        virtual
        returns (uint id)
    {
        // address msgSender = _msgSender();
        // console2.log( "last_offer_id=", last_offer_id );
        id = _next_id();
        // console2.log( "id=_next_id()=", id );

        offers[id] = OfferInfo(
            _pay_amt, _pay_gem, _buy_amt, _buy_gem, msg.sender/* msgSender */, uint64(block.timestamp)
        );

        _pay_gem.safeTransferFrom(msg.sender/* msgSender */, address(this), _pay_amt);

        emit LogItemUpdate(id);
        emit LogMake(
            bytes32(id),
            keccak256(abi.encodePacked(_pay_gem, _buy_gem)),
            msg.sender/* msgSender */,
            _pay_gem,
            _buy_gem,
            uint128(_pay_amt),
            uint128(_buy_amt),
            uint64(block.timestamp)
        );
    }

    function take(bytes32 id, uint128 maxTakeAmount)
        public
        virtual
    {
        require(buy(uint256(id), maxTakeAmount));
    }

    function _next_id()
        internal
        returns (uint)
    {
        return ++last_offer_id;
    }

} // contract SimpleMarket
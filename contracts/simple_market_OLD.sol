// SPDX-License-Identifier: AGPL-3.0-or-later

/// simple_market.sol

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

// pragma solidity >= 0.8.18 < 0.9.0;
// pragma solidity ^0.8.20;
pragma solidity ^0.8.18; // latest HH supported version

/*
import "ds-math/math.sol";
import "erc20/erc20.sol";
*/
//import "./erc20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
//import "@openzeppelin/contracts/utils/Address.sol";

contract EventfulMarket {
    event LogItemUpdate(uint id);
    event LogTrade(uint pay_amt, address indexed pay_gem,
                   uint buy_amt, address indexed buy_gem);

    event LogMake(
        bytes32  indexed  id,
        bytes32  indexed  pair,
        address  indexed  maker,
        ERC20             pay_gem,
        ERC20             buy_gem,
        uint128           pay_amt,
        uint128           buy_amt,
        uint64            timestamp
    );

    event LogBump(
        bytes32  indexed  id,
        bytes32  indexed  pair,
        address  indexed  maker,
        ERC20             pay_gem,
        ERC20             buy_gem,
        uint128           pay_amt,
        uint128           buy_amt,
        uint64            timestamp
    );

    event LogTake(
        bytes32           id,
        bytes32  indexed  pair,
        address  indexed  maker,
        ERC20             pay_gem,
        ERC20             buy_gem,
        address  indexed  taker,
        uint128           take_amt,
        uint128           give_amt,
        uint64            timestamp
    );

    event LogKill(
        bytes32  indexed  id,
        bytes32  indexed  pair,
        address  indexed  maker,
        ERC20             pay_gem,
        ERC20             buy_gem,
        uint128           pay_amt,
        uint128           buy_amt,
        uint64            timestamp
    );

}

contract ErrorCodes {
    // S Series = Security/Authorization
    string internal constant _S000 = "S000_REENTRANCY_ATTEMPT";

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

//contract SimpleMarket is EventfulMarket, DSMath {
contract SimpleMarket_OLD is EventfulMarket, ErrorCodes, Ownable {

    //using Address for address;
    address NULL_ADDRESS = address(0x0);

    uint public last_offer_id; // 0 when deployed

    mapping (uint => OfferInfo) public offers;

    bool locked; // Flag to re-entrancy attacks ; false by default

    ERC20 mainTradableToken; // ApidaeToken
    mapping (ERC20=>bool) tradableTokens; // mainTradableToken must not be in this list

    // error Locked();
    // error Unauthorized();

    /// Invalid Trading pair
    /// @param buyToken token to buy.
    /// @param sellToken token to sell.
    error InvalidTradingPair(ERC20 buyToken, ERC20 sellToken);
    error TestError();

    constructor(ERC20 _mainTradableToken) {
        mainTradableToken = _mainTradableToken;
    }
    

    struct OfferInfo {
        uint     pay_amt;
        ERC20    pay_gem;
        uint     buy_amt;
        ERC20    buy_gem;
        address  owner;
        uint64   timestamp;
    }

    modifier can_buy(uint id) virtual {
        // require(isActive(id));
        require(isOrderActive(id));
        _;
    }

    modifier can_cancel(uint id) virtual {
        // require(isActive(id));
        require(isOrderActive(id));
        require(getOwner(id) == msg.sender);
        // require(getOwner(id) == _msgSender());
        _;
    }

    modifier can_offer virtual{
        _;
    }

    modifier synchronized {
        // require(!locked, "Reentrancy attempt");
        require(!locked, _S000);
        locked = true;
        _;
        locked = false;
    }

    // Tokens checks

    modifier tokenAllowed(ERC20 erc20) {
        require(tradableTokens[erc20], "Token not authorized");
        _;
    }

    modifier checkOfferAmounts(uint _pay_amt, uint _buy_amt) {
        require(uint128(_pay_amt) == _pay_amt);
        require(uint128(_buy_amt) == _buy_amt);
        require(_pay_amt > 0);
        require(_buy_amt > 0);
        _;
    }

    modifier checkOfferTokens(ERC20 _pay_gem, ERC20 _buy_gem) {
        // Since tradable tokens are whitelisted, no need to check for address(0x0)
        //require(address(pay_gem) != address(0x0));
        //require(address(buy_gem) != address(0x0));
        // Tokens must be different
        // require(pay_gem != buy_gem);

        // Check for token : one must be mainTradableToken, other must be tradable
        // allow only:
        //  - mainTradableToken / tradableTokens[_buy_gem])
        //  - tradableTokens[_pay_gem]) / mainTradableToken

        /*
        // Sell mainTradableToken
        _pay_gem==mainTradableToken
        ?
        // Buy token must be tradable
        // require(tradableTokens[_buy_gem], "buy token not allowed")
        require(tradableTokens[_buy_gem], _T001)
        :
        // Buy mainTradableToken
        _buy_gem==mainTradableToken
            ?
            // Sold token must be tradable
            // require( tradableTokens[_pay_gem], "sell token not allowed" ):
            require( tradableTokens[_pay_gem], _T002 ):
            // mainTradableToken is neither sold or bought : revert
            // revert("wrong trading pair") ;
            revert(_T003) ;
            // revert InvalidTradingPair(_pay_gem, _buy_gem);
        */
        if (_pay_gem==mainTradableToken) {
            require(tradableTokens[_buy_gem], _T001);
        } else if (_buy_gem==mainTradableToken) {
            require(tradableTokens[_pay_gem], _T002);
        } else {
            revert InvalidTradingPair(_pay_gem, _buy_gem);
        }
        _;
    }


    // function isActive(uint id) public view returns (bool active) {
    function isOrderActive(uint id) public view returns (bool active) {
        return offers[id].timestamp > 0;
    }

    function getOwner(uint id) public view returns (address owner) {
        return offers[id].owner;
    }

    function getOffer(uint id) public view returns (uint, ERC20, uint, ERC20) {
      OfferInfo memory offerInfo = offers[id];
      return (offerInfo.pay_amt, offerInfo.pay_gem,
              offerInfo.buy_amt, offerInfo.buy_gem);
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
        // check is ERC20
        // check is ERC20
        // check is ERC20
        // check is ERC20
        // check is ERC20
        // check is ERC20
        tradableTokens[_erc20] = true;
    }

    function revokeToken(ERC20 _erc20) public onlyOwner tokenAllowed(_erc20) {
        // Allow to remove all tradable tokens
        // existing orders will remain active (no checks are made on buys)
        delete tradableTokens[_erc20];
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
        //OfferInfo memory offer = offers[id];
        OfferInfo memory offerInfo = offers[id];
        //uint spend = mul(quantity, offer.buy_amt) / offer.pay_amt;
        uint spend = quantity * offerInfo.buy_amt / offerInfo.pay_amt;


        require(uint128(spend) == spend);
        require(uint128(quantity) == quantity);

        // For backwards semantic compatibility.
        if (quantity == 0 || spend == 0 ||
            //quantity > offer.pay_amt || spend > offer.buy_amt)
            quantity > offerInfo.pay_amt || spend > offerInfo.buy_amt)
        {
            return false;
        }

        //offers[id].pay_amt = sub(offer.pay_amt, quantity);
        offers[id].pay_amt = offerInfo.pay_amt - quantity;
        //offers[id].buy_amt = sub(offer.buy_amt, spend);
        offers[id].pay_amt = offerInfo.pay_amt - quantity;

        // address msgSender = _msgSender();

        // safeTransferFrom(offer.buy_gem, msg.sender, offer.owner, spend);
        safeTransferFrom(offerInfo.buy_gem, msg.sender, offerInfo.owner, spend);
        // safeTransferFrom(offerInfo.buy_gem, msgSender, offerInfo.owner, spend);

        // safeTransfer(offer.pay_gem, msg.sender, quantity);
        safeTransfer(offerInfo.pay_gem, msg.sender, quantity);
        // safeTransfer(offerInfo.pay_gem, msgSender, quantity);

        emit LogItemUpdate(id);
        emit LogTake(
            bytes32(id),
            //keccak256(abi.encodePacked(offer.pay_gem, offer.buy_gem)),
            keccak256(abi.encodePacked(offerInfo.pay_gem, offerInfo.buy_gem)),
            //offer.owner,
            offerInfo.owner,
            //offer.pay_gem,
            offerInfo.pay_gem,
            //offer.buy_gem,
            offerInfo.pay_gem,
            msg.sender,
            // msgSender,
            uint128(quantity),
            uint128(spend),
            //uint64(now)
            uint64(block.timestamp)
        );
        //emit LogTrade(quantity, address(offer.pay_gem), spend, address(offer.buy_gem));
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
        //OfferInfo memory offer = offers[id];
        OfferInfo memory offerInfo = offers[id];
        delete offers[id];

        //safeTransfer(offer.pay_gem, offer.owner, offer.pay_amt);
        safeTransfer(offerInfo.pay_gem, offerInfo.owner, offerInfo.pay_amt);

        emit LogItemUpdate(id);
        emit LogKill(
            bytes32(id),
            //keccak256(abi.encodePacked(offer.pay_gem, offer.buy_gem)),
            keccak256(abi.encodePacked(offerInfo.pay_gem, offerInfo.buy_gem)),
            //offer.owner,
            offerInfo.owner,
            //offer.pay_gem,
            offerInfo.pay_gem,
            //offer.buy_gem,
            offerInfo.buy_gem,
            //uint128(offer.pay_amt),
            uint128(offerInfo.pay_amt),
            //uint128(offer.buy_amt),
            uint128(offerInfo.pay_amt),
            //uint64(now)
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
        ERC20    pay_gem,
        ERC20    buy_gem,
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
    function offer(uint _pay_amt, ERC20 _pay_gem, uint _buy_amt, ERC20 _buy_gem)
        public
        can_offer
        synchronized
        checkOfferAmounts(_pay_amt, _buy_amt)
        checkOfferTokens(_pay_gem, _buy_gem)
        virtual
        returns (uint id)
    {
        // Token amounts checked by modifier: checkOfferAmounts(pay_amt, buy_amt)
        //require(pay_gem != ERC20(0x0));
        //require(address(pay_gem) != address(0x0));
        //require(buy_gem != ERC20(0x0));
        //require(address(buy_gem) != address(0x0));

        // Tokens checked by modifier: checkOfferTokens(_pay_gem, _buy_gem)

        // Tokens must be different
       // require(pay_gem != buy_gem);

        /*
        // One must be main token
        require(pay_gem==mainTradableToken || buy_gem==mainTradableToken);
        // The other one must be allowed
        require( tradableTokens[pay_gem] || tradableTokens[buy_gem] , "trading token not allowed" );
        */

       /*
       if (pay_gem==mainTradableToken) { require( tradableTokens[buy_gem] , "token not allowed" ); }
       else if (buy_gem==mainTradableToken) { require( tradableTokens[buy_gem] , "token not allowed" ); }
       else { revert("wrong trading pair"); }
        */
       /*
       pay_gem==mainTradableToken
        ?
        require(tradableTokens[buy_gem])
        :
        buy_gem==mainTradableToken
            ?
            require( tradableTokens[pay_gem] , "token not allowed" ):
            revert("wrong trading pair") ;
        */

       address msgSender = _msgSender();

       /*
        OfferInfo memory info;
        info.pay_amt = _pay_amt;
        info.pay_gem = _pay_gem;
        info.buy_amt = _buy_amt;
        info.buy_gem = _buy_gem;
        info.owner = msg.sender;
        //info.timestamp = uint64(now);
        info.timestamp = uint64(block.timestamp);
        */
        
        id = _next_id();
        // offers[id] = info;
        offers[id] = OfferInfo(
            _pay_amt, _pay_gem, _buy_amt, _buy_gem, msgSender, uint64(block.timestamp)
        );

        safeTransferFrom(_pay_gem, msg.sender, address(this), _pay_amt);
        // safeTransferFrom(_pay_gem, msgSender, address(this), _pay_amt);
        

        emit LogItemUpdate(id);
        emit LogMake(
            bytes32(id),
            keccak256(abi.encodePacked(_pay_gem, _buy_gem)),
            msg.sender,
            // msgSender,
            _pay_gem,
            _buy_gem,
            uint128(_pay_amt),
            uint128(_buy_amt),
            //uint64(now)
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
        last_offer_id++; return last_offer_id;
    }

    function safeTransfer(ERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    /*
    function _callOptionalReturn(ERC20 token, bytes memory data) private {
        uint256 size;
        assembly { size := extcodesize(token) }
        require(size > 0, "Not a contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "Token call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
    */
    function _callOptionalReturn(ERC20 token, bytes memory data) private {
        /*
        uint256 size;
        assembly { size := extcodesize(token) }
        require(size > 0, "Not a contract");
        */
        // require(address(token).isContract());

        // call will revert in case of error
        (bool success, bytes memory returndata) = address(token).call(data);
        // check call success, revert if not
        require(success, "Token call failed");

        // if returndata > 0 it was a contract
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
        else {
            // returndata empty : check it was a contract
            require(address(token).code.length > 0, "Not a contract");
        }
    }

}
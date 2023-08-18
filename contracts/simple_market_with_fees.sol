// SPDX-License-Identifier: AGPL-3.0-or-later

/// simple_market_with_fees.sol


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

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./simple_market.sol";
import "./SimpleMarketConfigurationWithFees.sol";


contract SimpleMarketWithFeesErrorCodes {
    // Limits
    string internal constant _SMWFZCFG000 = "SimpleMarketWithFees: Configuration cannot be zero address";
    
}

contract SimpleMarketWithFeesEvents {

    event CollectFee(
        uint256 amount,
        IERC20 token
    );

    event WithdrawFees(
        uint256 amount,
        address recipient
    );
}

contract SimpleMarketWithFees is SimpleMarket, SimpleMarketWithFeesEvents, SimpleMarketWithFeesErrorCodes {

    using SafeERC20 for IERC20;

    SimpleMarketConfigurationWithFees public simpleMarketConfigurationWithFees;

    // mapping (address => Fee) public marketFee;

    // struct Fee {
    //      uint256 totalTransferFees;
    //      uint256 availableTransferFees;
    //  }


    // constructor(uint256 _marketFee, address _marketFeeCollector, uint256 _marketMaxFee, bool _buyFee, bool _sellFee) SimpleMarket() {
    // constructor(uint256 _marketFee, address _marketFeeCollector, uint256 _marketMaxFee, uint _buyFee, uint _sellFee) SimpleMarket() {
    constructor(SimpleMarketConfigurationWithFees _simpleMarketConfigurationWithFees) SimpleMarket() {    
        require( address(_simpleMarketConfigurationWithFees) != NULL_ADDRESS, _SMWFZCFG000);
        simpleMarketConfigurationWithFees = _simpleMarketConfigurationWithFees;
    }


    function withdrawFees() external {
        address marketFeeCollector = simpleMarketConfigurationWithFees.marketFeeCollector();
        require(msg.sender == marketFeeCollector || msg.sender == owner() , "Only fee collector or owner can call withdraw fees");

        // TODO : withdraw fees
        // TODO : withdraw fees
        // TODO : withdraw fees
        // TODO : withdraw fees
        // TODO : withdraw fees
        uint256 amount = 0;

        emit WithdrawFees(amount, marketFeeCollector);
        //ERC20.safeTransfer(msg.sender, amount);
    }

    // Accept given `quantity` of an offer. Transfers funds from caller to
    // offer maker, and from market to caller.
    function buy(uint id, uint quantity)
        public
        can_buy(id)
        synchronized
        virtual override
        returns (bool)
    {
        // Bought qty
        require(uint128(quantity) == quantity, _F111);

        OfferInfo memory offerInfo = offers[id];
        // Spent by buyer
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
        // offerInfo.buy_gem.safeTransferFrom(msg.sender /*msgSender*/, offerInfo.owner, spend);
        // offerInfo.pay_gem.safeTransfer(msg.sender /*msgSender*/, quantity);

        // Collect fees
        uint spendFee = simpleMarketConfigurationWithFees.calculateSellFee(spend);
        uint quantityFee = simpleMarketConfigurationWithFees.calculateBuyFee(quantity);
        console2.log("spendFee", spendFee);
        console2.log("quantityFee", quantityFee);

        // offer bought gem : Transfer from buyer to offerer : bought amount minus fees
        offerInfo.buy_gem.safeTransferFrom(msg.sender /*msgSender*/, offerInfo.owner, spend-spendFee);
        console2.log("sent ", spend-spendFee, " buy_gem  ", address(offerInfo.buy_gem) );
        console2.log("from Buyer", msg.sender, " to Offerer", offerInfo.owner);


        // offer bought gem : Transfer from buyer to this contract : fees
        if (spendFee > 0) {
            offerInfo.buy_gem.safeTransferFrom( msg.sender, address(this), spendFee);
            console2.log("sent ", spendFee, " buy_gem  ", address(offerInfo.buy_gem) );
            console2.log("from Buyer ", msg.sender, " to this contract ", address(this));
        }

        // offer sold gem : Transfer buyer sold gem to offerer : bought amount minus fees
        offerInfo.pay_gem.safeTransfer(msg.sender /*msgSender*/, quantity-quantityFee);
        console2.log("sent ", quantity-quantityFee, " pay_gem  ", address(offerInfo.pay_gem) );
        console2.log("from ", address(this), " to Buyer ", msg.sender);


        // offer sold gem : No need to transfer sold sold gem to this contract : fees remains in this contract
        console2.log(" keeping pay_gem", address(offerInfo.pay_gem),  " as fee for qty: ", quantityFee);

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
        if (spendFee > 0) {
            emit CollectFee(spendFee, offerInfo.buy_gem);
        }
        if (quantityFee > 0) {
            emit CollectFee(quantityFee, offerInfo.pay_gem);
        }
        emit LogTrade(quantity, address(offerInfo.pay_gem), spend, address(offerInfo.buy_gem));

        if (offers[id].pay_amt == 0) {
          delete offers[id];
        }

        return true;
    }

} // contract SimpleMarketWithFees
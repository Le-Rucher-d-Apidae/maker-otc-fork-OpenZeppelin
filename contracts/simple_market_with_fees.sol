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
import './simple_market_with_fees_constants.sol';


contract SimpleMarketWithFeesEvents {

    event CollectFee(
        uint256 amount,
        IERC20 token
    );

    event WithdrawFees(
        IERC20 token,
        uint256 amount,
        address recipient
    );
}

contract SimpleMarketWithFees is SimpleMarket, SimpleMarketWithFeesEvents {

    using SafeERC20 for IERC20;

    struct CollectedToken {
        IERC20 token;
        uint256 amount;
    }

    SimpleMarketConfigurationWithFees public simpleMarketConfigurationWithFees;
    // IERC20[] public collectedFeesTokensAddresses;
    CollectedToken[] public collectedTokensFees; // 0 index is not used
    mapping (IERC20 => uint256) public collectedFeesTokensAddressesToArrayIdx; // contains corresponding collectedTokensFees[INDEX] for an ERC20; 0 means not found
    // TODO : add collected fees quantity

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
        collectedTokensFees.push( CollectedToken(IERC20(NULL_ADDRESS), 0) ); // init : 0 index is not used
    }

    /**
     * dev Withdraw fees for <count> tokens starting from the last one
     * @param _maxWithdrawTokenCount : max number of tokens to withdraw
     */
    function withdrawFees(uint16 _maxWithdrawTokenCount) external {
        address marketFeeCollector = msg.sender;
        address cfgMarketFeeCollector = simpleMarketConfigurationWithFees.marketFeeCollector();
        require(marketFeeCollector == cfgMarketFeeCollector || marketFeeCollector == owner() , _SMWFZSEC001);
        // TODO : TEST withdraw fees
        // TODO : TEST withdraw fees
        // TODO : TEST withdraw fees
        // TODO : TEST withdraw fees
        // TODO : TEST withdraw fees
        uint16 count = 0;

        for (uint i = collectedTokensFees.length-1; i >= 0 && count <= _maxWithdrawTokenCount; i++) {
            // if (count >= _maxWithdrawTokenCount) {
            //     break;
            // }
            // IERC20 collectedFeesTokenAddress = collectedTokensFees[i];
            IERC20 collectedFeesTokenAddress = collectedTokensFees[i].token;
            
            uint256 amount = collectedFeesTokenAddress.balanceOf(address(this));
            if (amount == 0) { // Should not happen
                continue;
            }
            collectedFeesTokenAddress.safeTransfer( marketFeeCollector, amount );
            emit WithdrawFees( collectedFeesTokenAddress, amount, marketFeeCollector );
            collectedFeesTokensAddressesToArrayIdx[collectedFeesTokenAddress] = 0;
            collectedTokensFees.pop();
        } // for
        assert(collectedTokensFees.length > 0);
    } // withdrawFees

    /**
     * @dev Withdraw fees for given token address
     * @param _collectedFeesTokenAddress : token address to withdraw fees
     */
    function withdrawFees(IERC20 _collectedFeesTokenAddress // _tokenAddress
        ) external returns (uint256 withdrawnAmount) {
        address marketFeeCollector = msg.sender;
        address cfgMarketFeeCollector = simpleMarketConfigurationWithFees.marketFeeCollector();
        require(marketFeeCollector == cfgMarketFeeCollector || marketFeeCollector == owner() , _SMWFZSEC001);
        // TODO : TEST withdraw fees
        // TODO : TEST withdraw fees
        // TODO : TEST withdraw fees
        // TODO : TEST withdraw fees
        // TODO : TEST withdraw fees

        // IERC20 _collectedFeesTokenAddress = IERC20(_tokenAddress);
        console2.log( "withdrawFees: _tokenAddress= ", address(_collectedFeesTokenAddress) );
        require( collectedFeesTokensAddressesToArrayIdx[_collectedFeesTokenAddress] > 0, _SMWFZNTFND001);

        // Find token address in array
        // Shift array and delete last entry to remove token address
        console2.log( "withdrawFees: collectedTokensFees.length= ", collectedTokensFees.length );
        

        uint256 arrayLastIdx = collectedTokensFees.length-1;
        console2.log( "withdrawFees: arrayLastIdx= ", arrayLastIdx );
        // uint256 pos = 0;
        // uint256 amount = 0;
        for (uint256 i = 0; i <= arrayLastIdx; i++) {
            console2.log( "withdrawFees: for i = ", i );
            console2.log( "withdrawFees:  = collectedTokensFees[i].token= ", address(collectedTokensFees[i].token), " _collectedFeesTokenAddress= ", address(_collectedFeesTokenAddress) );
            if (collectedTokensFees[i].token == _collectedFeesTokenAddress) {
                // pos = i;
                // amount = collectedTokensFees[i].amount;
                withdrawnAmount = collectedTokensFees[i].amount;
                console2.log( "withdrawFees: for i = ", i, " withdrawnAmount=", withdrawnAmount );
                require(withdrawnAmount > 0, _SMWFZZRO001) ;
                // Shift entries
                for (uint256 j = i; j+1 < arrayLastIdx; j++) {
                    // console2.log( "withdrawFees: for j = ", j );
                    collectedTokensFees[j] = collectedTokensFees[j+1];
                }
                break;
            }
        } // for
        collectedTokensFees.pop();

        console2.log( "withdrawFees: _tokenAddress= ", address(_collectedFeesTokenAddress), " withdrawnAmount=", withdrawnAmount );

        _collectedFeesTokenAddress.safeTransfer( marketFeeCollector, withdrawnAmount );
        emit WithdrawFees( _collectedFeesTokenAddress, withdrawnAmount, marketFeeCollector );
        collectedFeesTokensAddressesToArrayIdx[_collectedFeesTokenAddress] = 0;

        assert(collectedTokensFees.length > 0);
    } // withdrawFees

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
        console2.log("buy: spendFee", spendFee);
        console2.log("buy: quantityFee", quantityFee);

        // offer bought gem : Transfer from buyer to offerer : bought amount minus fees
        offerInfo.buy_gem.safeTransferFrom(msg.sender /*msgSender*/, offerInfo.owner, spend-spendFee);
        console2.log("buy: sent ", spend-spendFee, " buy_gem  ", address(offerInfo.buy_gem) );
        console2.log("buy: from Buyer", msg.sender, " to Offerer", offerInfo.owner);


        // offer bought gem : Transfer from buyer to this contract : fees
        if (spendFee > 0) {
            offerInfo.buy_gem.safeTransferFrom( msg.sender, address(this), spendFee);
            console2.log("buy: sent ", spendFee, " buy_gem  ", address(offerInfo.buy_gem) );
            console2.log("buy: from Buyer ", msg.sender, " to this contract ", address(this));
        }

        // offer sold gem : Transfer buyer sold gem to offerer : bought amount minus fees
        offerInfo.pay_gem.safeTransfer(msg.sender /*msgSender*/, quantity-quantityFee);
        console2.log("buy: sent ", quantity-quantityFee, " pay_gem  ", address(offerInfo.pay_gem) );
        console2.log("buy: from ", address(this), " to Buyer ", msg.sender);


        // offer sold gem : No need to transfer sold sold gem to this contract : fees remains in this contract
        console2.log("buy: keeping pay_gem", address(offerInfo.pay_gem),  " as fee for qty: ", quantityFee);

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
            // add token address to fee collector addresses

            console2.log("buy: spendFee > 0  offerInfo.buy_gem", address(offerInfo.buy_gem), " collectedFeesTokensAddressesToArrayIdx[offerInfo.buy_gem]: index = ", collectedFeesTokensAddressesToArrayIdx[offerInfo.buy_gem]);

            if (collectedFeesTokensAddressesToArrayIdx[offerInfo.buy_gem] == 0) {

                console2.log("buy: spendFee > 0 NOT FOUND collectedTokensFees.length", collectedTokensFees.length);

                collectedTokensFees.push( CollectedToken(offerInfo.buy_gem, spendFee) );

                // ARRAY INDEX STARTS AT 1
                // ARRAY INDEX STARTS AT 1
                // ARRAY INDEX STARTS AT 1
                // ARRAY INDEX STARTS AT 1
                // ARRAY INDEX STARTS AT 1

                collectedFeesTokensAddressesToArrayIdx[offerInfo.buy_gem] = collectedTokensFees.length-1;
                // collectedTokensFees.push(offerInfo.buy_gem);
                // CollectedToken memory collectedToken = CollectedToken(offerInfo.buy_gem, spendFee);
            } else {
                // Find token array idx and add fees
                console2.log("buy: spendFee > 0 FOUND collectedTokensFees.length", collectedTokensFees.length, " collectedFeesTokensAddressesToArrayIdx[offerInfo.buy_gem] = index = " , collectedFeesTokensAddressesToArrayIdx[offerInfo.buy_gem] ) ;
                collectedTokensFees[ collectedFeesTokensAddressesToArrayIdx[offerInfo.buy_gem] ].amount += spendFee;
                console2.log("buy: spendFee > 0 FOUND collectedTokensFees[ collectedFeesTokensAddressesToArrayIdx[offerInfo.buy_gem] ].amount = ", collectedTokensFees[ collectedFeesTokensAddressesToArrayIdx[offerInfo.buy_gem] ].amount );
            }
            emit CollectFee(spendFee, offerInfo.buy_gem);
        }
        if (quantityFee > 0) {
            // add token address to fee collector addresses

            console2.log("buy: quantityFee > 0  offerInfo.buy_gem", address(offerInfo.pay_gem), " collectedFeesTokensAddressesToArrayIdx[offerInfo.buy_gem]: index = ", collectedFeesTokensAddressesToArrayIdx[offerInfo.pay_gem] );

            if (collectedFeesTokensAddressesToArrayIdx[offerInfo.pay_gem] == 0) {

                console2.log("buy: quantityFee > 0 NOT FOUND collectedTokensFees.length", collectedTokensFees.length);
                // ARRAY INDEX STARTS AT 1
                // ARRAY INDEX STARTS AT 1
                // ARRAY INDEX STARTS AT 1
                // ARRAY INDEX STARTS AT 1
                // ARRAY INDEX STARTS AT 1

                collectedTokensFees.push( CollectedToken(offerInfo.pay_gem, quantityFee) );
                collectedFeesTokensAddressesToArrayIdx[offerInfo.pay_gem] = collectedTokensFees.length-1;
                // collectedTokensFees.push(offerInfo.pay_gem);
                // CollectedToken memory collectedToken = CollectedToken(offerInfo.pay_gem, quantityFee);
                collectedTokensFees.push( CollectedToken(offerInfo.pay_gem, quantityFee) );
            } else {
                // Find token array idx and add fees
                console2.log("buy: spendFee > 0 FOUND collectedTokensFees.length", address(offerInfo.pay_gem), " collectedFeesTokensAddressesToArrayIdx[offerInfo.pay_gem] = index = ", collectedFeesTokensAddressesToArrayIdx[offerInfo.pay_gem] );
                collectedTokensFees[ collectedFeesTokensAddressesToArrayIdx[offerInfo.pay_gem] ].amount += quantityFee;
                console2.log("buy: spendFee > 0 FOUND collectedTokensFees[ collectedFeesTokensAddressesToArrayIdx[offerInfo.pay_gem] ].amount = ", collectedTokensFees[ collectedFeesTokensAddressesToArrayIdx[offerInfo.pay_gem] ].amount );
            }
            emit CollectFee(quantityFee, offerInfo.pay_gem);
        }
        emit LogTrade(quantity, address(offerInfo.pay_gem), spend, address(offerInfo.buy_gem));

        if (offers[id].pay_amt == 0) {
          delete offers[id];
        }

        return true;
    }

} // contract SimpleMarketWithFees
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

// pragma solidity >= 0.8.18 < 0.9.0;
// pragma solidity ^0.8.20;
pragma solidity ^0.8.18; // latest HH supported version

import "forge-std/console2.sol";

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./simple_market.sol";

contract SimpleMarketWithFees is SimpleMarket {

    using SafeERC20 for IERC20;

    // Fees
    // 1000000 = 100% Fee, 100000 = 10% Fee, 10000 = 1% Fee, 100 = 0.01% Fee, 1 = 0.0001% Fee
    uint256 public immutable MARKETMAXFEE;
    uint256 public marketFee;
    uint256 public buyFee;
    uint256 public sellFee;
    address public marketFeeCollector;
    mapping (address => bool) public marketFeeExemption;

    // mapping (address => Fee) public marketFee;

    event CollectFee(
        uint256 amount,
        IERC20 token,
        address recipient
    );

    event WithdrawFees(
        uint256 amount,
        address recipient
    );

    // struct Fee {
    //      uint256 totalTransferFees;
    //      uint256 availableTransferFees;
    //  }


    constructor(uint256 _marketFee, address _marketFeeCollector, uint256 _marketMaxFee, bool _buyFee, bool _sellFee) SimpleMarket() {
        MARKETMAXFEE = _marketMaxFee;
        require(_marketFee <= _marketMaxFee, "Fee percent too high");
        setMarketFee(_marketFee);
        setBuyAndSellFee(_buyFee, _sellFee);
        setMarketFeeCollector(_marketFeeCollector);
    }

    function setBuyAndSellFee(bool _buyFee, bool _sellFee) public onlyOwner {
        if (_buyFee) {
            if (_sellFee) {
                buyFee = marketFee/2;
                sellFee = marketFee/2;
                return;
            } else {
                buyFee = marketFee;
                sellFee = 0;
            }
        } else if (_sellFee) {
            buyFee = 0;
            sellFee = marketFee;
        }
    }

    function setMarketFeeExemption(address _address, bool _exempt) public onlyOwner {
        marketFeeExemption[_address] = _exempt;
    }

    function setMarketFee(uint256 _marketFee) public onlyOwner {
        require(_marketFee <= MARKETMAXFEE, "Fee percent too high");
        marketFee = _marketFee;
    }

    function setMarketFeeCollector(address  _marketFeeCollector) public onlyOwner {
        require(_marketFeeCollector != address(0), "Fee collector cannot be zero address");
        marketFeeCollector = _marketFeeCollector;
    }

    function withdrawFees() external {
        require(msg.sender == marketFeeCollector || msg.sender == owner() , "Only fee collector or owner can call withdraw fees");

        // TODO : Fees
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
        // offerInfo.buy_gem.safeTransferFrom(msg.sender /*msgSender*/, offerInfo.owner, spend);
        // offerInfo.pay_gem.safeTransfer(msg.sender /*msgSender*/, quantity);

        buyFee = 0;
        payFee = 0;

        // Collect fees
        offerInfo.buy_gem.safeTransferFrom(msg.sender /*msgSender*/, offerInfo.owner, spend);
        offerInfo.pay_gem.safeTransfer(msg.sender /*msgSender*/, quantity);

        // TODO : Fees
        // TODO : Fees
        // TODO : Fees
        // TODO : Fees
        // TODO : Fees
        // TODO : Fees

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

} // contract SimpleMarketWithFees
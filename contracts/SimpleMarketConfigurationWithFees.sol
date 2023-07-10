// SPDX-License-Identifier: AGPL-3.0-or-later

/// SimpleMarketConfigurationWithFees.sol

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

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../contracts/MarketsConstants.sol";
import "../contracts/MarketsConstantsFees.sol";
import "../contracts/matchingMarketConfiguration.sol";

contract SimpleMarketConfigurationWithFeesErrorCodes {
    // Limits
    string internal constant _MMWFLMT010 = "Market max fee too high.";
    string internal constant _MMWFLMT011 = "Market fee too high.";
    string internal constant _MMWFLMT020 = "Market buyFeeRatio fee too high.";
    string internal constant _MMWFLMT021 = "Market sellFeeRatio fee too high.";
    // Zero address
    string internal constant _MMWFZ000 = "Fee collector cannot be zero address.";
}

contract SimpleMarketConfigurationWithFeesEvents {
    event CollectFee(
        uint256 amount,
        IERC20 token
    );

}

contract SimpleMarketConfigurationWithFees is
    SimpleMarketConfigurationWithFeesErrorCodes, SimpleMarketConfigurationWithFeesEvents, Ownable {

    // address public constant NULL_ADDRESS = address(0x0);

    // Fees
    // 1000000 = 100% Fee, 100000 = 10% Fee, 10000 = 1% Fee, 100 = 0.01% Fee, 1 = 0.0001% Fee
    // uint256 public constant ONEHUNDREDPERCENT  = 1_000_000;
    uint256 public immutable MARKETMAXFEE;

    uint256 public marketFee;
    uint256 public buyFee;
    uint256 public sellFee;

    // Ratios
    uint256 public buyFeeRatio;
    uint256 public sellFeeRatio;

    // Fees collector
    address public marketFeeCollector;

    mapping (address => bool) public marketFeeExemption;

    // Represents total fee percent that gets taken on each trade
    // uint256 public totalFeePercent;
    // // Represents percent precision
    // uint256 public percentPrecision;

    constructor(
        uint256 _marketMaxFee,
        uint256 _marketFee,
        address _marketFeeCollector,
        uint _buyFee,
        uint _sellFee ) {

        MARKETMAXFEE = _marketMaxFee; // immutable must be set in constructor
        initialize( //_marketMaxFee,
         _marketFee,
         _marketFeeCollector,
         _buyFee,
         _sellFee);
    }

    /**
     * @notice Initialize function
     */
    function initialize(
        // uint256 _marketMaxFee,
        uint256 _marketFee,
        address _marketFeesCollector,
        uint _buyFeeRatio,
        uint _sellFeeRatio
    ) private onlyOwner
    {
        require(MARKETMAXFEE <= ONEHUNDREDPERCENT,_MMWFLMT010);
        // MARKETMAXFEE = _marketMaxFee;
        setMarketFeeCollector(_marketFeesCollector);
        setMarketBuyAndSellFeeRatios(_buyFeeRatio, _sellFeeRatio);
        setMarketFee(_marketFee);
        computeMarketBuyAndSellFees();
    }

    function setMarketFeeCollector(address  _marketFeeCollector) public onlyOwner {
        require(_marketFeeCollector != NULL_ADDRESS, _MMWFZ000);
        marketFeeCollector = _marketFeeCollector;
    }

    function setMarketFee(uint256 _marketFee) public onlyOwner {
        require(_marketFee <= MARKETMAXFEE, _MMWFLMT011);
        marketFee = _marketFee;
        setMarketBuyAndSellFeeRatios(buyFeeRatio, sellFeeRatio);
    }


    /**
     * @dev Set buy and sell fee
     * @param _buyFeeRatio  0 = no buy fee
     * @param _sellFeeRatio 0 = no sell fee
     * @notice Splits marketFee between buy and sell fee
     * @notice If buyFee and sellFee are both 0, then there is no fee
     */
    function setMarketBuyAndSellFeeRatios(uint _buyFeeRatio, uint _sellFeeRatio) public onlyOwner {
        require(_buyFeeRatio <= ONEHUNDREDPERCENT, _MMWFLMT020);
        require(_sellFeeRatio <= ONEHUNDREDPERCENT, _MMWFLMT021);

        buyFeeRatio = _buyFeeRatio;
        sellFeeRatio = _sellFeeRatio;
    }

    // function computeMarketBuyAndSellFees(uint _buyFeeRatio, uint _sellFeeRatio) public onlyOwner {
    function computeMarketBuyAndSellFees(/*uint _buyFeeRatio, uint _sellFeeRatio*/) private onlyOwner {

        // require(_buyFeeRatio <= ONEHUNDREDPERCENT, _MMWFLMT020);
        // require(_sellFeeRatio <= ONEHUNDREDPERCENT, _MMWFLMT021);

        // buyFeeRatio = _buyFeeRatio;
        // sellFeeRatio = _sellFeeRatio;

        if (marketFee == 0) {
            buyFee = 0;
            sellFee = 0;
        } else {
            if (buyFeeRatio>0) {
                if (sellFeeRatio>0) {
                    uint buyAndSell= buyFeeRatio+sellFeeRatio;
                    buyFee = marketFee * buyFeeRatio / buyAndSell;
                    sellFee = marketFee * sellFeeRatio / buyAndSell;
                    return;
                } else {
                    buyFee = marketFee; // 100% of marketFee
                    sellFee = 0;
                }
            } else if (sellFeeRatio>0) {
                buyFee = 0;
                sellFee = marketFee;
            } else if (marketFee>0) {
                revert("Both buy and sell fee cannot be 0 if market fee is not zero.");
            }
        } // marketFee > 0

        assert (buyFee+sellFee == marketFee);
    }

   function calculateBuyFee(uint256 amount) external view returns (uint256){
        return amount * buyFee / ONEHUNDREDPERCENT;
    }

   function calculateSellFee(uint256 amount) external view returns (uint256){
        return amount * sellFee / ONEHUNDREDPERCENT;
    }

    function setMarketFeeExemption(address _address, bool _exempt) public onlyOwner {
        marketFeeExemption[_address] = _exempt;
    }
}
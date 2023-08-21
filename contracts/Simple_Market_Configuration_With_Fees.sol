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

pragma solidity ^0.8.21;



import "forge-std/console2.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./constants/Markets__constants.sol";
import "./constants/Markets_Fees__constants.sol";
import "./constants/Simple_Market_Configuration_With_Fees__constants.sol";

import "./Matching_Market_Configuration.sol";

contract SimpleMarketConfigurationWithFeesEvents {
    event CollectFee(
        uint256 amount,
        IERC20 token
    );
    event ExemptMarketFee(
        address _address, // indexed
        bool _exempt
    );
}

contract SimpleMarketConfigurationWithFees is
    SimpleMarketConfigurationWithFeesEvents, Ownable {

    // address public constant NULL_ADDRESS = address(0x0);

    // Fees
    // 1000000 = 100% Fee, 100000 = 10% Fee, 10000 = 1% Fee, 100 = 0.01% Fee, 1 = 0.0001% Fee
    // uint256 public constant FEE_ONE_HUNDRED_PERCENT  = 1_000_000;
    uint256 public immutable MARKETMAXFEE;

    uint256 public marketFee;
    uint256 public buyFee;
    uint256 public sellFee;

    // Ratios
    uint256 public buyFeeRatio;
    uint256 public sellFeeRatio;

    // Fees collector
    address public marketFeeCollector;

    // TODO : TEST EXEMPTION
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
        console2.log("SimpleMarketConfigurationWithFees:initialize _marketFee", _marketFee);
        require(MARKETMAXFEE <= FEE_ONE_HUNDRED_PERCENT,_MMWFLMT010);
        require( (_marketFee == 0) || (_marketFee >= FEE_SMALLEST),_MMWFLMT000);
        
        // MARKETMAXFEE = _marketMaxFee;
        setMarketFeeCollector(_marketFeesCollector);

        // setMarketBuyAndSellFeeRatios(_buyFeeRatio, _sellFeeRatio);
        // setMarketFee(_marketFee);
        // computeMarketBuyAndSellFees();

        setMarketInitialBuyAndSellFeeRatios(_buyFeeRatio, _sellFeeRatio);
        setMarketFee(_marketFee/* , true */);
        // computeMarketBuyAndSellFees();

    }

    function setMarketFeeCollector(address  _marketFeeCollector) public onlyOwner {
        require(_marketFeeCollector != NULL_ADDRESS, _MMWFZ000);
        marketFeeCollector = _marketFeeCollector;
    }

    function setMarketFee(uint256 _marketFee /*, bool _compute*/) public onlyOwner {
        console2.log("setMarketFee _marketFee", _marketFee);
        require(_marketFee <= MARKETMAXFEE, _MMWFLMT011);
        marketFee = _marketFee;
        setMarketBuyAndSellFeeRatios(buyFeeRatio, sellFeeRatio, true);
        // if (_compute) {
        //     computeMarketBuyAndSellFees();
        // }
    }

    function setMarketInitialBuyAndSellFeeRatios(uint _buyFeeRatio, uint _sellFeeRatio) internal onlyOwner {
        setMarketBuyAndSellFeeRatios(_buyFeeRatio, _sellFeeRatio, false);
    }

    /**
     * @dev Set buy and sell fee
     * @param _buyFeeRatio  0 = no buy fee
     * @param _sellFeeRatio 0 = no sell fee
     * @notice Splits marketFee between buy and sell fee
     * @notice If buyFee and sellFee are both 0, then there is no fee
     */
    function setMarketBuyAndSellFeeRatios(uint _buyFeeRatio, uint _sellFeeRatio /*, bool _compute*/) public onlyOwner {
        // require(_buyFeeRatio <= FEE_ONE_HUNDRED_PERCENT, _MMWFLMT020);
        // require(_sellFeeRatio <= FEE_ONE_HUNDRED_PERCENT, _MMWFLMT021);

        // buyFeeRatio = _buyFeeRatio;
        // sellFeeRatio = _sellFeeRatio;
        // if (_compute) {
        //     computeMarketBuyAndSellFees();
        // }
        console2.log("public setMarketBuyAndSellFeeRatios _buyFeeRatio", _buyFeeRatio, "_sellFeeRatio", _sellFeeRatio);

        setMarketBuyAndSellFeeRatios(_buyFeeRatio, _sellFeeRatio, true);
    }

    function setMarketBuyAndSellFeeRatios(uint _buyFeeRatio, uint _sellFeeRatio, bool _compute) internal onlyOwner {

        console2.log("internal setMarketBuyAndSellFeeRatios _buyFeeRatio", _buyFeeRatio, "_sellFeeRatio", _sellFeeRatio);
        console2.log("internal setMarketBuyAndSellFeeRatios compute", _compute);

        require(_buyFeeRatio <= FEE_ONE_HUNDRED_PERCENT, _MMWFLMT020);
        require(_sellFeeRatio <= FEE_ONE_HUNDRED_PERCENT, _MMWFLMT021);

        buyFeeRatio = _buyFeeRatio;
        sellFeeRatio = _sellFeeRatio;
        if (_compute) {
            computeMarketBuyAndSellFees();
        }
    }

    // function computeMarketBuyAndSellFees(uint _buyFeeRatio, uint _sellFeeRatio) public onlyOwner {
    function computeMarketBuyAndSellFees(/*uint _buyFeeRatio, uint _sellFeeRatio*/) private onlyOwner {

        // require(_buyFeeRatio <= FEE_ONE_HUNDRED_PERCENT, _MMWFLMT020);
        // require(_sellFeeRatio <= FEE_ONE_HUNDRED_PERCENT, _MMWFLMT021);

        // buyFeeRatio = _buyFeeRatio;
        // sellFeeRatio = _sellFeeRatio;
        console2.log("computeMarketBuyAndSellFees--------START");

        if (marketFee == 0) {
            console2.log("computeMarketBuyAndSellFees:marketFee is 0");
            buyFee = 0;
            sellFee = 0;
        } else {
            if (buyFeeRatio>0) {
                console2.log("computeMarketBuyAndSellFees:buyFeeRatio>0: ", buyFeeRatio);
                if (sellFeeRatio>0) {
                    console2.log("computeMarketBuyAndSellFees:sellFeeRatio>0: ", sellFeeRatio);
                    uint buyAndSell= buyFeeRatio+sellFeeRatio;
                    console2.log("computeMarketBuyAndSellFees:buyAndSell: ", buyAndSell);
                    buyFee = marketFee * buyFeeRatio / buyAndSell;
                    console2.log("computeMarketBuyAndSellFees:buyFee: ", buyFee);
                    sellFee = marketFee * sellFeeRatio / buyAndSell;
                    console2.log("computeMarketBuyAndSellFees:sellFee: ", sellFee);
                    // return;
                } else {
                    console2.log("computeMarketBuyAndSellFees:sellFeeRatio==0: ", sellFeeRatio);
                    buyFee = marketFee; // 100% of marketFee
                    sellFee = 0;
                }
            } else if (sellFeeRatio>0) {
                console2.log("sellFeeRatio>0");
                console2.log("computeMarketBuyAndSellFees:buyFeeRatio==0: ", buyFeeRatio);
                console2.log("computeMarketBuyAndSellFees:sellFeeRatio>0: ", sellFeeRatio);
                buyFee = 0;
                sellFee = marketFee;
            } else if (marketFee>0) {
                revert("Both buy and sell fee cannot be 0 if market fee is not zero.");
            }
        } // marketFee > 0

        console2.log("computeMarketBuyAndSellFees:buyFee: ", buyFee);
        console2.log("computeMarketBuyAndSellFees:sellFee: ", sellFee);

        if (buyFee+sellFee < marketFee) {
            // adjust buyFee or sellFee to make sure buyFee+sellFee = marketFee
            if (buyFee<=sellFee) {
                buyFee += 1;
                console2.log("computeMarketBuyAndSellFees:buyFee: ", buyFee);
            } else {
                sellFee += 1;
                console2.log("computeMarketBuyAndSellFees:sellFee: ", sellFee);
            }
        }

        console2.log("computeMarketBuyAndSellFees:buyFee+sellFee: ", buyFee+sellFee);
        console2.log("computeMarketBuyAndSellFees:marketFee: ", marketFee);

        console2.log("computeMarketBuyAndSellFees--------END");

        assert (buyFee+sellFee == marketFee);
    }

   function calculateBuyFee(uint256 amount) external view returns (uint256){

    if (marketFeeExemption[msg.sender]) {
        console2.log("calculateBuyFee: marketFeeExemption[msg.sender] is true: EXEMPTION");
        return 0;
    }
    // TODO : TEST EXEMPTION

        console2.log("calculateBuyFee amount: ", amount, " buyFee: ", buyFee);
        console2.log("amount * buyFee / FEE_ONE_HUNDRED_PERCENT = buy fee amount: ", (amount * buyFee) / FEE_ONE_HUNDRED_PERCENT);
        return (amount * buyFee) / FEE_ONE_HUNDRED_PERCENT;
    }

   function calculateSellFee(uint256 amount) external view returns (uint256){
       console2.log("calculateSellFee amount:" , amount, " sellFee: ", sellFee);

    // TODO : TEST EXEMPTION

    if (marketFeeExemption[msg.sender]) {
        console2.log("calculateSellFee: marketFeeExemption[msg.sender] is true: EXEMPTION");
        return 0;
    }

        console2.log("amount * sellFee / FEE_ONE_HUNDRED_PERCENT = sell fee amount: ", (amount * sellFee) / FEE_ONE_HUNDRED_PERCENT);
        return (amount * sellFee) / FEE_ONE_HUNDRED_PERCENT;
    }

    function setMarketFeeExemption(address _address, bool _exempt) public onlyOwner {
        console2.log("setMarketFeeExemption: ", _address);
        emit ExemptMarketFee(_address, _exempt);
        marketFeeExemption[_address] = _exempt;
    }
}
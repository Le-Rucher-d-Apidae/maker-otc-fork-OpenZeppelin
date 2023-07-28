// SPDX-License-Identifier: AGPL-3.0-or-later

/// SimpleMarketConfigurationWithFees.t.sol

// pragma solidity >= 0.8.18 < 0.9.0;
// pragma solidity ^0.8.20;
pragma solidity ^0.8.18; // latest HH supported version


import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console2.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../contracts/MarketsConstantsFees.sol";
// import "../contracts/SimpleMarketConfigurationWithFees_Constants.sol";

import "../contracts/SimpleMarketConfigurationWithFees.sol";

import {VmCheat, DSTokenBase, SOMEMNEMONIC_01} from "./markets.t.sol";


contract SimpleMarketConfigurationWithFees_Constructor_Test is DSTest, VmCheat {
    
    address someUser;

    function setUp() public override {
        super.setUp();
        console2.log("SimpleMarketConfigurationWithFees_Test: setUp()");

        // uint256 somePrivateKey_99 = vm.deriveKey(SOMEMNEMONIC_01, 99);
        // someUser = vm.addr(somePrivateKey_99);
        someUser = someUser_99;
    }

    // constructor(
    //     uint256 _marketMaxFee,
    //     uint256 _marketFee,
    //     address _marketFeeCollector,
    //     uint _buyFee,
    //     uint _sellFee )

    function testSimpleMarketConfigurationWithFeesConstructorNullCollector() public {

        // Should fail on null address
        // FAIL. Reason: "Fee collector cannot be zero address."
        vm.expectRevert( bytes(_MMWFZ000) );

        SimpleMarketConfigurationWithFees simpleMarketConfigurationWithFees = new SimpleMarketConfigurationWithFees(
            10_000, // Max fee = 1.0%
            5000, // Current fee =  0.5%
            NULL_ADDRESS,
            1, // buy fee   = 50 % (buy fee/(buy fee+sell fee))
            1  // sell fee  = 50 % (sell fee/(buy fee+sell fee))
        );
        address(simpleMarketConfigurationWithFees) == NULL_ADDRESS; // remove "Unused local variable" warning
    }

    function testSimpleMarketConfigurationWithFeesConstructorOne() public {
        uint256 MARKETFEE = 5000;
        SimpleMarketConfigurationWithFees simpleMarketConfigurationWithFees = new SimpleMarketConfigurationWithFees(
            10_000, // Max fee = 1.0%
            MARKETFEE, // Current fee =  0.5%
            someUser,
            1, // buy fee   = 50 % (buy fee/(buy fee+sell fee))
            1  // sell fee  = 50 % (sell fee/(buy fee+sell fee))
        );
        assertTrue(address(simpleMarketConfigurationWithFees)!=NULL_ADDRESS);
        uint256 marketFee = simpleMarketConfigurationWithFees.marketFee();
        assertTrue(marketFee == MARKETFEE);
    }

    function testSimpleMarketConfigurationWithFeesConstructorZero() public {

        SimpleMarketConfigurationWithFees simpleMarketConfigurationWithFees = new SimpleMarketConfigurationWithFees(
            0, // Max fee = 0%
            0, // Current fee =  0%
            someUser,
            1000, // buy fee   = 50 % (buy fee/(buy fee+sell fee))
            1000  // sell fee  = 50 % (sell fee/(buy fee+sell fee))
        );
        assertTrue(address(simpleMarketConfigurationWithFees)!=NULL_ADDRESS);

    }

    function testSimpleMarketConfigurationWithFeesConstructorZero2() public {

        // Should fail : fee > Market max fee
        // FAIL. Reason: "Market fee too high."
        vm.expectRevert( bytes(_MMWFLMT011) );

        SimpleMarketConfigurationWithFees simpleMarketConfigurationWithFees = new SimpleMarketConfigurationWithFees(
            0, // Max fee = 0%
            1, // Current fee =  0%
            someUser,
            1000, // buy fee   = 50 % (buy fee/(buy fee+sell fee))
            1000  // sell fee  = 50 % (sell fee/(buy fee+sell fee))
        );
        assertTrue(address(simpleMarketConfigurationWithFees)!=NULL_ADDRESS);

    }

    function testSimpleMarketConfigurationWithFeesConstructorOneHundred() public {

        SimpleMarketConfigurationWithFees simpleMarketConfigurationWithFees = new SimpleMarketConfigurationWithFees(
            ONEHUNDREDPERCENT, // Max fee = 0%
            ONEHUNDREDPERCENT, // Current fee =  0%
            someUser,
            1000, // buy fee   = 50 % (buy fee/(buy fee+sell fee))
            1000  // sell fee  = 50 % (sell fee/(buy fee+sell fee))
        );
        assertTrue(address(simpleMarketConfigurationWithFees)!=NULL_ADDRESS);
        uint256 marketFee = simpleMarketConfigurationWithFees.marketFee();
        assertTrue(marketFee == ONEHUNDREDPERCENT);
    }

    function testSimpleMarketConfigurationWithFeesConstructorOneHundred2() public {

        uint256 MARKETFEE = 100;
        SimpleMarketConfigurationWithFees simpleMarketConfigurationWithFees = new SimpleMarketConfigurationWithFees(
            ONEHUNDREDPERCENT, // Max fee = 0%
            MARKETFEE, // Current fee =  0%
            someUser,
            1000, // buy fee   = 50 % (buy fee/(buy fee+sell fee))
            1000  // sell fee  = 50 % (sell fee/(buy fee+sell fee))
        );
        assertTrue(address(simpleMarketConfigurationWithFees)!=NULL_ADDRESS);
        uint256 marketFee = simpleMarketConfigurationWithFees.marketFee();
        assertTrue(marketFee == MARKETFEE);
    }

    function testSimpleMarketConfigurationWithFeesConstructorOneHundredPlus() public {

        // Should fail : Market max fee > 100%
        // FAIL. Reason: "Market max fee too high."
        vm.expectRevert( bytes(_MMWFLMT010) );

        SimpleMarketConfigurationWithFees simpleMarketConfigurationWithFees = new SimpleMarketConfigurationWithFees(
            ONEHUNDREDPERCENT+1, // Max fee > 100%
            0, // Current fee =  0%
            someUser,
            1000, // buy fee   = 50 % (buy fee/(buy fee+sell fee))
            1000  // sell fee  = 50 % (sell fee/(buy fee+sell fee))
        );
        address(simpleMarketConfigurationWithFees) == NULL_ADDRESS; // remove "Unused local variable" warning
    }

    function testSimpleMarketConfigurationWithFeesConstructorOneHundredPlusOverflow() public {

        // Should fail : overflow
        // FAIL. Reason: "Arithmetic over/underflow"
        
        vm.expectRevert();
        // vm.expectRevert("Arithmetic over/underflow");


        SimpleMarketConfigurationWithFees simpleMarketConfigurationWithFees = new SimpleMarketConfigurationWithFees(
            uint(type(uint256).max+ONEHUNDREDPERCENT), // Max fee > 100%
            0, // Current fee =  0%
            someUser,
            1000, // buy fee   = 50 % (buy fee/(buy fee+sell fee))
            1000  // sell fee  = 50 % (sell fee/(buy fee+sell fee))
        );
        address(simpleMarketConfigurationWithFees) == NULL_ADDRESS; // remove "Unused local variable" warning
    }

/*
    function testFailConstructor() public {
    }

*/

} // SimpleMarketConfigurationWithFees_Constructor_Test

contract SimpleMarketConfigurationWithFees_ZeroTests is DSTest, VmCheat {

    SimpleMarketConfigurationWithFees simpleMarketConfigurationWithFees;
    address someUser;
    uint256 constant MARKETMAXFEE = 0;

    function setUp() public override{
        super.setUp();
        console2.log("SimpleMarketConfigurationWithFeesTests: setUp()");

        // uint256 somePrivateKey_99 = vm.deriveKey(SOMEMNEMONIC_01, 99);
        // someUser = vm.addr(somePrivateKey_99);
        someUser = someUser_99;

        simpleMarketConfigurationWithFees = new SimpleMarketConfigurationWithFees(
            0, // Max fee = 0%
            0, // Current fee =  0%
            someUser,
            1000, // buy fee   = 50 % (buy fee/(buy fee+sell fee))
            1000  // sell fee  = 50 % (sell fee/(buy fee+sell fee))
        );
    }

    function testZeroFees1() public {

        // Should fail : Market fee > Market max fee
        // FAIL. Reason: "Market fee too high."
        vm.expectRevert( bytes(_MMWFLMT011) );
        simpleMarketConfigurationWithFees.setMarketFee(1);
    }

    function testZeroFeesCheckedOverflow0() public {

        // vm.expectRevert("Arithmetic over/underflow");
        vm.expectRevert();
        simpleMarketConfigurationWithFees.setMarketFee(type(uint256).max+1); // = 0

        // check fees are 0
        uint256 currentMarketFee = simpleMarketConfigurationWithFees.marketFee();
        console2.log("currentMarketFee", currentMarketFee);

        assertTrue(currentMarketFee == MARKETMAXFEE);
    }

    function testZeroFeesCheckedOverflow1() public {

        // vm.expectRevert("Arithmetic over/underflow");
        vm.expectRevert();
        simpleMarketConfigurationWithFees.setMarketFee(type(uint256).max+2); // = 1

        // check fees are 0
        uint256 currentMarketFee = simpleMarketConfigurationWithFees.marketFee();
        console2.log("currentMarketFee", currentMarketFee);

        assertTrue(currentMarketFee == MARKETMAXFEE);
    }

    function testZeroFeesUncheckedOverflow0() public {

        // vm.expectRevert("Arithmetic over/underflow");
        // vm.expectRevert("Arithmetic over/underflow");
        uint256 newMarketFee;
        unchecked {
            newMarketFee = type(uint256).max+1; // = 0
        }
        simpleMarketConfigurationWithFees.setMarketFee( newMarketFee );
        
        // check fees are 0
        uint256 currentMarketFee = simpleMarketConfigurationWithFees.marketFee();
        console2.log("currentMarketFee", currentMarketFee);

        assertTrue(currentMarketFee == MARKETMAXFEE);
    }

    function testZeroFeesUncheckedOverflow1() public {

        // vm.expectRevert("Arithmetic over/underflow");
        uint256 newMarketFee;
        unchecked {
            newMarketFee = type(uint256).max+2; // = 1
        }

        vm.expectRevert( bytes(_MMWFLMT011) );
        simpleMarketConfigurationWithFees.setMarketFee( newMarketFee );
        
        // check fees are 0
        uint256 currentMarketFee = simpleMarketConfigurationWithFees.marketFee();
        console2.log("currentMarketFee", currentMarketFee);

        assertTrue(currentMarketFee == MARKETMAXFEE);
        
    }

}

contract SimpleMarketConfigurationWithFees_MaxTests is DSTest, VmCheat {

    SimpleMarketConfigurationWithFees simpleMarketConfigurationWithFees;
    address someUser;
    uint256 constant MARKETMAXFEE = ONEHUNDREDPERCENT;
    uint256 constant MARKETINITIALFEE = 0;

    function setUp() public override{
        super.setUp();
        console2.log("SimpleMarketConfigurationWithFeesTests: setUp()");

        // uint256 somePrivateKey_99 = vm.deriveKey(SOMEMNEMONIC_01, 99);
        // someUser = vm.addr(somePrivateKey_99);
        someUser = someUser_33;

        simpleMarketConfigurationWithFees = new SimpleMarketConfigurationWithFees(
            MARKETMAXFEE, // Max fee = 100%
            MARKETINITIALFEE, // Current fee =  0%
            someUser,
            1000, // buy fee   = 50 % (buy fee/(buy fee+sell fee))
            1000  // sell fee  = 50 % (sell fee/(buy fee+sell fee))
        );
    }

    function testMaxFeesPlusOne() public {

        // Should fail : Market fee > Market max fee
        // FAIL. Reason: "Market fee too high."
        vm.expectRevert( bytes(_MMWFLMT011) );
        simpleMarketConfigurationWithFees.setMarketFee(ONEHUNDREDPERCENT+1);
    }

    function testMaxFeesMinusOne() public {
        uint256 previousMarketFee = simpleMarketConfigurationWithFees.marketFee();
        uint256 newMarketFee = ONEHUNDREDPERCENT-1;
        // Success
        simpleMarketConfigurationWithFees.setMarketFee(newMarketFee);

        // check fees
        uint256 currentMarketFee = simpleMarketConfigurationWithFees.marketFee();
        // console2.log("currentMarketFee", currentMarketFee);
        assertTrue(previousMarketFee == MARKETINITIALFEE);
        assertTrue(currentMarketFee == newMarketFee);
    }
    function testMaxFeesOnePercent() public {
        uint256 previousMarketFee = simpleMarketConfigurationWithFees.marketFee();
        uint256 newMarketFee = ONEPERCENT;

        simpleMarketConfigurationWithFees.setMarketFee(newMarketFee);

        // check fees
        uint256 currentMarketFee = simpleMarketConfigurationWithFees.marketFee();
        // console2.log("currentMarketFee", currentMarketFee);
        assertTrue(previousMarketFee == MARKETINITIALFEE);
        assertTrue(currentMarketFee == newMarketFee);
    }

    function testMaxFeesOneHundredPercent() public {
        uint256 previousMarketFee = simpleMarketConfigurationWithFees.marketFee();
        uint256 newMarketFee = ONEHUNDREDPERCENT;

        simpleMarketConfigurationWithFees.setMarketFee(newMarketFee);

        // check fees
        uint256 currentMarketFee = simpleMarketConfigurationWithFees.marketFee();
        // console2.log("currentMarketFee", currentMarketFee);
        assertTrue(previousMarketFee == MARKETINITIALFEE);
        assertTrue(currentMarketFee == newMarketFee);
    }

    function testFiftyPercentFees() public {
        uint256 previousMarketFee = simpleMarketConfigurationWithFees.marketFee();
        uint256 newMarketFee = ONEPERCENT*50;

        simpleMarketConfigurationWithFees.setMarketFee(newMarketFee);

        // check fees
        uint256 currentMarketFee = simpleMarketConfigurationWithFees.marketFee();
        // console2.log("currentMarketFee", currentMarketFee);
        assertTrue(previousMarketFee == MARKETINITIALFEE);
        assertTrue(currentMarketFee == newMarketFee);
    }

}

contract SimpleMarketConfigurationWithFees_CheckRatios is DSTest, VmCheat {

    SimpleMarketConfigurationWithFees simpleMarketConfigurationWithFees;
    address someUser;
    address someUser2;
    uint256 constant MARKETMAXFEE = ONEHUNDREDPERCENT;
    uint256 constant MARKETINITIALFEE = 0;
    uint constant BUYFEE = 1000;
    uint constant SELLFEE = 1000;

    function setUp() public override{
        super.setUp();
        console2.log("SimpleMarketConfigurationWithFeesTests: setUp()");

        // uint256 somePrivateKey_99 = vm.deriveKey(SOMEMNEMONIC_01, 99);
        // uint256 somePrivateKey_33 = vm.deriveKey(SOMEMNEMONIC_01, 33);
        // someUser = vm.addr(somePrivateKey_99);
        // someUser2 = vm.addr(somePrivateKey_33);

        someUser = someUser_33;
        someUser2 = someUser_99;

        simpleMarketConfigurationWithFees = new SimpleMarketConfigurationWithFees(
            MARKETMAXFEE, // Max fee = 1%
            MARKETINITIALFEE, // Current fee =  0%
            someUser,
            BUYFEE, // buy fee   = 50 % (buy fee/(buy fee+sell fee))
            SELLFEE  // sell fee  = 50 % (sell fee/(buy fee+sell fee))
        );

    }

    function testCurrentFees() public {

        uint marketFee = simpleMarketConfigurationWithFees.marketFee();
        assertTrue(marketFee == MARKETINITIALFEE);

        uint buyFee = simpleMarketConfigurationWithFees.buyFee();
        assertTrue(buyFee == MARKETINITIALFEE);

        uint sellFee = simpleMarketConfigurationWithFees.sellFee();
        assertTrue(sellFee == MARKETINITIALFEE);
    }


    function testMaxFeesOneHundredPercent_1Buy_1Sell_Ratios() public {
        uint256 previousMarketFee = simpleMarketConfigurationWithFees.marketFee();

        uint256 previous_buyFee = simpleMarketConfigurationWithFees.calculateBuyFee(1_000_000_000_000);
        uint256 previous_sellFee = simpleMarketConfigurationWithFees.calculateSellFee(1_000_000_000_000);

        uint256 newMarketFee = ONEHUNDREDPERCENT;

        simpleMarketConfigurationWithFees.setMarketFee(newMarketFee);

        // check fees
        uint256 currentMarketFee = simpleMarketConfigurationWithFees.marketFee();
        // console2.log("currentMarketFee", currentMarketFee);
        assertTrue(previousMarketFee == MARKETINITIALFEE);
        assertTrue(currentMarketFee == newMarketFee);

        assertTrue(previous_buyFee == 0);
        assertTrue(previous_sellFee == 0);

        uint256 current_buyFee = simpleMarketConfigurationWithFees.calculateBuyFee(2);
        console2.log("current_buyFee", current_buyFee);
        uint256 current_sellFee = simpleMarketConfigurationWithFees.calculateSellFee(2);
        console2.log("current_sellFee", current_sellFee);

        assertTrue(current_buyFee == 1);
        assertTrue(current_sellFee == 1);
    }

    function testMaxFeesOneHundredPercent_2Buy_1Sell_Ratios_part1() public {
        // Compiler error (/solidity/libsolidity/codegen/LValue.cpp:52):Stack too deep. Try
        uint256 previousMarketFee = simpleMarketConfigurationWithFees.marketFee();
        uint256 previous_buyFee_1_1 = simpleMarketConfigurationWithFees.calculateBuyFee(1_000_000_000_000);
        uint256 previous_sellFee_1_1 = simpleMarketConfigurationWithFees.calculateSellFee(1_000_000_000_000);

        // set buy and sell fee buy:sell ratios 2:1
        uint8 buyFeeRatio = 2;
        uint8 sellFeeRatio = 1;
        uint8 buySellFeeRatio = buyFeeRatio + sellFeeRatio;
        simpleMarketConfigurationWithFees.setMarketBuyAndSellFeeRatios(buyFeeRatio, sellFeeRatio);

        uint256 previous_buyFee_2_1 = simpleMarketConfigurationWithFees.calculateBuyFee(1_000_000_000_000);
        uint256 previous_sellFee_2_1 = simpleMarketConfigurationWithFees.calculateSellFee(1_000_000_000_000);

        uint256 newMarketFee = ONEHUNDREDPERCENT;

        simpleMarketConfigurationWithFees.setMarketFee(newMarketFee);

        // check fees
        uint256 currentMarketFee = simpleMarketConfigurationWithFees.marketFee();
        // console2.log("currentMarketFee", currentMarketFee);
        assertTrue(previousMarketFee == MARKETINITIALFEE);
        assertTrue(currentMarketFee == newMarketFee);

        assertTrue(previous_buyFee_1_1 == 0);
        assertTrue(previous_sellFee_1_1 == 0);

        assertTrue(previous_buyFee_2_1 == 0);
        assertTrue(previous_sellFee_2_1 == 0);

        uint256 testValue_1 = 9;

        uint256 current_buyFee_1 = simpleMarketConfigurationWithFees.calculateBuyFee(testValue_1); // = 9 * (2 / 2+1)
        // console2.log("current_buyFee_1", current_buyFee_1);
        uint256 current_sellFee_1 = simpleMarketConfigurationWithFees.calculateSellFee(testValue_1); // = 9 * (1 / 2+1)
        // console2.log("current_sellFee_1", current_sellFee_1);

        assertGe(current_buyFee_1, testValue_1*buyFeeRatio/buySellFeeRatio -1);
        assertLe(current_buyFee_1, testValue_1*buyFeeRatio/buySellFeeRatio +1);
        assertGe(current_sellFee_1, testValue_1*sellFeeRatio/buySellFeeRatio -1);
        assertLe(current_sellFee_1, testValue_1*sellFeeRatio/buySellFeeRatio +1);
    }

    function testMaxFeesOneHundredPercent_2Buy_1Sell_Ratios_part2() public {
        // set buy and sell fee buy:sell ratios 2:1
        uint8 buyFeeRatio = 2;
        uint8 sellFeeRatio = 1;
        uint8 buySellFeeRatio = buyFeeRatio + sellFeeRatio;
        simpleMarketConfigurationWithFees.setMarketBuyAndSellFeeRatios(buyFeeRatio, sellFeeRatio);

        uint256 newMarketFee = ONEHUNDREDPERCENT;

        simpleMarketConfigurationWithFees.setMarketFee(newMarketFee);

        uint256 testValue_2 = 10;

        uint256 current_buyFee_2 = simpleMarketConfigurationWithFees.calculateBuyFee(testValue_2); // = 10 * (2 / 2+1)
        // console2.log("current_buyFee_2", current_buyFee_2);
        uint256 current_sellFee2 = simpleMarketConfigurationWithFees.calculateSellFee(testValue_2); // = 10 * (1 / 2+1)
        // console2.log("current_sellFee2", current_sellFee2);

        assertGe(current_buyFee_2, testValue_2*buyFeeRatio/buySellFeeRatio -1);
        assertLe(current_buyFee_2, testValue_2*buyFeeRatio/buySellFeeRatio +1);
        assertGe(current_sellFee2, testValue_2*sellFeeRatio/buySellFeeRatio -1);
        assertLe(current_sellFee2, testValue_2*sellFeeRatio/buySellFeeRatio +1);

        uint256 testValue_3 = 1_000;

        uint256 current_buyFee_3 = simpleMarketConfigurationWithFees.calculateBuyFee(testValue_3); // = 1000 * (2 / 2+1)
        console2.log("current_buyFee_3", current_buyFee_3);
        uint256 current_sellFee_3 = simpleMarketConfigurationWithFees.calculateSellFee(testValue_3); // = 1000 * (1 / 2+1)
        console2.log("current_sellFee_3", current_sellFee_3);

        assertGe(current_buyFee_3, testValue_3*buyFeeRatio/buySellFeeRatio -1);
        assertLe(current_buyFee_3, testValue_3*buyFeeRatio/buySellFeeRatio +1);
        assertGe(current_sellFee_3, testValue_3*sellFeeRatio/buySellFeeRatio -1);
        assertLe(current_sellFee_3, testValue_3*sellFeeRatio/buySellFeeRatio +1);
    }

    function testFeesFiftyPercent_1Buy_1Sell_Ratios() public {
        uint256 previousMarketFee = simpleMarketConfigurationWithFees.marketFee();

        uint256 previous_buyFee = simpleMarketConfigurationWithFees.calculateBuyFee(1_000_000_000_000);
        uint256 previous_sellFee = simpleMarketConfigurationWithFees.calculateSellFee(1_000_000_000_000);

        uint256 newMarketFee = ONEPERCENT*50;

        simpleMarketConfigurationWithFees.setMarketFee(newMarketFee);

        // check fees
        uint256 currentMarketFee = simpleMarketConfigurationWithFees.marketFee();
        // console2.log("currentMarketFee", currentMarketFee);
        assertTrue(previousMarketFee == MARKETINITIALFEE);
        assertTrue(currentMarketFee == newMarketFee);

        assertTrue(previous_buyFee == 0);
        assertTrue(previous_sellFee == 0);

        uint256 current_buyFee = simpleMarketConfigurationWithFees.calculateBuyFee(4);
        console2.log("current_buyFee", current_buyFee);
        uint256 current_sellFee = simpleMarketConfigurationWithFees.calculateSellFee(4);
        console2.log("current_sellFee", current_sellFee);

        assertTrue(current_buyFee == 1);
        assertTrue(current_sellFee == 1);
    }

/*
    function testUpdateCurrentFees() public {

        simpleMarketConfigurationWithFees.setMarketFee(10_000); // 1%

        uint marketFee = simpleMarketConfigurationWithFees.marketFee();
        console2.log("marketFee", marketFee);
        assertTrue(marketFee == 0);

        uint buyFee = simpleMarketConfigurationWithFees.buyFee();
        console2.log("buyFee", buyFee);
        assertTrue(buyFee == 10_000 * BUYFEE / (BUYFEE + SELLFEE) );

        uint sellFee = simpleMarketConfigurationWithFees.sellFee();
        console2.log("sellFee", sellFee);
        assertTrue(sellFee == 10_000 * SELLFEE / (BUYFEE + SELLFEE) );
    }
*/

/*

    function testMaxFees1() public {

        simpleMarketConfigurationWithFees.setMarketFee(10000000);
        // should pass
        
    }

    function testMaxFees2() public {

        simpleMarketConfigurationWithFees.setMarketFee(1);
        // should pass
        
    }

    function testMaxFees3() public {

        simpleMarketConfigurationWithFees.setMarketFee(1);
        // check fees are 0
        
    }

*/
}

contract SimpleMarketConfigurationWithFees_CheckFeeCollector is DSTest, VmCheat {

    SimpleMarketConfigurationWithFees simpleMarketConfigurationWithFees;
    address someUser;
    address someUser2;
    uint constant BUYFEE = 1000;
    uint constant SELLFEE = 1000;

    function setUp() public override{
        super.setUp();
        console2.log("SimpleMarketConfigurationWithFeesTests: setUp()");

        uint256 somePrivateKey_99 = vm.deriveKey(SOMEMNEMONIC_01, 99);
        uint256 somePrivateKey_33 = vm.deriveKey(SOMEMNEMONIC_01, 33);
        someUser = vm.addr(somePrivateKey_99);
        someUser2 = vm.addr(somePrivateKey_33);

        simpleMarketConfigurationWithFees = new SimpleMarketConfigurationWithFees(
            10_000, // Max fee = 1%
            0, // Current fee =  0%
            someUser,
            BUYFEE, // buy fee   = 50 % (buy fee/(buy fee+sell fee))
            SELLFEE  // sell fee  = 50 % (sell fee/(buy fee+sell fee))
        );
    }

    function testCurrentFeeCollector() public {

        address marketFeeCollector = simpleMarketConfigurationWithFees.marketFeeCollector();
        assertTrue(marketFeeCollector == someUser);
        
    }

    function testUpdateFeeCollector() public {

        assertTrue(someUser2 != someUser);
        simpleMarketConfigurationWithFees.setMarketFeeCollector(someUser2);
        address marketFeeCollector = simpleMarketConfigurationWithFees.marketFeeCollector();
        assertTrue(marketFeeCollector == someUser2);

    }

}

contract SimpleMarketConfigurationWithFeesTests is DSTest, VmCheat {

    SimpleMarketConfigurationWithFees simpleMarketConfigurationWithFees;
    address someUser;
    uint constant BUYFEE = 1000;
    uint constant SELLFEE = 1000;

    function setUp() public override {
        super.setUp();
        console2.log("SimpleMarketConfigurationWithFees_Test: setUp()");

        uint256 somePrivateKey_99 = vm.deriveKey(SOMEMNEMONIC_01, 99);
        someUser = vm.addr(somePrivateKey_99);

        simpleMarketConfigurationWithFees = new SimpleMarketConfigurationWithFees(
            10_000, // Max fee = 1%
            0, // Current fee =  0%
            someUser,
            BUYFEE, // buy fee   = 50 % (buy fee/(buy fee+sell fee))
            SELLFEE  // sell fee  = 50 % (sell fee/(buy fee+sell fee))
        );
    }


    function testFeesRatioBuySellOk() public {

        simpleMarketConfigurationWithFees.setMarketBuyAndSellFeeRatios(ONEHUNDREDPERCENT, 0);
        simpleMarketConfigurationWithFees.setMarketBuyAndSellFeeRatios(0, ONEHUNDREDPERCENT);
        simpleMarketConfigurationWithFees.setMarketBuyAndSellFeeRatios(ONEHUNDREDPERCENT, ONEHUNDREDPERCENT);
    }

    function testFeesRatioBuyTooHigh() public {

        // Should fail : Market fee > Market max fee
        // FAIL. Reason: "Market fee too high."
        vm.expectRevert( bytes(_MMWFLMT020) );
        simpleMarketConfigurationWithFees.setMarketBuyAndSellFeeRatios(ONEHUNDREDPERCENT+1, 0);

        vm.expectRevert( bytes(_MMWFLMT021) );
        simpleMarketConfigurationWithFees.setMarketBuyAndSellFeeRatios(0, ONEHUNDREDPERCENT+1);

        vm.expectRevert( bytes(_MMWFLMT020) ); // Buy is checked first
        simpleMarketConfigurationWithFees.setMarketBuyAndSellFeeRatios(ONEHUNDREDPERCENT+1, ONEHUNDREDPERCENT+1);
    }

/* 
    function testFees2() public {

        simpleMarketConfigurationWithFees.setMarketBuyAndSellFeeRatios(1,1);
        // check fees are 50/50
        
    }

 */
}

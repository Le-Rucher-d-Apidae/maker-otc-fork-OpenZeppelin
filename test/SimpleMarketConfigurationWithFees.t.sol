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

import {VmCheat, DSTokenBase} from "./markets.t.sol";


contract SimpleMarketConfigurationWithFees_Constructor_Test is DSTest, VmCheat {
    
    address someUser;

    function setUp() public override {
        super.setUp();
        console2.log("SimpleMarketConfigurationWithFees_Test: setUp()");

        string memory someMnemonic = "test test test test test test test test test test test junk";
        uint256 somePrivateKey = vm.deriveKey(someMnemonic, 99);
        someUser = vm.addr(somePrivateKey);
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

    function setUp() public override{
        super.setUp();
        console2.log("SimpleMarketConfigurationWithFeesTests: setUp()");


        string memory someMnemonic = "test test test test test test test test test test test junk";
        uint256 somePrivateKey = vm.deriveKey(someMnemonic, 99);
        someUser = vm.addr(somePrivateKey);

        simpleMarketConfigurationWithFees = new SimpleMarketConfigurationWithFees(
            0, // Max fee > 100%
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

    // function testZeroFees2() public {

    //     simpleMarketConfigurationWithFees.setMarketFee(1);
    //     // check fees are 0
        
    // }
}


contract SimpleMarketConfigurationWithFees_CheckRatios is DSTest, VmCheat {

    SimpleMarketConfigurationWithFees simpleMarketConfigurationWithFees;
    address someUser;
    address someUser2;
    uint constant BUYFEE = 1000;
    uint constant SELLFEE = 1000;

    function setUp() public override{
        super.setUp();
        console2.log("SimpleMarketConfigurationWithFeesTests: setUp()");

        string memory someMnemonic = "test test test test test test test test test test test junk";
        uint256 somePrivateKey = vm.deriveKey(someMnemonic, 99);
        uint256 somePrivateKey2 = vm.deriveKey(someMnemonic, 33);
        someUser = vm.addr(somePrivateKey);
        someUser2 = vm.addr(somePrivateKey2);

        simpleMarketConfigurationWithFees = new SimpleMarketConfigurationWithFees(
            10_000, // Max fee = 1%
            0, // Current fee =  0%
            someUser,
            BUYFEE, // buy fee   = 50 % (buy fee/(buy fee+sell fee))
            SELLFEE  // sell fee  = 50 % (sell fee/(buy fee+sell fee))
        );

    }

    function testCurrentFees1() public {

        uint marketFee = simpleMarketConfigurationWithFees.marketFee();
        assertTrue(marketFee == 0);

        uint buyFee = simpleMarketConfigurationWithFees.buyFee();
        assertTrue(buyFee == 0);

        uint sellFee = simpleMarketConfigurationWithFees.sellFee();
        assertTrue(sellFee == 0);
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

        string memory someMnemonic = "test test test test test test test test test test test junk";
        uint256 somePrivateKey = vm.deriveKey(someMnemonic, 99);
        uint256 somePrivateKey2 = vm.deriveKey(someMnemonic, 33);
        someUser = vm.addr(somePrivateKey);
        someUser2 = vm.addr(somePrivateKey2);

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

        string memory someMnemonic = "test test test test test test test test test test test junk";
        uint256 somePrivateKey = vm.deriveKey(someMnemonic, 99);
        someUser = vm.addr(somePrivateKey);

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

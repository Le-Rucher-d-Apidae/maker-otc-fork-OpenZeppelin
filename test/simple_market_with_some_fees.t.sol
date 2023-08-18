// SPDX-License-Identifier: AGPL-3.0-or-later

/// simple_market_with_fees.t.sol

pragma solidity ^0.8.21;


import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console2.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../contracts/simple_market_with_fees.sol";
import "../contracts/SimpleMarketConfigurationWithFees.sol";

import {VmCheat, DSTokenBase} from "./markets.t.sol";

contract MarketTester {

    SimpleMarketWithFees market;

    constructor(SimpleMarketWithFees market_) {
        market = market_;
    }
    function doApprove(address spender, uint value, IERC20 token) public {
        token.approve(spender, value);
    }
    function doBuy(uint id, uint buy_how_much) public returns (bool _success) {
        return market.buy(id, buy_how_much);
    }
    function doCancel(uint id) public returns (bool _success) {
        return market.cancel(id);
    }
}

contract SimpleMarketWithSomeFees_Test is DSTest, VmCheat, EventfulMarket {
    MarketTester user1;
    IERC20 dai;
    IERC20 mkr;
    SimpleMarketWithFees otc;

    function setUp() public override {
        super.setUp();
        console2.log("SimpleMarketWithSomeFees_Test: setUp()");
        address feeCollector = someUser_22;

        SimpleMarketConfigurationWithFees simpleMarketConfigurationWithFees = new SimpleMarketConfigurationWithFees(
            2 * ONEPERCENT, // Max fee = 2%
            SMALLEST_FEE /* ONEPERCENT / 1000 */, // Current fee =  1%/1 000 = 0.001%
            feeCollector,
            1000, // buy fee   = 50 % (buy fee/(buy fee+sell fee)) = 0.0005%
            1000  // sell fee  = 50 % (sell fee/(buy fee+sell fee)) = 0.0005%
        );

        otc = new SimpleMarketWithFees(simpleMarketConfigurationWithFees);
        user1 = new MarketTester(otc);

        dai = new DSTokenBase(10 ** 9 * MKR_DECIMALS);
        mkr = new DSTokenBase(10 ** 6 * DAI_DECIMALS);
    }
    function testSmplMrktBasicTrade() public {
        dai.transfer(address(user1), 100 * DAI_DECIMALS);
        user1.doApprove(address(otc), 100 * DAI_DECIMALS, dai);
        mkr.approve(address(otc), 300 * MKR_DECIMALS);

        uint256 my_mkr_balance_before = mkr.balanceOf(address(this));
        uint256 my_dai_balance_before = dai.balanceOf(address(this));
        uint256 user1_mkr_balance_before = mkr.balanceOf(address(user1));
        uint256 user1_dai_balance_before = dai.balanceOf(address(user1));

        uint256 id = otc.offer(300 * MKR_DECIMALS, mkr, 100 * DAI_DECIMALS, dai);
        assertTrue(user1.doBuy(id, 300 * MKR_DECIMALS));
        uint256 my_mkr_balance_after = mkr.balanceOf(address(this));
        uint256 my_dai_balance_after = dai.balanceOf(address(this));
        uint256 user1_mkr_balance_after = mkr.balanceOf(address(user1));
        uint256 user1_dai_balance_after = dai.balanceOf(address(user1));

        assertEq(300 * MKR_DECIMALS, my_mkr_balance_before - my_mkr_balance_after);


        uint256 spent = 100 * DAI_DECIMALS; // ((300 * MKR_DECIMALS) * (100 * DAI_DECIMALS)) / (300 * MKR_DECIMALS) 
        uint spentFee = otc.simpleMarketConfigurationWithFees().calculateSellFee( spent );
        console2.log("spentFee", spentFee);


        uint256 bought = 300 * MKR_DECIMALS;
        uint boughtFee = otc.simpleMarketConfigurationWithFees().calculateBuyFee( bought );
        console2.log("boughtFee", boughtFee);

        assertEq( (100 * DAI_DECIMALS) - spentFee, my_dai_balance_after - my_dai_balance_before);

        assertEq( (300 * MKR_DECIMALS) - boughtFee, user1_mkr_balance_after - user1_mkr_balance_before);
        assertEq(100 * DAI_DECIMALS, user1_dai_balance_before - user1_dai_balance_after);

        // TODO: migrate Events checks
        // // expectEventsExact(address(otc)); // deprecated https://github.com/dapphub/dapptools/issues/18 https://dapple.readthedocs.io/en/master/test/
        // // emit LogItemUpdate(id);
        // // emit LogTrade(300, address(mkr), 100, address(dai));
        // // emit LogItemUpdate(id);

        // vm.expectEmit(true,false,false,false, address(otc));
        // emit LogItemUpdate(id);

        // vm.expectEmit(true,true,true,true, address(otc));
        // emit LogTrade(300, address(mkr), 100, address(dai));

        // vm.expectEmit(true,false,false,false, address(otc));
        // emit LogItemUpdate(id);
    }

/*

     function testSmplMrktPartiallyFilledOrderMkr() public {
        dai.transfer(address(user1), 300 * DAI_DECIMALS);
        user1.doApprove(address(otc), 300 * DAI_DECIMALS, dai);
        mkr.approve(address(otc), 200 * MKR_DECIMALS);

        uint256 my_mkr_balance_before = mkr.balanceOf(address(this));
        uint256 my_dai_balance_before = dai.balanceOf(address(this));
        uint256 user1_mkr_balance_before = mkr.balanceOf(address(user1));
        uint256 user1_dai_balance_before = dai.balanceOf(address(user1));

        uint256 id = otc.offer(200 * MKR_DECIMALS, mkr, 500 * DAI_DECIMALS, dai);
        assertTrue(user1.doBuy(id, 10 * MKR_DECIMALS));
        uint256 my_mkr_balance_after = mkr.balanceOf(address(this));
        uint256 my_dai_balance_after = dai.balanceOf(address(this));
        uint256 user1_mkr_balance_after = mkr.balanceOf(address(user1));
        uint256 user1_dai_balance_after = dai.balanceOf(address(user1));
        (uint256 sell_val, IERC20 sell_token, uint256 buy_val, IERC20 buy_token) = otc.getOffer(id);

        assertEq(200 * MKR_DECIMALS, my_mkr_balance_before - my_mkr_balance_after);
        assertEq(25 * DAI_DECIMALS, my_dai_balance_after - my_dai_balance_before);
        assertEq(10 * MKR_DECIMALS, user1_mkr_balance_after - user1_mkr_balance_before);
        assertEq(25 * DAI_DECIMALS, user1_dai_balance_before - user1_dai_balance_after);
        assertEq(190 * MKR_DECIMALS , sell_val);
        assertEq(475 * DAI_DECIMALS, buy_val);
        // assertTrue(address(sell_token) != address(0));
        // assertTrue(address(buy_token) != address(0));
        assertTrue(address(sell_token) != NULL_ADDRESS);
        assertTrue(address(buy_token) != NULL_ADDRESS);

        // TODO: migrate Events checks
        // // expectEventsExact(address(otc));
        // // emit LogItemUpdate(id);
        // // emit LogTrade(10, address(mkr), 25, address(dai));
        // // emit LogItemUpdate(id);

        // vm.expectEmit(true,false,false,false, address(otc));
        // emit LogItemUpdate(id);

        // vm.expectEmit(true,true,true,true, address(otc));
        // emit LogTrade(10, address(mkr), 25, address(dai));

        // vm.expectEmit(true,false,false,false, address(otc));
        // emit LogItemUpdate(id);
    }
    function testSmplMrktPartiallyFilledOrderDai() public {
        mkr.transfer(address(user1), 10 * MKR_DECIMALS ); // Move 10 MKR to user1
        user1.doApprove(address(otc), 10 * MKR_DECIMALS, mkr); // user1 approve spending 10 MKR to OTC
        dai.approve(address(otc), 500 * DAI_DECIMALS); // Approve 500 DAI to OTC

        uint256 my_mkr_balance_before = mkr.balanceOf(address(this));
        console.log("my_mkr_balance_before", my_mkr_balance_before);
        uint256 my_dai_balance_before = dai.balanceOf(address(this));
        console.log("my_dai_balance_before", my_dai_balance_before);
        uint256 user1_mkr_balance_before = mkr.balanceOf(address(user1));
        console.log("user1_mkr_balance_before", user1_mkr_balance_before);
        uint256 user1_dai_balance_before = dai.balanceOf(address(user1));
        console.log("user1_dai_balance_before", user1_dai_balance_before);

        // Offer : Sell 500 DAI, buy 200 MKR (buy DAI with MKR) 4 MKR = 10 DAI
        uint256 id = otc.offer(500 * DAI_DECIMALS, dai, 200 * MKR_DECIMALS, mkr);
        console.log("id", id);
        // Buy for 10 DAI of MKR (spend 4 MKR)
        assertTrue(user1.doBuy(id, 10 * DAI_DECIMALS));
        uint256 my_mkr_balance_after = mkr.balanceOf(address(this));
        console.log("my_mkr_balance_after", my_mkr_balance_after);
        uint256 my_dai_balance_after = dai.balanceOf(address(this));
        console.log("my_dai_balance_after", my_dai_balance_after);
        uint256 user1_mkr_balance_after = mkr.balanceOf(address(user1));
        console.log("user1_mkr_balance_after", user1_mkr_balance_after);
        uint256 user1_dai_balance_after = dai.balanceOf(address(user1));
        console.log("user1_dai_balance_after", user1_dai_balance_after);
        (uint256 sell_val, IERC20 sell_token, uint256 buy_val, IERC20 buy_token) = otc.getOffer(id);
        console.log("sell_val", sell_val, "buy_val", buy_val);

        assertEq(500 * DAI_DECIMALS, my_dai_balance_before - my_dai_balance_after);
        assertEq(4 * MKR_DECIMALS, my_mkr_balance_after - my_mkr_balance_before);
        assertEq(10 * DAI_DECIMALS, user1_dai_balance_after - user1_dai_balance_before);
        assertEq(4 * MKR_DECIMALS, user1_mkr_balance_before - user1_mkr_balance_after);
        assertEq(490 * DAI_DECIMALS, sell_val);
        assertEq(196 * MKR_DECIMALS, buy_val); // FAILS HERE

        // assertTrue(address(sell_token) != address(0));
        // assertTrue(address(buy_token) != address(0));
       assertTrue(address(sell_token) != NULL_ADDRESS);
       assertTrue(address(buy_token) != NULL_ADDRESS);

        // TODO: migrate Events checks
        // // expectEventsExact(address(otc));
        // // emit LogItemUpdate(id);
        // // emit LogTrade(10, address(dai), 4, address(mkr));
        // // emit LogItemUpdate(id);


        // vm.expectEmit(true,false,false,false, address(otc));
        // emit LogItemUpdate(id);

        // vm.expectEmit(true,true,true,true, address(otc));
        // emit LogTrade(10, address(dai), 4, address(mkr));

        // vm.expectEmit(true,false,false,false, address(otc));
        // emit LogItemUpdate(id);
    }
    function testSmplMrktPartiallyFilledOrderMkrExcessQuantity() public {
        dai.transfer(address(user1), 300 * DAI_DECIMALS);
        user1.doApprove(address(otc), 300 * DAI_DECIMALS, dai);
        mkr.approve(address(otc), 200 * MKR_DECIMALS);

        uint256 my_mkr_balance_before = mkr.balanceOf(address(this));
        uint256 my_dai_balance_before = dai.balanceOf(address(this));
        uint256 user1_mkr_balance_before = mkr.balanceOf(address(user1));
        uint256 user1_dai_balance_before = dai.balanceOf(address(user1));

        uint256 id = otc.offer(200 * MKR_DECIMALS, mkr, 500 * DAI_DECIMALS, dai);
        assertTrue(!user1.doBuy(id, 201 * MKR_DECIMALS));

        uint256 my_mkr_balance_after = mkr.balanceOf(address(this));
        uint256 my_dai_balance_after = dai.balanceOf(address(this));
        uint256 user1_mkr_balance_after = mkr.balanceOf(address(user1));
        uint256 user1_dai_balance_after = dai.balanceOf(address(user1));
        (uint256 sell_val, IERC20 sell_token, uint256 buy_val, IERC20 buy_token) = otc.getOffer(id);

        assertEq(0, my_dai_balance_before - my_dai_balance_after);
        assertEq(200 * MKR_DECIMALS, my_mkr_balance_before - my_mkr_balance_after);
        assertEq(0, user1_dai_balance_before - user1_dai_balance_after);
        assertEq(0, user1_mkr_balance_before - user1_mkr_balance_after);
        assertEq(200 * MKR_DECIMALS, sell_val);
        assertEq(500 * DAI_DECIMALS, buy_val);

        assertTrue(address(sell_token) != NULL_ADDRESS);
        assertTrue(address(buy_token) != NULL_ADDRESS);

        // TODO: migrate Events checks
        // // expectEventsExact(address(otc));
        // // emit LogItemUpdate(id);
        // vm.expectEmit(true,false,false,false, address(otc));
        // emit LogItemUpdate(id);
    }
    function testSmplMrktInsufficientlyFilledOrder() public {
        mkr.approve(address(otc), 300 * MKR_DECIMALS);
        uint256 id = otc.offer(300 * MKR_DECIMALS, mkr, 10 * DAI_DECIMALS, dai);

        dai.transfer(address(user1), 1 * DAI_DECIMALS);
        user1.doApprove(address(otc), 1 * DAI_DECIMALS, dai);
        // Buy value must be low enough to be rounded to zero in order to return false
        bool success = user1.doBuy(id, 1); // buy for (1 / DAI_DECIMALS) DAI of MKR
        assertTrue(!success);
    }
    function testSmplMrktCancel() public {
        mkr.approve(address(otc), 300 * MKR_DECIMALS);
        uint256 id = otc.offer(300 * MKR_DECIMALS, mkr, 100 * DAI_DECIMALS, dai);
        assertTrue(otc.cancel(id));

        // // TODO: migrate Events checks
        // // expectEventsExact(address(otc));
        // // emit LogItemUpdate(id);
        // // emit LogItemUpdate(id);
        // vm.expectEmit(true,false,false,false, address(otc));
        // emit LogItemUpdate(id);

        // vm.expectEmit(true,false,false,false, address(otc));
        // emit LogItemUpdate(id);
    }
    function testFailSmplMrktCancelNotOwner() public {
        mkr.approve(address(otc), 300 * MKR_DECIMALS);
        uint256 id = otc.offer(300 * MKR_DECIMALS, mkr, 100 * DAI_DECIMALS, dai);
        user1.doCancel(id);
    }
    function testFailSmplMrktCancelInactive() public {
        mkr.approve(address(otc), 300 * MKR_DECIMALS);
        uint256 id = otc.offer(300 * MKR_DECIMALS, mkr, 100 * DAI_DECIMALS, dai);
        assertTrue(otc.cancel(id));
        otc.cancel(id);
    }
    function testFailSmplMrktBuyInactive() public {
        mkr.approve(address(otc), 300 * MKR_DECIMALS);
        uint256 id = otc.offer(300 * MKR_DECIMALS, mkr, 100 * DAI_DECIMALS, dai);
        assertTrue(otc.cancel(id));
        otc.buy(id, 0);
    }
    function testFailSmplMrktOfferNotEnoughFunds() public {
        mkr.transfer(NULL_ADDRESS, mkr.balanceOf(address(this)) - 29);
        uint256 id = otc.offer(300 * MKR_DECIMALS, mkr, 100 * DAI_DECIMALS, dai);
        assertTrue(id >= 0);     //ugly hack to stop compiler from throwing a warning for unused var id
    }
    function testFailSmplMrktBuyNotEnoughFunds() public {
        uint256 id = otc.offer(300* MKR_DECIMALS, mkr, 101 * DAI_DECIMALS, dai);
        emit log_named_uint("user1 dai allowance", dai.allowance(address(user1), address(otc)));
        user1.doApprove(address(otc), 101* DAI_DECIMALS, dai);
        emit log_named_uint("user1 dai allowance", dai.allowance(address(user1), address(otc)));
        emit log_named_uint("user1 dai balance before", dai.balanceOf(address(user1)));
        assertTrue(user1.doBuy(id, 101 * DAI_DECIMALS));
        emit log_named_uint("user1 dai allowance", dai.allowance(address(user1), address(otc)));
        emit log_named_uint("user1 dai balance after", dai.balanceOf(address(user1)));
    }
    function testFailSmplMrktBuyNotEnoughApproval() public {
        uint256 id = otc.offer(300 * MKR_DECIMALS, mkr, 100 * DAI_DECIMALS, dai);
        emit log_named_uint("user1 dai allowance", dai.allowance(address(user1), address(otc)));
        user1.doApprove(address(otc), 99 * DAI_DECIMALS, dai);
        emit log_named_uint("user1 dai allowance", dai.allowance(address(user1), address(otc)));
        emit log_named_uint("user1 dai balance before", dai.balanceOf(address(user1)));
        assertTrue(user1.doBuy(id, 100 * DAI_DECIMALS));
        emit log_named_uint("user1 dai allowance", dai.allowance(address(user1), address(otc)));
        emit log_named_uint("user1 dai balance after", dai.balanceOf(address(user1)));
    }
    function testFailSmplMrktOfferSameToken() public {
        dai.approve(address(otc), 200 * DAI_DECIMALS);
        otc.offer(100 * DAI_DECIMALS, dai, 100 * DAI_DECIMALS, dai);
    }
    function testSmplMrktBuyTooMuch() public {
        mkr.approve(address(otc), 300 * MKR_DECIMALS);
        uint256 id = otc.offer(300 * MKR_DECIMALS, mkr, 100 * DAI_DECIMALS, dai);
        assertTrue(!otc.buy(id, 500 * DAI_DECIMALS));
    }
    function testFailSmplMrktOverflow() public {
        mkr.approve(address(otc), 300 * MKR_DECIMALS);
        uint256 id = otc.offer(300 * MKR_DECIMALS, mkr, 100 * DAI_DECIMALS, dai);
        // Overflow
        otc.buy(id, uint(type(uint256).max+1)); // otc.buy(id, uint(-1));
    }
    function testFailSmplMrktTransferFromEOA() public {
        otc.offer(300 * MKR_DECIMALS, IERC20(address(123)), 100 * DAI_DECIMALS, dai);
    }
*/
}

/*

contract TransferTest is DSTest, VmCheat {
    MarketTester user1;
    IERC20 dai;
    IERC20 mkr;
    SimpleMarketWithFees otc;

    function setUp() public override{
        super.setUp();
        console2.log("TransferTest: setUp()");
        address feeCollector = someUser_33;

        SimpleMarketConfigurationWithFees simpleMarketConfigurationWithZeroFees = new SimpleMarketConfigurationWithFees(
            0, // Max fee = 0%
            0, // Current fee =  0%
            feeCollector,
            1000, // buy fee   = 50 % (buy fee/(buy fee+sell fee))
            1000  // sell fee  = 50 % (sell fee/(buy fee+sell fee))
        );

        otc = new SimpleMarketWithFees(simpleMarketConfigurationWithZeroFees);
        user1 = new MarketTester(otc);

        dai = new DSTokenBase(10 ** 9 * DAI_DECIMALS);
        mkr = new DSTokenBase(10 ** 6 * DAI_DECIMALS);

        dai.transfer(address(user1), 100 * DAI_DECIMALS);
        user1.doApprove(address(otc), 100 * DAI_DECIMALS, dai);
        mkr.approve(address(otc), 300 * MKR_DECIMALS);
    }
}

contract SimpleMarketWithZeroFees_OfferTransferTest is TransferTest {
    function testSmplMrktOfferTransfersFromSeller() public {
        uint256 balance_before = mkr.balanceOf(address(this));
        uint256 id = otc.offer(300 * MKR_DECIMALS, mkr, 100 * DAI_DECIMALS, dai);
        uint256 balance_after = mkr.balanceOf(address(this));

        assertEq(balance_before - balance_after, 300 * MKR_DECIMALS);
        assertTrue(id > 0);
    }
    function testSmplMrktOfferTransfersToMarket() public {
        uint256 balance_before = mkr.balanceOf(address(otc));
        uint256 id = otc.offer(300 * MKR_DECIMALS, mkr, 100 * DAI_DECIMALS, dai);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_after - balance_before, 300 * MKR_DECIMALS);
        assertTrue(id > 0);
    }
}

contract SimpleMarketWithZeroFees_BuyTransferTest is TransferTest {
    function testSmplMrktBuyTransfersFromBuyer() public {
        uint256 id = otc.offer(300 * MKR_DECIMALS, mkr, 100 * DAI_DECIMALS, dai);

        uint256 balance_before = dai.balanceOf(address(user1));
        user1.doBuy(id, 300 * MKR_DECIMALS);
        uint256 balance_after = dai.balanceOf(address(user1));

        assertEq(balance_before - balance_after, 100 * DAI_DECIMALS);
    }
    function testSmplMrktBuyTransfersToSeller() public {
        uint256 id = otc.offer(300 * MKR_DECIMALS, mkr, 100 * DAI_DECIMALS, dai);

        uint256 balance_before = dai.balanceOf(address(this));
        user1.doBuy(id, 150 * DAI_DECIMALS);
        uint256 balance_after = dai.balanceOf(address(this));

        assertEq(balance_after - balance_before, 50 * DAI_DECIMALS);
    }
    function testSmplMrktBuyTransfersFromMarket() public {
        uint256 id = otc.offer(300 * MKR_DECIMALS, mkr, 100 * DAI_DECIMALS, dai);

        uint256 balance_before = mkr.balanceOf(address(otc));
        user1.doBuy(id, 300 * MKR_DECIMALS);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, 300 * MKR_DECIMALS);
    }
    function testSmplMrktBuyTransfersToBuyer() public {
        uint256 id = otc.offer(300, mkr, 100 * DAI_DECIMALS, dai);

        uint256 balance_before = mkr.balanceOf(address(user1));
        user1.doBuy(id, 300);
        uint256 balance_after = mkr.balanceOf(address(user1));

        assertEq(balance_after - balance_before, 300);
    }
}

contract SimpleMarketWithZeroFees_PartialBuyTransferTest is TransferTest {
    function testSmplMrktBuyTransfersFromBuyer_Partial() public {
        uint256 id = otc.offer(300 * MKR_DECIMALS, mkr, 100 * DAI_DECIMALS, dai);

        uint256 balance_before = dai.balanceOf(address(user1));
        user1.doBuy(id, 150 * MKR_DECIMALS);
        uint256 balance_after = dai.balanceOf(address(user1));

        assertEq(balance_before - balance_after, 50 * DAI_DECIMALS);
    }
    function testSmplMrktBuyTransfersToSeller_Partial() public {
        uint256 id = otc.offer(300 * MKR_DECIMALS, mkr, 100 * DAI_DECIMALS, dai);

        uint256 balance_before = dai.balanceOf(address(this));
        user1.doBuy(id, 150 * MKR_DECIMALS);
        uint256 balance_after = dai.balanceOf(address(this));

        assertEq(balance_after - balance_before, 50 * DAI_DECIMALS);
    }
    function testSmplMrktBuyTransfersFromMarket_Partial() public {
        uint256 id = otc.offer(300 * MKR_DECIMALS, mkr, 100 * DAI_DECIMALS, dai);

        uint256 balance_before = mkr.balanceOf(address(otc));
        user1.doBuy(id, 15 * MKR_DECIMALS);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, 15 * MKR_DECIMALS);
    }
    function testSmplMrktBuyTransfersToBuyer_Partial() public {
        uint256 id = otc.offer(300 * MKR_DECIMALS, mkr, 100 * DAI_DECIMALS, dai);

        uint256 balance_before = mkr.balanceOf(address(user1));
        user1.doBuy(id, 15 * MKR_DECIMALS);
        uint256 balance_after = mkr.balanceOf(address(user1));

        assertEq(balance_after - balance_before, 15 * MKR_DECIMALS);
    }
    function testSmplMrktBuyOddTransfersFromBuyer_Partial() public {
        uint256 id = otc.offer(300 * MKR_DECIMALS, mkr, 100 * DAI_DECIMALS, dai);

        uint256 balance_before = dai.balanceOf(address(user1));
        user1.doBuy(id, 180 * MKR_DECIMALS);
        uint256 balance_after = dai.balanceOf(address(user1));

        assertEq(balance_before - balance_after, 60 * DAI_DECIMALS);
    }
}

contract SimpleMarketWithZeroFees_CancelTransferTest is TransferTest {
    function testSmplMrktCancelTransfersFromMarket() public {
        uint256 id = otc.offer(300 * MKR_DECIMALS, mkr, 100 * DAI_DECIMALS, dai);

        uint256 balance_before = mkr.balanceOf(address(otc));
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, 300 * MKR_DECIMALS);
    }
    function testSmplMrktCancelTransfersToSeller() public {
        uint256 id = otc.offer(300 * MKR_DECIMALS, mkr, 100 * DAI_DECIMALS, dai);

        uint256 balance_before = mkr.balanceOf(address(this));
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(this));

        assertEq(balance_after - balance_before, 300 * MKR_DECIMALS);
    }
    function testSmplMrktCancelPartialTransfersFromMarket() public {
        uint256 id = otc.offer(300 * MKR_DECIMALS, mkr, 100 * DAI_DECIMALS, dai);
        user1.doBuy(id, 150 * MKR_DECIMALS);

        uint256 balance_before = mkr.balanceOf(address(otc));
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, 150 * MKR_DECIMALS);
    }
    function testSmplMrktCancelPartialTransfersToSeller() public {
        uint256 id = otc.offer(300 * MKR_DECIMALS, mkr, 100 * DAI_DECIMALS, dai);
        user1.doBuy(id, 150 * MKR_DECIMALS);

        uint256 balance_before = mkr.balanceOf(address(this));
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(this));

        assertEq(balance_after - balance_before, 150 * MKR_DECIMALS);
    }
}

contract SimpleMarketWithZeroFees_GasTest is DSTest, VmCheat {
    IERC20 dai;
    IERC20 mkr;
    SimpleMarket otc;
    uint id;

    function setUp() public override {
        super.setUp();
        console2.log("GasTest: setUp()");

        address feeCollector = someUser_66;

        SimpleMarketConfigurationWithFees simpleMarketConfigurationWithZeroFees = new SimpleMarketConfigurationWithFees(
            0, // Max fee = 0%
            0, // Current fee =  0%
            feeCollector,
            1, // buy fee   = 50 % (buy fee/(buy fee+sell fee))
            1  // sell fee  = 50 % (sell fee/(buy fee+sell fee))
        );

        otc = new SimpleMarketWithFees(simpleMarketConfigurationWithZeroFees);

        dai = new DSTokenBase(10 ** 9 * MKR_DECIMALS);
        mkr = new DSTokenBase(10 ** 6 * DAI_DECIMALS);

        mkr.approve(address(otc), 300*2 * MKR_DECIMALS );
        dai.approve(address(otc), 100 * DAI_DECIMALS );

        // console2.log("GasTest: setUp() - mkr.balanceOf: ", mkr.balanceOf( address(this) ) );

        id = otc.offer( 300 * MKR_DECIMALS  , mkr, 100 * DAI_DECIMALS, dai);
    }
    function testSmplMrktNewMarket()
        public
        logs_gas
    {
        address feeCollector = someUser_88;
        SimpleMarketConfigurationWithFees simpleMarketConfigurationWithZeroFees = new SimpleMarketConfigurationWithFees(
            0, // Max fee = 0%
            0, // Current fee =  0%
            feeCollector,
            1, // buy fee   = 50 % (buy fee/(buy fee+sell fee))
            1  // sell fee  = 50 % (sell fee/(buy fee+sell fee))
        );
        new SimpleMarketWithFees(simpleMarketConfigurationWithZeroFees);
    }
    function testSmplMrktNewOffer()
        public
        logs_gas
    {
        otc.offer(300 * MKR_DECIMALS, mkr, 100 * DAI_DECIMALS, dai);
    }
    function testSmplMrktBuy()
        public
        logs_gas
    {
        otc.buy(id, 300 * MKR_DECIMALS);
    }
    function testSmplMrktBuyPartial()
        public
        logs_gas
    {
        otc.buy(id, 150 * MKR_DECIMALS);
    }
    function testSmplMrktCancel()
        public
        logs_gas
    {
        otc.cancel(id);
    }
}
*/
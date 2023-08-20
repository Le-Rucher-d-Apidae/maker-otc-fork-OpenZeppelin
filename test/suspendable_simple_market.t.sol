

// SPDX-License-Identifier: AGPL-3.0-or-later

/// simple_market.t.sol

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


import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console2.sol";

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../contracts/Suspendable_Simple_Market.sol";

import {VmCheat, DSTokenBase} from "./markets.t.sol";

contract MarketTester {

    SuspendableSimpleMarket market;

    constructor(SuspendableSimpleMarket market_) {
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

// Exact same test as SimpleMarketTest, but with Suspend & Stop checks added

contract SuspendableSimpleMarket_Test is DSTest, VmCheat, EventfulMarket {
    MarketTester user1;
    IERC20 dai;
    IERC20 mkr;
    SuspendableSimpleMarket otc;

    function setUp() public override {
        super.setUp();
        console2.log("SuspendableSimpleMarketTest: setUp()");

        otc = new SuspendableSimpleMarket(false);
        user1 = new MarketTester(otc);

        dai = new DSTokenBase(10 ** 9);
        mkr = new DSTokenBase(10 ** 6);
    }
    function testSuspdblSmplMrktBasicTrade() public {
        dai.transfer(address(user1), 100);
        user1.doApprove(address(otc), 100, dai);
        mkr.approve(address(otc), 30);

        uint256 my_mkr_balance_before = mkr.balanceOf(address(this));
        uint256 my_dai_balance_before = dai.balanceOf(address(this));
        uint256 user1_mkr_balance_before = mkr.balanceOf(address(user1));
        uint256 user1_dai_balance_before = dai.balanceOf(address(user1));

        uint256 id = otc.offer(30, mkr, 100, dai);
        assertTrue(user1.doBuy(id, 30));
        uint256 my_mkr_balance_after = mkr.balanceOf(address(this));
        uint256 my_dai_balance_after = dai.balanceOf(address(this));
        uint256 user1_mkr_balance_after = mkr.balanceOf(address(user1));
        uint256 user1_dai_balance_after = dai.balanceOf(address(user1));
        assertEq(30, my_mkr_balance_before - my_mkr_balance_after);
        assertEq(100, my_dai_balance_after - my_dai_balance_before);
        assertEq(30, user1_mkr_balance_after - user1_mkr_balance_before);
        assertEq(100, user1_dai_balance_before - user1_dai_balance_after);

        // TODO: migrate Events checks

/* 
        // expectEventsExact(address(otc)); // deprecated https://github.com/dapphub/dapptools/issues/18 https://dapple.readthedocs.io/en/master/test/
        // emit LogItemUpdate(id);
        // emit LogTrade(30, address(mkr), 100, address(dai));
        // emit LogItemUpdate(id);

        vm.expectEmit(true,false,false,false, address(otc));
        emit LogItemUpdate(id);

        vm.expectEmit(true,true,true,true, address(otc));
        emit LogTrade(30, address(mkr), 100, address(dai));

        vm.expectEmit(true,false,false,false, address(otc));
        emit LogItemUpdate(id);

 */
    }
    function testSuspdblSmplMrktPartiallyFilledOrderMkr() public {
        dai.transfer(address(user1), 30);
        user1.doApprove(address(otc), 30, dai);
        mkr.approve(address(otc), 200);

        uint256 my_mkr_balance_before = mkr.balanceOf(address(this));
        uint256 my_dai_balance_before = dai.balanceOf(address(this));
        uint256 user1_mkr_balance_before = mkr.balanceOf(address(user1));
        uint256 user1_dai_balance_before = dai.balanceOf(address(user1));

        uint256 id = otc.offer(200, mkr, 500, dai);
        assertTrue(user1.doBuy(id, 10));
        uint256 my_mkr_balance_after = mkr.balanceOf(address(this));
        uint256 my_dai_balance_after = dai.balanceOf(address(this));
        uint256 user1_mkr_balance_after = mkr.balanceOf(address(user1));
        uint256 user1_dai_balance_after = dai.balanceOf(address(user1));
        (uint256 sell_val, IERC20 sell_token, uint256 buy_val, IERC20 buy_token) = otc.getOffer(id);

        assertEq(200, my_mkr_balance_before - my_mkr_balance_after);
        assertEq(25, my_dai_balance_after - my_dai_balance_before);
        assertEq(10, user1_mkr_balance_after - user1_mkr_balance_before);
        assertEq(25, user1_dai_balance_before - user1_dai_balance_after);
        assertEq(190, sell_val);
        assertEq(475, buy_val);
        // assertTrue(address(sell_token) != address(0));
        // assertTrue(address(buy_token) != address(0));
        assertTrue(address(sell_token) != NULL_ADDRESS);
        assertTrue(address(buy_token) != NULL_ADDRESS);

        // TODO: migrate Events checks
/* 
        // expectEventsExact(address(otc));
        // emit LogItemUpdate(id);
        // emit LogTrade(10, address(mkr), 25, address(dai));
        // emit LogItemUpdate(id);

        vm.expectEmit(true,false,false,false, address(otc));
        emit LogItemUpdate(id);

        vm.expectEmit(true,true,true,true, address(otc));
        emit LogTrade(10, address(mkr), 25, address(dai));

        vm.expectEmit(true,false,false,false, address(otc));
        emit LogItemUpdate(id);
 */
    }
    function testSuspdblSmplMrktPartiallyFilledOrderDai() public {
        mkr.transfer(address(user1), 10); // Move 10 MKR to user1
        user1.doApprove(address(otc), 10, mkr); // user1 approve spending 10 MKR to OTC
        dai.approve(address(otc), 500); // Approve 500 DAI to OTC

        uint256 my_mkr_balance_before = mkr.balanceOf(address(this));
        console.log("my_mkr_balance_before", my_mkr_balance_before);
        uint256 my_dai_balance_before = dai.balanceOf(address(this));
        console.log("my_dai_balance_before", my_dai_balance_before);
        uint256 user1_mkr_balance_before = mkr.balanceOf(address(user1));
        console.log("user1_mkr_balance_before", user1_mkr_balance_before);
        uint256 user1_dai_balance_before = dai.balanceOf(address(user1));
        console.log("user1_dai_balance_before", user1_dai_balance_before);

        // Offer : Sell 500 DAI, buy 200 MKR (buy DAI with MKR) 4 MKR = 10 DAI
        uint256 id = otc.offer(500, dai, 200, mkr);
        console.log("id", id);
        // Buy for 10 DAI of MKR (spend 4 MKR)
        assertTrue(user1.doBuy(id, 10));
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

        assertEq(500, my_dai_balance_before - my_dai_balance_after);
        assertEq(4, my_mkr_balance_after - my_mkr_balance_before);
        assertEq(10, user1_dai_balance_after - user1_dai_balance_before);
        assertEq(4, user1_mkr_balance_before - user1_mkr_balance_after);
        assertEq(490, sell_val);
        assertEq(196, buy_val); // FAILS HERE

        // assertTrue(address(sell_token) != address(0));
        // assertTrue(address(buy_token) != address(0));
       assertTrue(address(sell_token) != NULL_ADDRESS);
       assertTrue(address(buy_token) != NULL_ADDRESS);

        // TODO: migrate Events checks

/* 
        // expectEventsExact(address(otc));
        // emit LogItemUpdate(id);
        // emit LogTrade(10, address(dai), 4, address(mkr));
        // emit LogItemUpdate(id);


        vm.expectEmit(true,false,false,false, address(otc));
        emit LogItemUpdate(id);

        vm.expectEmit(true,true,true,true, address(otc));
        emit LogTrade(10, address(dai), 4, address(mkr));

        vm.expectEmit(true,false,false,false, address(otc));
        emit LogItemUpdate(id);
 */
    }
    function testSuspdblSmplMrktPartiallyFilledOrderMkrExcessQuantity() public {
        dai.transfer(address(user1), 30);
        user1.doApprove(address(otc), 30, dai);
        mkr.approve(address(otc), 200);

        uint256 my_mkr_balance_before = mkr.balanceOf(address(this));
        uint256 my_dai_balance_before = dai.balanceOf(address(this));
        uint256 user1_mkr_balance_before = mkr.balanceOf(address(user1));
        uint256 user1_dai_balance_before = dai.balanceOf(address(user1));

        uint256 id = otc.offer(200, mkr, 500, dai);
        assertTrue(!user1.doBuy(id, 201));

        uint256 my_mkr_balance_after = mkr.balanceOf(address(this));
        uint256 my_dai_balance_after = dai.balanceOf(address(this));
        uint256 user1_mkr_balance_after = mkr.balanceOf(address(user1));
        uint256 user1_dai_balance_after = dai.balanceOf(address(user1));
        (uint256 sell_val, IERC20 sell_token, uint256 buy_val, IERC20 buy_token) = otc.getOffer(id);

        assertEq(0, my_dai_balance_before - my_dai_balance_after);
        assertEq(200, my_mkr_balance_before - my_mkr_balance_after);
        assertEq(0, user1_dai_balance_before - user1_dai_balance_after);
        assertEq(0, user1_mkr_balance_before - user1_mkr_balance_after);
        assertEq(200, sell_val);
        assertEq(500, buy_val);
        // assertTrue(address(sell_token) != address(0));
        // assertTrue(address(buy_token) != address(0));
        assertTrue(address(sell_token) != NULL_ADDRESS);
        assertTrue(address(buy_token) != NULL_ADDRESS);

        // TODO: migrate Events checks

/* 
        // expectEventsExact(address(otc));
        // emit LogItemUpdate(id);

        vm.expectEmit(true,false,false,false, address(otc));
        emit LogItemUpdate(id);
 */
    }
    function testSuspdblSmplMrktInsufficientlyFilledOrder() public {
        mkr.approve(address(otc), 30);
        uint256 id = otc.offer(30, mkr, 10, dai);

        dai.transfer(address(user1), 1);
        user1.doApprove(address(otc), 1, dai);
        bool success = user1.doBuy(id, 1);
        assertTrue(!success);
    }
    function testSuspdblSmplMrktCancel() public {
        mkr.approve(address(otc), 30);
        uint256 id = otc.offer(30, mkr, 100, dai);
        assertTrue(otc.cancel(id));

        // TODO: migrate Events checks

/* 
        // expectEventsExact(address(otc));
        // emit LogItemUpdate(id);
        // emit LogItemUpdate(id);

        vm.expectEmit(true,false,false,false, address(otc));
        emit LogItemUpdate(id);

        vm.expectEmit(true,false,false,false, address(otc));
        emit LogItemUpdate(id);

 */
    }
    function testFailSuspdblSmplMrktCancelNotOwner() public {
        mkr.approve(address(otc), 30);
        uint256 id = otc.offer(30, mkr, 100, dai);
        user1.doCancel(id);
    }
    function testFailSuspdblSmplMrktCancelInactive() public {
        mkr.approve(address(otc), 30);
        uint256 id = otc.offer(30, mkr, 100, dai);
        assertTrue(otc.cancel(id));
        otc.cancel(id);
    }
    function testFailSuspdblSmplMrktBuyInactive() public {
        mkr.approve(address(otc), 30);
        uint256 id = otc.offer(30, mkr, 100, dai);
        assertTrue(otc.cancel(id));
        otc.buy(id, 0);
    }
    function testFailSuspdblSmplMrktOfferNotEnoughFunds() public {
        mkr.transfer(NULL_ADDRESS, mkr.balanceOf(address(this)) - 29);
        uint256 id = otc.offer(30, mkr, 100, dai);
        assertTrue(id >= 0);     //ugly hack to stop compiler from throwing a warning for unused var id
    }
    function testFailSuspdblSmplMrktBuyNotEnoughFunds() public {
        uint256 id = otc.offer(30, mkr, 101, dai);
        emit log_named_uint("user1 dai allowance", dai.allowance(address(user1), address(otc)));
        user1.doApprove(address(otc), 101, dai);
        emit log_named_uint("user1 dai allowance", dai.allowance(address(user1), address(otc)));
        emit log_named_uint("user1 dai balance before", dai.balanceOf(address(user1)));
        assertTrue(user1.doBuy(id, 101));
        emit log_named_uint("user1 dai allowance", dai.allowance(address(user1), address(otc)));
        emit log_named_uint("user1 dai balance after", dai.balanceOf(address(user1)));
    }
    function testFailSuspdblSmplMrktBuyNotEnoughApproval() public {
        uint256 id = otc.offer(30, mkr, 100, dai);
        emit log_named_uint("user1 dai allowance", dai.allowance(address(user1), address(otc)));
        user1.doApprove(address(otc), 99, dai);
        emit log_named_uint("user1 dai allowance", dai.allowance(address(user1), address(otc)));
        emit log_named_uint("user1 dai balance before", dai.balanceOf(address(user1)));
        assertTrue(user1.doBuy(id, 100));
        emit log_named_uint("user1 dai allowance", dai.allowance(address(user1), address(otc)));
        emit log_named_uint("user1 dai balance after", dai.balanceOf(address(user1)));
    }
    function testFailSuspdblSmplMrktOfferSameToken() public {
        dai.approve(address(otc), 200);
        otc.offer(100, dai, 100, dai);
    }
    function testSuspdblSmplMrktBuyTooMuch() public {
        mkr.approve(address(otc), 30);
        uint256 id = otc.offer(30, mkr, 100, dai);
        assertTrue(!otc.buy(id, 50));
    }
    function testFailSuspdblSmplMrktOverflow() public {
        mkr.approve(address(otc), 30);
        uint256 id = otc.offer(30, mkr, 100, dai);
        otc.buy(id, uint(type(uint256).max+1));
    }
    function testFailSuspdblSmplMrktTransferFromEOA() public {
        otc.offer(30, IERC20(address(123)), 100, dai);
    }
}

// ----------------------------------------------------------------------------

// Same tests as Simple market (market is NOT suspended or closed)

contract TransferTest_OpenMarket is DSTest, VmCheat {
    MarketTester user1;
    IERC20 dai;
    IERC20 mkr;
    SuspendableSimpleMarket otc;

    function setUp() public override{
        super.setUp();
        console2.log("TransferTest_OpenMarket: setUp()");

        otc = new SuspendableSimpleMarket(false);
        user1 = new MarketTester(otc);

        dai = new DSTokenBase(10 ** 9);
        mkr = new DSTokenBase(10 ** 6);

        dai.transfer(address(user1), 100);
        user1.doApprove(address(otc), 100, dai);
        mkr.approve(address(otc), 30);
    }
}

contract SuspendableSimpleMarket_OfferTransferTestOpened is TransferTest_OpenMarket {
    function testSuspdblSmplMrktOfferTransfersFromSeller() public {
        uint256 balance_before = mkr.balanceOf(address(this));
        uint256 id = otc.offer(30, mkr, 100, dai);
        uint256 balance_after = mkr.balanceOf(address(this));

        assertEq(balance_before - balance_after, 30);
        assertTrue(id > 0);
    }
    function testSuspdblSmplMrktOfferTransfersToMarket() public {
        uint256 balance_before = mkr.balanceOf(address(otc));
        uint256 id = otc.offer(30, mkr, 100, dai);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_after - balance_before, 30);
        assertTrue(id > 0);
    }
}

contract SuspendableSimpleMarket_BuyTransferTestOpened is TransferTest_OpenMarket {
    function testSuspdblSmplMrktBuyTransfersFromBuyer() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(user1));
        user1.doBuy(id, 30);
        uint256 balance_after = dai.balanceOf(address(user1));

        assertEq(balance_before - balance_after, 100);
    }
    function testSuspdblSmplMrktBuyTransfersToSeller() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(this));
        user1.doBuy(id, 30);
        uint256 balance_after = dai.balanceOf(address(this));

        assertEq(balance_after - balance_before, 100);
    }
    function testSuspdblSmplMrktBuyTransfersFromMarket() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(otc));
        user1.doBuy(id, 30);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, 30);
    }
    function testSuspdblSmplMrktBuyTransfersToBuyer() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(user1));
        user1.doBuy(id, 30);
        uint256 balance_after = mkr.balanceOf(address(user1));

        assertEq(balance_after - balance_before, 30);
    }
}

contract SuspendableSimpleMarket_PartialBuyTransferTestOpened is TransferTest_OpenMarket {
    function testSuspdblSmplMrktBuyTransfersFromBuyer() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(user1));
        user1.doBuy(id, 15);
        uint256 balance_after = dai.balanceOf(address(user1));

        assertEq(balance_before - balance_after, 50);
    }
    function testSuspdblSmplMrktBuyTransfersToSeller() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(this));
        user1.doBuy(id, 15);
        uint256 balance_after = dai.balanceOf(address(this));

        assertEq(balance_after - balance_before, 50);
    }
    function testSuspdblSmplMrktBuyTransfersFromMarket() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(otc));
        user1.doBuy(id, 15);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, 15);
    }
    function testSuspdblSmplMrktBuyTransfersToBuyer() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(user1));
        user1.doBuy(id, 15);
        uint256 balance_after = mkr.balanceOf(address(user1));

        assertEq(balance_after - balance_before, 15);
    }
    function testSuspdblSmplMrktBuyOddTransfersFromBuyer() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(user1));
        user1.doBuy(id, 17);
        uint256 balance_after = dai.balanceOf(address(user1));

        assertEq(balance_before - balance_after, 56);
    }
}

contract SuspendableSimpleMarket_CancelTransferTestOpened is TransferTest_OpenMarket {
    function testSuspdblSmplMrktCancelTransfersFromMarket() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(otc));
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, 30);
    }
    function testSuspdblSmplMrktCancelTransfersToSeller() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(this));
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(this));

        assertEq(balance_after - balance_before, 30);
    }
    function testSuspdblSmplMrktCancelPartialTransfersFromMarket() public {
        uint256 id = otc.offer(30, mkr, 100, dai);
        user1.doBuy(id, 15);

        uint256 balance_before = mkr.balanceOf(address(otc));
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, 15);
    }
    function testSuspdblSmplMrktCancelPartialTransfersToSeller() public {
        uint256 id = otc.offer(30, mkr, 100, dai);
        user1.doBuy(id, 15);

        uint256 balance_before = mkr.balanceOf(address(this));
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(this));

        assertEq(balance_after - balance_before, 15);
    }
}

// ----------------------------------------------------------------------------

// Same tests as above, but with the market suspended

contract TransferTest_SuspendedMarket is DSTest, VmCheat {
    MarketTester user1;
    IERC20 dai;
    IERC20 mkr;
    SuspendableSimpleMarket otc;

    function setUp() public override{
        super.setUp();
        console2.log("TransferTest_SuspendedMarket: setUp()");

        otc = new SuspendableSimpleMarket(true);
        user1 = new MarketTester(otc);

        dai = new DSTokenBase(10 ** 9);
        mkr = new DSTokenBase(10 ** 6);

        dai.transfer(address(user1), 100);
        user1.doApprove(address(otc), 100, dai);
        mkr.approve(address(otc), 30);
    }
}

contract SuspendableSimpleMarket_OfferTransferTestSuspended is TransferTest_SuspendedMarket {
    function testFailSuspndSuspdblSmplMrktOfferTransfersFromSeller() public {
        uint256 balance_before = mkr.balanceOf(address(this));
        uint256 id = otc.offer(30, mkr, 100, dai);
        uint256 balance_after = mkr.balanceOf(address(this));

        assertEq(balance_before - balance_after, 30);
        assertTrue(id > 0);
    }
    function testFailSuspndSuspdblSmplMrktOfferTransfersToMarket() public {
        uint256 balance_before = mkr.balanceOf(address(otc));
        uint256 id = otc.offer(30, mkr, 100, dai);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_after - balance_before, 30);
        assertTrue(id > 0);
    }
}

contract SuspendableSimpleMarket_BuyTransferTestSuspended is TransferTest_SuspendedMarket {
    function testFailSuspndSuspdblSmplMrktBuyTransfersFromBuyer() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(user1));
        user1.doBuy(id, 30);
        uint256 balance_after = dai.balanceOf(address(user1));

        assertEq(balance_before - balance_after, 100);
    }
    function testFailSuspndSuspdblSmplMrktBuyTransfersToSeller() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(this));
        user1.doBuy(id, 30);
        uint256 balance_after = dai.balanceOf(address(this));

        assertEq(balance_after - balance_before, 100);
    }
    function testFailSuspndSuspdblSmplMrktBuyTransfersFromMarket() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(otc));
        user1.doBuy(id, 30);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, 30);
    }
    function testFailSuspndSuspdblSmplMrktBuyTransfersToBuyer() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(user1));
        user1.doBuy(id, 30);
        uint256 balance_after = mkr.balanceOf(address(user1));

        assertEq(balance_after - balance_before, 30);
    }
}

contract SuspendableSimpleMarket_PartialBuyTransferTestSuspended is TransferTest_SuspendedMarket {
    function testFailSuspndSuspdblSmplMrktBuyTransfersFromBuyer() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(user1));
        user1.doBuy(id, 15);
        uint256 balance_after = dai.balanceOf(address(user1));

        assertEq(balance_before - balance_after, 50);
    }
    function testFailSuspndSuspdblSmplMrktBuyTransfersToSeller() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(this));
        user1.doBuy(id, 15);
        uint256 balance_after = dai.balanceOf(address(this));

        assertEq(balance_after - balance_before, 50);
    }
    function testFailSuspndSuspdblSmplMrktBuyTransfersFromMarket() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(otc));
        user1.doBuy(id, 15);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, 15);
    }
    function testFailSuspndSuspdblSmplMrktBuyTransfersToBuyer() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(user1));
        user1.doBuy(id, 15);
        uint256 balance_after = mkr.balanceOf(address(user1));

        assertEq(balance_after - balance_before, 15);
    }
    function testFailSuspndSuspdblSmplMrktBuyOddTransfersFromBuyer() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(user1));
        user1.doBuy(id, 17);
        uint256 balance_after = dai.balanceOf(address(user1));

        assertEq(balance_before - balance_after, 56);
    }
}

contract SuspendableSimpleMarket_CancelTransferTestSuspended is TransferTest_SuspendedMarket {
    function testSuspndSuspdblSmplMrktCancelTransfersFromMarket() public {
        // Unsuspend to allow offer
        otc.unsuspendMarket();
        uint256 id = otc.offer(30, mkr, 100, dai);
        // Suspend and test cancellation
        otc.suspendMarket();

        uint256 balance_before = mkr.balanceOf(address(otc));
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, 30);
    }
    function testSuspndSuspdblSmplMrktCancelTransfersToSeller() public {
        // Unsuspend to allow offer
        otc.unsuspendMarket();
        uint256 id = otc.offer(30, mkr, 100, dai);
        // Suspend and test cancellation
        otc.suspendMarket();

        uint256 balance_before = mkr.balanceOf(address(this));
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(this));

        assertEq(balance_after - balance_before, 30);
    }
    function testSuspndSuspdblSmplMrktCancelPartialTransfersFromMarket() public {
        // Unsuspend to allow offer & buy
        otc.unsuspendMarket();
        uint256 id = otc.offer(30, mkr, 100, dai);
        user1.doBuy(id, 15);
        // Suspend and test cancellation
        otc.suspendMarket();

        uint256 balance_before = mkr.balanceOf(address(otc));
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, 15);
    }
    function testSuspndSuspdblSmplMrktCancelPartialTransfersToSeller() public {
        // Unsuspend to allow offer & buy
        otc.unsuspendMarket();
        uint256 id = otc.offer(30, mkr, 100, dai);
        user1.doBuy(id, 15);
        // Suspend and test cancellation
        otc.suspendMarket();

        uint256 balance_before = mkr.balanceOf(address(this));
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(this));

        assertEq(balance_after - balance_before, 15);
    }
}

// ----------------------------------------------------------------------------

// Same tests as above, but with the market closed

contract TransferTest_ClosedMarket is DSTest, VmCheat {
    MarketTester user1;
    IERC20 dai;
    IERC20 mkr;
    SuspendableSimpleMarket otc;

    function setUp() public override{
        super.setUp();
        console2.log("TransferTest_ClosedMarket: setUp()");

        otc = new SuspendableSimpleMarket(false);
        otc.closeMarket();
        user1 = new MarketTester(otc);

        dai = new DSTokenBase(10 ** 9);
        mkr = new DSTokenBase(10 ** 6);

        dai.transfer(address(user1), 100);
        user1.doApprove(address(otc), 100, dai);
        mkr.approve(address(otc), 30);
    }
}

contract SuspendableSimpleMarket_OfferTransferTestClosed is TransferTest_ClosedMarket {
    function testFailClsdSuspdblSmplMrktOfferTransfersFromSeller() public {
        uint256 balance_before = mkr.balanceOf(address(this));
        uint256 id = otc.offer(30, mkr, 100, dai);
        uint256 balance_after = mkr.balanceOf(address(this));

        assertEq(balance_before - balance_after, 30);
        assertTrue(id > 0);
    }
    function testFailClsdSuspdblSmplMrktOfferTransfersToMarket() public {
        uint256 balance_before = mkr.balanceOf(address(otc));
        uint256 id = otc.offer(30, mkr, 100, dai);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_after - balance_before, 30);
        assertTrue(id > 0);
    }
}

contract SuspendableSimpleMarket_BuyTransferTestClosed is TransferTest_ClosedMarket {
    function testFailClsdSuspdblSmplMrktBuyTransfersFromBuyer() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(user1));
        user1.doBuy(id, 30);
        uint256 balance_after = dai.balanceOf(address(user1));

        assertEq(balance_before - balance_after, 100);
    }
    function testFailClsdSuspdblSmplMrktBuyTransfersToSeller() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(this));
        user1.doBuy(id, 30);
        uint256 balance_after = dai.balanceOf(address(this));

        assertEq(balance_after - balance_before, 100);
    }
    function testFailClsdSuspdblSmplMrktBuyTransfersFromMarket() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(otc));
        user1.doBuy(id, 30);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, 30);
    }
    function testFailClsdSuspdblSmplMrktBuyTransfersToBuyer() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(user1));
        user1.doBuy(id, 30);
        uint256 balance_after = mkr.balanceOf(address(user1));

        assertEq(balance_after - balance_before, 30);
    }
}

contract SuspendableSimpleMarket_PartialBuyTransferTestClosed is TransferTest_ClosedMarket {
    function testFailClsdSuspdblSmplMrktBuyTransfersFromBuyer() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(user1));
        user1.doBuy(id, 15);
        uint256 balance_after = dai.balanceOf(address(user1));

        assertEq(balance_before - balance_after, 50);
    }
    function testFailClsdSuspdblSmplMrktBuyTransfersToSeller() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(this));
        user1.doBuy(id, 15);
        uint256 balance_after = dai.balanceOf(address(this));

        assertEq(balance_after - balance_before, 50);
    }
    function testFailClsdSuspdblSmplMrktBuyTransfersFromMarket() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(otc));
        user1.doBuy(id, 15);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, 15);
    }
    function testFailClsdSuspdblSmplMrktBuyTransfersToBuyer() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(user1));
        user1.doBuy(id, 15);
        uint256 balance_after = mkr.balanceOf(address(user1));

        assertEq(balance_after - balance_before, 15);
    }
    function testFailClsdSuspdblSmplMrktBuyOddTransfersFromBuyer() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(user1));
        user1.doBuy(id, 17);
        uint256 balance_after = dai.balanceOf(address(user1));

        assertEq(balance_before - balance_after, 56);
    }
}

contract SuspendableSimpleMarket_CancelTransferTestClosed is TransferTest_ClosedMarket {
    function testFailClsdSuspdblSmplMrktCancelTransfersFromMarket() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(otc));
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, 30);
    }
    function testFailClsdSuspdblSmplMrktCancelTransfersToSeller() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(this));
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(this));

        assertEq(balance_after - balance_before, 30);
    }
    function testFailClsdSuspdblSmplMrktCancelPartialTransfersFromMarket() public {
        uint256 id = otc.offer(30, mkr, 100, dai);
        user1.doBuy(id, 15);

        uint256 balance_before = mkr.balanceOf(address(otc));
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, 15);
    }
    function testFailClsdSuspdblSmplMrktCancelPartialTransfersToSeller() public {
        uint256 id = otc.offer(30, mkr, 100, dai);
        user1.doBuy(id, 15);

        uint256 balance_before = mkr.balanceOf(address(this));
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(this));

        assertEq(balance_after - balance_before, 15);
    }
    // Same tests, but try to unsuspend
    function testFail2ClsdSuspdblSmplMrktCancelTransfersFromMarket() public {
        // Unsuspend attempt
        otc.unsuspendMarket();
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(otc));
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, 30);
    }
    function testFail2ClsdSuspdblSmplMrktCancelTransfersToSeller() public {
        // Unsuspend attempt
        otc.unsuspendMarket();
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(this));
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(this));

        assertEq(balance_after - balance_before, 30);
    }
    function testFail2ClsdSuspdblSmplMrktCancelPartialTransfersFromMarket() public {
        // Unsuspend attempt
        otc.unsuspendMarket();
        uint256 id = otc.offer(30, mkr, 100, dai);
        user1.doBuy(id, 15);

        uint256 balance_before = mkr.balanceOf(address(otc));
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, 15);
    }
    function testFail2ClsdSuspdblSmplMrktCancelPartialTransfersToSeller() public {
        // Unsuspend attempt
        otc.unsuspendMarket();
        uint256 id = otc.offer(30, mkr, 100, dai);
        user1.doBuy(id, 15);

        uint256 balance_before = mkr.balanceOf(address(this));
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(this));

        assertEq(balance_after - balance_before, 15);
    }
}


// ============================================================================


// --- Gas Tests ---

contract SuspendableSimpleMarket_GasTest_OpenMarket is DSTest, VmCheat {
    IERC20 dai;
    IERC20 mkr;
    SuspendableSimpleMarket otc;
    uint id;

    function setUp() public override {
        super.setUp();
        console2.log("GasTest: setUp()");

        otc = new SuspendableSimpleMarket(false); // not suspended

        dai = new DSTokenBase(10 ** 9);
        mkr = new DSTokenBase(10 ** 6);

        mkr.approve(address(otc), 60);
        dai.approve(address(otc), 100);

        id = otc.offer(30, mkr, 100, dai);
    }
    function testOpndSuspdblSmplMrktNewMarket()
        public
        logs_gas
    {
        new SuspendableSimpleMarket(false);
    }
    function testOpndSuspdblSmplMrktNewOffer()
        public
        logs_gas
    {
        otc.offer(30, mkr, 100, dai);
    }
    function testOpndSuspdblSmplMrktBuy()
        public
        logs_gas
    {
        otc.buy(id, 30);
    }
    function testOpndSuspdblSmplMrktBuyPartial()
        public
        logs_gas
    {
        otc.buy(id, 15);
    }
    function testOpndSuspdblSmplMrktCancel()
        public
        logs_gas
    {
        otc.cancel(id);
    }
}

// ----------------------------------------------------------------------------

// Same tests as above, but with the market suspended

contract SuspendableSimpleMarket_GasTest_SuspendedMarket is DSTest, VmCheat {
    IERC20 dai;
    IERC20 mkr;
    SuspendableSimpleMarket otc;
    uint id;

    function setUp() public override {
        super.setUp();
        console2.log("GasTest: setUp()");

        otc = new SuspendableSimpleMarket(false);

        dai = new DSTokenBase(10 ** 9);
        mkr = new DSTokenBase(10 ** 6);

        mkr.approve(address(otc), 60);
        dai.approve(address(otc), 100);

        id = otc.offer(30, mkr, 100, dai);
        otc.suspendMarket(); // SUSPEND
    }
    function testSuspndSuspdblSmplMrktNewMarket()
        public
        logs_gas
    {
        new SuspendableSimpleMarket(false);
    }
    function testFailSuspndSuspdblSmplMrktNewOffer()
        public
        logs_gas
    {
        otc.offer(30, mkr, 100, dai);
    }
    function testFailSuspndSuspdblSmplMrktBuy()
        public
        logs_gas
    {
        otc.buy(id, 30);
    }
    function testFailSuspndSuspdblSmplMrktBuyPartial()
        public
        logs_gas
    {
        otc.buy(id, 15);
    }
    function testSuspndSuspdblSmplMrktCancel()
        public
        logs_gas
    {
        otc.cancel(id);
    }
}

// Same tests as above, but with the market closed

contract SuspendableSimpleMarket_GasTest_ClosedMarket is DSTest, VmCheat {
    IERC20 dai;
    IERC20 mkr;
    SuspendableSimpleMarket otc;
    uint id;

    function setUp() public override {
        super.setUp();
        console2.log("GasTest: setUp()");

        otc = new SuspendableSimpleMarket(false);

        dai = new DSTokenBase(10 ** 9);
        mkr = new DSTokenBase(10 ** 6);

        mkr.approve(address(otc), 60);
        dai.approve(address(otc), 100);

        id = otc.offer(30, mkr, 100, dai);
        otc.closeMarket(); // CLOSE
    }
    function testClsdSuspdblSmplMrktNewMarket()
        public
        logs_gas
    {
        new SuspendableSimpleMarket(false);
    }
    function testFailClsdSuspdblSmplMrktNewOffer()
        public
        logs_gas
    {
        otc.offer(30, mkr, 100, dai);
    }
    function testFailClsdSuspdblSmplMrktBuy()
        public
        logs_gas
    {
        otc.buy(id, 30);
    }
    function testFailClsdSuspdblSmplMrktBuyPartial()
        public
        logs_gas
    {
        otc.buy(id, 15);
    }
    function testClsdSuspdblSmplMrktCancel()
        public
        logs_gas
    {
        otc.cancel(id);
    }
}

// Same tests as above, but with the market closed & unsuspended

contract SuspendableSimpleMarket_GasTest_ClosedMarket2 is DSTest, VmCheat {
    IERC20 dai;
    IERC20 mkr;
    SuspendableSimpleMarket otc;
    uint id;

    function setUp() public override {
        super.setUp();
        console2.log("GasTest: setUp()");

        otc = new SuspendableSimpleMarket(false);

        dai = new DSTokenBase(10 ** 9);
        mkr = new DSTokenBase(10 ** 6);

        mkr.approve(address(otc), 60);
        dai.approve(address(otc), 100);

        id = otc.offer(30, mkr, 100, dai);
        otc.closeMarket(); // CLOSE
        vm.expectRevert("SS299_MARKET_ALREADY_CLOSED"); // Closed market
        otc.unsuspendMarket(); // SUSPEND
    }
    function testClsd2SuspdblSmplMrktNewMarket()
        public
        logs_gas
    {
        new SuspendableSimpleMarket(false);
    }
    function testFail2ClsdSuspdblSmplMrktNewOffer()
        public
        logs_gas
    {
        otc.offer(30, mkr, 100, dai);
    }
    function testFail2ClsdSuspdblSmplMrktBuy()
        public
        logs_gas
    {
        otc.buy(id, 30);
    }
    function testFail2ClsdSuspdblSmplMrktBuyPartial()
        public
        logs_gas
    {
        otc.buy(id, 15);
    }
    function testClsd2SuspdblSmplMrktCancel()
        public
        logs_gas
    {
        otc.cancel(id);
    }
}

// ============================================================================

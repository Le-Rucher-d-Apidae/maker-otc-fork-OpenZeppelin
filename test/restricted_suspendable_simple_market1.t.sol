// SPDX-License-Identifier: AGPL-3.0-or-later

/// restricted_suspendable_simple_market1.t.sol

/// apply the exact same test found in simple_market.t.sol for the Restricted_Suspendable_Simple_Market.sol
/// due to tokens restrictions almost all test are moved from test to testFail

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

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../contracts/Restricted_Suspendable_Simple_Market.sol";
import {VmCheat, DSTokenBase} from "./markets.t.sol";

contract MarketTester {

    RestrictedSuspendableSimpleMarket market;

    constructor(RestrictedSuspendableSimpleMarket market_) {
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

contract Restricted1SuspendableSimpleMarket_Test is DSTest, VmCheat, EventfulMarket {
    MarketTester user1;
    IERC20 dai;
    IERC20 mkr;
    RestrictedSuspendableSimpleMarket otc;

    function setUp() public override {
        super.setUp();
        console2.log("RestrictedSuspendableSimpleMarket_Test: setUp()");

        otc = new RestrictedSuspendableSimpleMarket(NULL_ERC20, false);
        user1 = new MarketTester(otc);

        dai = new DSTokenBase(10 ** 9);
        mkr = new DSTokenBase(10 ** 6);
    }
    function testRstrctdSuspdblSmplMrktBasicTrade() public {
        dai.transfer(address(user1), 100);
        user1.doApprove(address(otc), 100, dai);
        mkr.approve(address(otc), 30);

        uint256 my_mkr_balance_before = mkr.balanceOf(address(this));
        uint256 my_dai_balance_before = dai.balanceOf(address(this));
        uint256 user1_mkr_balance_before = mkr.balanceOf(address(user1));
        uint256 user1_dai_balance_before = dai.balanceOf(address(user1));

        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        uint256 id = otc.offer(30, mkr, 100, dai);

        vm.expectRevert();
        // assertTrue(user1.doBuy(id, 30));
        user1.doBuy(id, 30);

        uint256 my_mkr_balance_after = mkr.balanceOf(address(this));
        uint256 my_dai_balance_after = dai.balanceOf(address(this));
        uint256 user1_mkr_balance_after = mkr.balanceOf(address(user1));
        uint256 user1_dai_balance_after = dai.balanceOf(address(user1));
        assertEq(/* 30 */0, my_mkr_balance_before - my_mkr_balance_after);
        assertEq(/* 100 */0, my_dai_balance_after - my_dai_balance_before);
        assertEq(/* 30 */0, user1_mkr_balance_after - user1_mkr_balance_before);
        assertEq(/* 100 */0, user1_dai_balance_before - user1_dai_balance_after);

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
    function testRstrctdSuspdblSmplMrktPartiallyFilledOrderMkr() public {
        dai.transfer(address(user1), 30);
        user1.doApprove(address(otc), 30, dai);
        mkr.approve(address(otc), 200);

        uint256 my_mkr_balance_before = mkr.balanceOf(address(this));
        uint256 my_dai_balance_before = dai.balanceOf(address(this));
        uint256 user1_mkr_balance_before = mkr.balanceOf(address(user1));
        uint256 user1_dai_balance_before = dai.balanceOf(address(user1));

        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        uint256 id = otc.offer(200, mkr, 500, dai);
        // assertTrue(user1.doBuy(id, 10));
        vm.expectRevert();
        user1.doBuy(id, 10);
        
        uint256 my_mkr_balance_after = mkr.balanceOf(address(this));
        uint256 my_dai_balance_after = dai.balanceOf(address(this));
        uint256 user1_mkr_balance_after = mkr.balanceOf(address(user1));
        uint256 user1_dai_balance_after = dai.balanceOf(address(user1));
        (uint256 sell_val, IERC20 sell_token, uint256 buy_val, IERC20 buy_token) = otc.getOffer(id);

        assertEq(/* 200 */0, my_mkr_balance_before - my_mkr_balance_after);
        assertEq(/* 25 */0, my_dai_balance_after - my_dai_balance_before);
        assertEq(/* 10 */0, user1_mkr_balance_after - user1_mkr_balance_before);
        assertEq(/* 25 */0, user1_dai_balance_before - user1_dai_balance_after);
        assertEq(/* 190 */0, sell_val);
        assertEq(/* 475 */0, buy_val);
        assertTrue(address(sell_token) == NULL_ADDRESS);
        assertTrue(address(buy_token) == NULL_ADDRESS);

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
    function testRstrctdSuspdblSmplMrktPartiallyFilledOrderDai() public {
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

        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, dai, mkr) );
        uint256 id = otc.offer(500, dai, 200, mkr);
        console.log("id", id);
        // Buy for 10 DAI of MKR (spend 4 MKR)
        // assertTrue(user1.doBuy(id, 10));
        vm.expectRevert();
        user1.doBuy(id, 10);

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

        assertEq(/* 500 */0, my_dai_balance_before - my_dai_balance_after);
        assertEq(/* 4 */0, my_mkr_balance_after - my_mkr_balance_before);
        assertEq(/* 10 */0, user1_dai_balance_after - user1_dai_balance_before);
        assertEq(/* 4 */0, user1_mkr_balance_before - user1_mkr_balance_after);
        assertEq(/* 490 */0, sell_val);
        assertEq(/* 196 */0, buy_val); // FAILS HERE

       assertTrue(address(sell_token) == NULL_ADDRESS);
       assertTrue(address(buy_token) == NULL_ADDRESS);

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
    function testRstrctdSuspdblSmplMrktPartiallyFilledOrderMkrExcessQuantity() public {
        dai.transfer(address(user1), 30);
        user1.doApprove(address(otc), 30, dai);
        mkr.approve(address(otc), 200);

        uint256 my_mkr_balance_before = mkr.balanceOf(address(this));
        uint256 my_dai_balance_before = dai.balanceOf(address(this));
        uint256 user1_mkr_balance_before = mkr.balanceOf(address(user1));
        uint256 user1_dai_balance_before = dai.balanceOf(address(user1));

        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        uint256 id = otc.offer(200, mkr, 500, dai);
        // assertTrue(!user1.doBuy(id, 201));
        vm.expectRevert();
        user1.doBuy(id, 201);

        uint256 my_mkr_balance_after = mkr.balanceOf(address(this));
        uint256 my_dai_balance_after = dai.balanceOf(address(this));
        uint256 user1_mkr_balance_after = mkr.balanceOf(address(user1));
        uint256 user1_dai_balance_after = dai.balanceOf(address(user1));
        (uint256 sell_val, IERC20 sell_token, uint256 buy_val, IERC20 buy_token) = otc.getOffer(id);

        assertEq(/* 0 */0, my_dai_balance_before - my_dai_balance_after);
        assertEq(/* 200 */0, my_mkr_balance_before - my_mkr_balance_after);
        assertEq(/* 0 */0, user1_dai_balance_before - user1_dai_balance_after);
        assertEq(/* 0 */0, user1_mkr_balance_before - user1_mkr_balance_after);
        assertEq(/* 200 */0, sell_val);
        assertEq(/* 500 */0, buy_val);
        assertTrue(address(sell_token) == NULL_ADDRESS);
        assertTrue(address(buy_token) == NULL_ADDRESS);

        // TODO: migrate Events checks

/* 
        // expectEventsExact(address(otc));
        // emit LogItemUpdate(id);

        vm.expectEmit(true,false,false,false, address(otc));
        emit LogItemUpdate(id);
 */
    }
    function testRstrctdSuspdblSmplMrktInsufficientlyFilledOrder() public {
        mkr.approve(address(otc), 30);

        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        uint256 id = otc.offer(30, mkr, 10, dai);

        dai.transfer(address(user1), 1);
        user1.doApprove(address(otc), 1, dai);

        vm.expectRevert();
        bool success = user1.doBuy(id, 1);
        assertTrue(!success);
    }
    function testRstrctdSuspdblSmplMrktCancel() public {
        mkr.approve(address(otc), 30);
        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        uint256 id = otc.offer(30, mkr, 100, dai);
        vm.expectRevert();
        // assertTrue(otc.cancel(id));
        otc.cancel(id);

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
    function testRstrctdSuspdblSmplMrktCancelNotOwner() public {
        mkr.approve(address(otc), 30);
        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        uint256 id = otc.offer(30, mkr, 100, dai);
        vm.expectRevert();
        user1.doCancel(id);
    }
    function testRstrctdSuspdblSmplMrktCancelInactive() public {
        mkr.approve(address(otc), 30);
        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        uint256 id = otc.offer(30, mkr, 100, dai);
        vm.expectRevert();
        // assertTrue(otc.cancel(id));
        otc.cancel(id);
        vm.expectRevert();
        otc.cancel(id);
    }
    function testRstrctdSuspdblSmplMrktBuyInactive() public {
        mkr.approve(address(otc), 30);
        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        uint256 id = otc.offer(30, mkr, 100, dai);
        vm.expectRevert(); // order doesn't exist
        // assertTrue(otc.cancel(id));
        otc.cancel(id);
        vm.expectRevert(); // order doesn't exist
        otc.buy(id, 0);
    }
    function testRstrctdSuspdblSmplMrktOfferNotEnoughFunds() public {
        // mkr.transfer(NULL_ADDRESS, mkr.balanceOf(address(this)) - 29);
        uint amount = mkr.balanceOf(address(this)) - 29;
        vm.expectRevert( "ERC20: transfer to the zero address" );
        mkr.transfer(NULL_ADDRESS, amount);
        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        uint256 id = otc.offer(30, mkr, 100, dai);
        assertTrue(id == 0);     //ugly hack to stop compiler from throwing a warning for unused var id
    }
    function testRstrctdSuspdblSmplMrktBuyNotEnoughFunds() public {
        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        uint256 id = otc.offer(30, mkr, 101, dai);
        emit log_named_uint("user1 dai allowance", dai.allowance(address(user1), address(otc)));
        user1.doApprove(address(otc), 101, dai);
        emit log_named_uint("user1 dai allowance", dai.allowance(address(user1), address(otc)));
        emit log_named_uint("user1 dai balance before", dai.balanceOf(address(user1)));

        vm.expectRevert();
        // assertTrue(user1.doBuy(id, 101));
        user1.doBuy(id, 101);
        emit log_named_uint("user1 dai allowance", dai.allowance(address(user1), address(otc)));
        emit log_named_uint("user1 dai balance after", dai.balanceOf(address(user1)));
    }
    function testRstrctdSuspdblSmplMrktBuyNotEnoughApproval() public {
        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        uint256 id = otc.offer(30, mkr, 100, dai);

        emit log_named_uint("user1 dai allowance", dai.allowance(address(user1), address(otc)));
        user1.doApprove(address(otc), 99, dai);
        emit log_named_uint("user1 dai allowance", dai.allowance(address(user1), address(otc)));
        emit log_named_uint("user1 dai balance before", dai.balanceOf(address(user1)));
        vm.expectRevert();
        // assertTrue(user1.doBuy(id, 100));
        user1.doBuy(id, 100);
        emit log_named_uint("user1 dai allowance", dai.allowance(address(user1), address(otc)));
        emit log_named_uint("user1 dai balance after", dai.balanceOf(address(user1)));
    }
    function testRstrctdSuspdblSmplMrktOfferSameToken() public {
        dai.approve(address(otc), 200);
        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, dai, dai) );
        otc.offer(100, dai, 100, dai);
    }
    function testRstrctdSuspdblSmplMrktBuyTooMuch() public {
        mkr.approve(address(otc), 30);
        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        uint256 id = otc.offer(30, mkr, 100, dai);
        vm.expectRevert();
        assertTrue(!otc.buy(id, 50));
    }
    function testFailRstrctdSuspdblSmplMrktOverflow() public {
        mkr.approve(address(otc), 30);
        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, dai, mkr) );
        uint256 id = otc.offer(30, mkr, 100, dai);
        vm.expectRevert();
        otc.buy(id, uint(type(uint256).max+1));
    }
    function testFailRstrctdSuspdblSmplMrktTransferFromEOA() public {
        IERC20 ERC20_123 = IERC20(address(123));
        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, ERC20_123, mkr) );
        otc.offer(30, ERC20_123, 100, dai);
    }
}

// ----------------------------------------------------------------------------

// Same tests as Simple market (market is NOT suspended or closed)

contract TransferTest_OpenMarket is DSTest, VmCheat {
    MarketTester user1;
    IERC20 dai;
    IERC20 mkr;
    RestrictedSuspendableSimpleMarket otc;

    function setUp() public override{
        super.setUp();
        console2.log("TransferTest_OpenMarket: setUp()");

        otc = new RestrictedSuspendableSimpleMarket(NULL_ERC20, false);
        user1 = new MarketTester(otc);

        dai = new DSTokenBase(10 ** 9);
        mkr = new DSTokenBase(10 ** 6);

        dai.transfer(address(user1), 100);
        user1.doApprove(address(otc), 100, dai);
        mkr.approve(address(otc), 30);
    }
}

contract Restricted1SuspendableSimpleMarket_OfferTransferTestOpened is TransferTest_OpenMarket {
    function testRstrctdSuspdblSmplMrktOfferTransfersFromSeller() public {
        uint256 balance_before = mkr.balanceOf(address(this));
        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        uint256 id = otc.offer(30, mkr, 100, dai);
        uint256 balance_after = mkr.balanceOf(address(this));

        assertEq(balance_before - balance_after, /* 30 */0);
        assertTrue(id /* >  0 */ == 0);
    }
    function testRstrctdSuspdblSmplMrktOfferTransfersToMarket() public {
        uint256 balance_before = mkr.balanceOf(address(otc));
        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        uint256 id = otc.offer(30, mkr, 100, dai);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_after - balance_before, /* 30 */0);
        assertTrue(id /* > 0 */==0);
    }
}

contract Restricted1SuspendableSimpleMarket_BuyTransferTestOpened is TransferTest_OpenMarket {
    function testRstrctdSuspdblSmplMrktBuyTransfersFromBuyer() public {
        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(user1));
        vm.expectRevert();
        user1.doBuy(id, 30);
        uint256 balance_after = dai.balanceOf(address(user1));

        assertEq(balance_before - balance_after, /* 100 */0);
    }
    function testRstrctdSuspdblSmplMrktBuyTransfersToSeller() public {
        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(this));
        vm.expectRevert();
        user1.doBuy(id, 30);
        uint256 balance_after = dai.balanceOf(address(this));

        assertEq(balance_after - balance_before, /* 100 */ 0);
    }
    function testRstrctdSuspdblSmplMrktBuyTransfersFromMarket() public {
        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(otc));
        vm.expectRevert();
        user1.doBuy(id, 30);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, /* 30 */ 0);
    }
    function testRstrctdSuspdblSmplMrktBuyTransfersToBuyer() public {
        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(user1));
        vm.expectRevert();
        user1.doBuy(id, 30);
        uint256 balance_after = mkr.balanceOf(address(user1));

        assertEq(balance_after - balance_before, /* 30 */ 0);
    }
}

contract Restricted1SuspendableSimpleMarket_PartialBuyTransferTestOpened is TransferTest_OpenMarket {
    function testRstrctdSuspdblSmplMrktBuyTransfersFromBuyer() public {
        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(user1));
        vm.expectRevert();
        user1.doBuy(id, 15);
        uint256 balance_after = dai.balanceOf(address(user1));

        assertEq(balance_before - balance_after, /* 50 */ 0);
    }
    function testRstrctdSuspdblSmplMrktBuyTransfersToSeller() public {
        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(this));
        vm.expectRevert();
        user1.doBuy(id, 15);
        uint256 balance_after = dai.balanceOf(address(this));

        assertEq(balance_after - balance_before, /* 50 */ 0);
    }
    function testRstrctdSuspdblSmplMrktBuyTransfersFromMarket() public {
        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(otc));
        vm.expectRevert();
        user1.doBuy(id, 15);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, /* 15 */ 0);
    }
    function testRstrctdSuspdblSmplMrktBuyTransfersToBuyer() public {
        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(user1));
        vm.expectRevert();
        user1.doBuy(id, 15);
        uint256 balance_after = mkr.balanceOf(address(user1));

        assertEq(balance_after - balance_before, /* 15 */ 0);
    }
    function testRstrctdSuspdblSmplMrktBuyOddTransfersFromBuyer() public {
        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(user1));
        vm.expectRevert();
        user1.doBuy(id, 17);
        uint256 balance_after = dai.balanceOf(address(user1));

        assertEq(balance_before - balance_after, /* 56 */ 0);
    }
}

contract Restricted1SuspendableSimpleMarket_CancelTransferTestOpened is TransferTest_OpenMarket {
    function testRstrctdSuspdblSmplMrktCancelTransfersFromMarket() public {
        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(otc));
        vm.expectRevert();
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, /* 30 */ 0);
    }
    function testRstrctdSuspdblSmplMrktCancelTransfersToSeller() public {
        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(this));
        vm.expectRevert();
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(this));

        assertEq(balance_after - balance_before, /* 30 */ 0);
    }
    function testRstrctdSuspdblSmplMrktCancelPartialTransfersFromMarket() public {
        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        uint256 id = otc.offer(30, mkr, 100, dai);
        vm.expectRevert();
        user1.doBuy(id, 15);

        uint256 balance_before = mkr.balanceOf(address(otc));
        vm.expectRevert();
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, /* 15 */ 0);
    }
    function testRstrctdSuspdblSmplMrktCancelPartialTransfersToSeller() public {
        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        uint256 id = otc.offer(30, mkr, 100, dai);
        vm.expectRevert();
        user1.doBuy(id, 15);

        uint256 balance_before = mkr.balanceOf(address(this));
        vm.expectRevert();
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(this));

        assertEq(balance_after - balance_before, /* 15 */ 0);
    }
}

// ----------------------------------------------------------------------------

// Same tests as above, but with the market suspended

contract TransferTest_SuspendedMarket is DSTest, VmCheat {
    MarketTester user1;
    IERC20 dai;
    IERC20 mkr;
    RestrictedSuspendableSimpleMarket otc;

    function setUp() public override{
        super.setUp();
        console2.log("TransferTest_SuspendedMarket: setUp()");

        otc = new RestrictedSuspendableSimpleMarket(NULL_ERC20, true);
        user1 = new MarketTester(otc);

        dai = new DSTokenBase(10 ** 9);
        mkr = new DSTokenBase(10 ** 6);

        dai.transfer(address(user1), 100);
        user1.doApprove(address(otc), 100, dai);
        mkr.approve(address(otc), 30);
    }
}

contract Restricted1SuspendableSimpleMarket_OfferTransferTestSuspended is TransferTest_SuspendedMarket {
    function testSuspndSuspdblSmplMrktOfferTransfersFromSeller() public {
        uint256 balance_before = mkr.balanceOf(address(this));
        vm.expectRevert(); // Suspended market
        uint256 id = otc.offer(30, mkr, 100, dai);
        uint256 balance_after = mkr.balanceOf(address(this));

        assertEq(balance_before - balance_after, /* 30 */ 0);
        assertTrue(id/*  > 0 */== 0);
    }
    function testSuspndSuspdblSmplMrktOfferTransfersToMarket() public {
        uint256 balance_before = mkr.balanceOf(address(otc));
        vm.expectRevert(); // Suspended market
        uint256 id = otc.offer(30, mkr, 100, dai);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_after - balance_before, /* 30 */ 0);
        assertTrue(id/*  > 0 */== 0);
    }
}

contract Restricted1SuspendableSimpleMarket_BuyTransferTestSuspended is TransferTest_SuspendedMarket {
    function testSuspndSuspdblSmplMrktBuyTransfersFromBuyer() public {
        vm.expectRevert(); // Suspended market
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(user1));
        vm.expectRevert(); // Suspended market
        user1.doBuy(id, 30);
        uint256 balance_after = dai.balanceOf(address(user1));

        assertEq(balance_before - balance_after, /* 100 */ 0);
    }
    function testSuspndSuspdblSmplMrktBuyTransfersToSeller() public {
        vm.expectRevert(); // Suspended market
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(this));
        vm.expectRevert(); // Suspended market
        user1.doBuy(id, 30);
        uint256 balance_after = dai.balanceOf(address(this));

        assertEq(balance_after - balance_before, /* 100 */ 0);
    }
    function testSuspndSuspdblSmplMrktBuyTransfersFromMarket() public {
        vm.expectRevert(); // Suspended market
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(otc));
        vm.expectRevert(); // Suspended market
        user1.doBuy(id, 30);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after,/*  30 */ 0);
    }
    function testSuspndSuspdblSmplMrktBuyTransfersToBuyer() public {
        vm.expectRevert(); // Suspended market
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(user1));
        vm.expectRevert(); // Suspended market
        user1.doBuy(id, 30);
        uint256 balance_after = mkr.balanceOf(address(user1));

        assertEq(balance_after - balance_before,/*  30 */ 0);
    }
}

contract Restricted1SuspendableSimpleMarket_PartialBuyTransferTestSuspended is TransferTest_SuspendedMarket {
    function testSuspndSuspdblSmplMrktBuyTransfersFromBuyer() public {
        vm.expectRevert(); // Suspended market
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(user1));
        vm.expectRevert(); // Suspended market
        user1.doBuy(id, 15);
        uint256 balance_after = dai.balanceOf(address(user1));

        assertEq(balance_before - balance_after, /* 50 */ 0);
    }
    function testSuspndSuspdblSmplMrktBuyTransfersToSeller() public {
        vm.expectRevert(); // Suspended market
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(this));
        vm.expectRevert(); // Suspended market
        user1.doBuy(id, 15);
        uint256 balance_after = dai.balanceOf(address(this));

        assertEq(balance_after - balance_before, /* 50 */ 0);
    }
    function testSuspndSuspdblSmplMrktBuyTransfersFromMarket() public {
        vm.expectRevert(); // Suspended market
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(otc));
        vm.expectRevert(); // Suspended market
        user1.doBuy(id, 15);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, /* 15 */ 0);
    }
    function testSuspndSuspdblSmplMrktBuyTransfersToBuyer() public {
        vm.expectRevert(); // Suspended market
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(user1));
        vm.expectRevert(); // Suspended market
        user1.doBuy(id, 15);
        uint256 balance_after = mkr.balanceOf(address(user1));

        assertEq(balance_after - balance_before, /* 15 */ 0);
    }
    function testSuspndSuspdblSmplMrktBuyOddTransfersFromBuyer() public {
        vm.expectRevert(); // Suspended market
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(user1));
        vm.expectRevert(); // Suspended market
        user1.doBuy(id, 17);
        uint256 balance_after = dai.balanceOf(address(user1));

        assertEq(balance_before - balance_after, /* 56 */ 0);
    }
}

contract Restricted1SuspendableSimpleMarket_CancelTransferTestSuspended is TransferTest_SuspendedMarket {
    function testSuspndSuspdblSmplMrktCancelTransfersFromMarket() public {
        // Unsuspend to allow offer
        otc.unsuspendMarket();
        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        uint256 id = otc.offer(30, mkr, 100, dai);
        // Suspend and test cancellation
        otc.suspendMarket();

        uint256 balance_before = mkr.balanceOf(address(otc));
        vm.expectRevert();
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, /* 30 */ 0);
    }
    function testSuspndSuspdblSmplMrktCancelTransfersToSeller() public {
        // Unsuspend to allow offer
        otc.unsuspendMarket();
        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        uint256 id = otc.offer(30, mkr, 100, dai);
        // Suspend and test cancellation
        otc.suspendMarket();

        uint256 balance_before = mkr.balanceOf(address(this));
        vm.expectRevert();
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(this));

        assertEq(balance_after - balance_before, /* 30 */ 0);
    }
    function testSuspndSuspdblSmplMrktCancelPartialTransfersFromMarket() public {
        // Unsuspend to allow offer & buy
        otc.unsuspendMarket();
        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        uint256 id = otc.offer(30, mkr, 100, dai);
        vm.expectRevert();
        user1.doBuy(id, 15);
        // Suspend and test cancellation
        otc.suspendMarket();

        uint256 balance_before = mkr.balanceOf(address(otc));
        vm.expectRevert();
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, /* 15 */ 0);
    }
    function testSuspndSuspdblSmplMrktCancelPartialTransfersToSeller() public {
        // Unsuspend to allow offer & buy
        otc.unsuspendMarket();
        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        uint256 id = otc.offer(30, mkr, 100, dai);
        vm.expectRevert();
        user1.doBuy(id, 15);
        // Suspend and test cancellation
        otc.suspendMarket();

        uint256 balance_before = mkr.balanceOf(address(this));
        vm.expectRevert();
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(this));

        assertEq(balance_after - balance_before, /* 15 */ 0);
    }
}

// ----------------------------------------------------------------------------

// Same tests as above, but with the market closed

contract TransferTest_ClosedMarket is DSTest, VmCheat {
    MarketTester user1;
    IERC20 dai;
    IERC20 mkr;
    RestrictedSuspendableSimpleMarket otc;

    function setUp() public override{
        super.setUp();
        console2.log("TransferTest_ClosedMarket: setUp()");

        otc = new RestrictedSuspendableSimpleMarket(NULL_ERC20, false);
        otc.closeMarket();
        user1 = new MarketTester(otc);

        dai = new DSTokenBase(10 ** 9);
        mkr = new DSTokenBase(10 ** 6);

        dai.transfer(address(user1), 100);
        user1.doApprove(address(otc), 100, dai);
        mkr.approve(address(otc), 30);
    }
}

contract Restricted1SuspendableSimpleMarket_OfferTransferTestClosed is TransferTest_ClosedMarket {
    function testClsdSuspdblSmplMrktOfferTransfersFromSeller() public {
        uint256 balance_before = mkr.balanceOf(address(this));
        vm.expectRevert(); // Closed market
        uint256 id = otc.offer(30, mkr, 100, dai);
        uint256 balance_after = mkr.balanceOf(address(this));

        assertEq(balance_before - balance_after,/*  30 */ 0);
        assertTrue(id /* > 0 */ == 0);
    }
    function testClsdSuspdblSmplMrktOfferTransfersToMarket() public {
        uint256 balance_before = mkr.balanceOf(address(otc));
        vm.expectRevert(); // Closed market
        uint256 id = otc.offer(30, mkr, 100, dai);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_after - balance_before,/*  30 */ 0);
        assertTrue(id /* > 0 */ == 0);
    }
}

contract Restricted1SuspendableSimpleMarket_BuyTransferTestClosed is TransferTest_ClosedMarket {
    function testClsdSuspdblSmplMrktBuyTransfersFromBuyer() public {
        vm.expectRevert(); // Closed market
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(user1));
        vm.expectRevert(); // Closed market
        user1.doBuy(id, 30);
        uint256 balance_after = dai.balanceOf(address(user1));

        assertEq(balance_before - balance_after, /* 100 */ 0);
    }
    function testClsdSuspdblSmplMrktBuyTransfersToSeller() public {
        vm.expectRevert(); // Closed market
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(this));
        vm.expectRevert(); // Closed market
        user1.doBuy(id, 30);
        uint256 balance_after = dai.balanceOf(address(this));

        assertEq(balance_after - balance_before, /* 100 */ 0);
    }
    function testClsdSuspdblSmplMrktBuyTransfersFromMarket() public {
        vm.expectRevert(); // Closed market
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(otc));
        vm.expectRevert(); // Closed market
        user1.doBuy(id, 30);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after,/*  30 */ 0);
    }
    function testClsdSuspdblSmplMrktBuyTransfersToBuyer() public {
        vm.expectRevert(); // Closed market
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(user1));
        vm.expectRevert(); // Closed market
        user1.doBuy(id, 30);
        uint256 balance_after = mkr.balanceOf(address(user1));

        assertEq(balance_after - balance_before,/*  30 */ 0);
    }
}

contract Restricted1SuspendableSimpleMarket_PartialBuyTransferTestClosed is TransferTest_ClosedMarket {
    function testClsdSuspdblSmplMrktBuyTransfersFromBuyer() public {
        vm.expectRevert(); // Closed market
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(user1));
        vm.expectRevert(); // Closed market
        user1.doBuy(id, 15);
        uint256 balance_after = dai.balanceOf(address(user1));

        assertEq(balance_before - balance_after, /* 50 */ 0);
    }
    function testClsdSuspdblSmplMrktBuyTransfersToSeller() public {
        vm.expectRevert(); // Closed market
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(this));
        vm.expectRevert(); // Closed market
        user1.doBuy(id, 15);
        uint256 balance_after = dai.balanceOf(address(this));

        assertEq(balance_after - balance_before, /* 50 */ 0);
    }
    function testClsdSuspdblSmplMrktBuyTransfersFromMarket() public {
        vm.expectRevert(); // Closed market
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(otc));
        vm.expectRevert(); // Closed market
        user1.doBuy(id, 15);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, /* 15 */ 0);
    }
    function testClsdSuspdblSmplMrktBuyTransfersToBuyer() public {
        vm.expectRevert(); // Closed market
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(user1));
        vm.expectRevert(); // Closed market
        user1.doBuy(id, 15);
        uint256 balance_after = mkr.balanceOf(address(user1));

        assertEq(balance_after - balance_before, /* 15 */ 0);
    }
    function testClsdSuspdblSmplMrktBuyOddTransfersFromBuyer() public {
        vm.expectRevert(); // Closed market
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(user1));
        vm.expectRevert(); // Closed market
        user1.doBuy(id, 17);
        uint256 balance_after = dai.balanceOf(address(user1));

        assertEq(balance_before - balance_after, /* 56 */ 0);
    }
}

contract Restricted1SuspendableSimpleMarket_CancelTransferTestClosed is TransferTest_ClosedMarket {
    function testClsdSuspdblSmplMrktCancelTransfersFromMarket() public {
        vm.expectRevert(); // Closed market
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(otc));
        vm.expectRevert(); // Closed market
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, /* 30 */ 0);
    }
    function testClsdSuspdblSmplMrktCancelTransfersToSeller() public {
        vm.expectRevert(); // Closed market
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(this));
        vm.expectRevert(); // Closed market
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(this));

        assertEq(balance_after - balance_before, /* 30 */ 0);
    }
    function testClsdSuspdblSmplMrktCancelPartialTransfersFromMarket() public {
        vm.expectRevert(); // Closed market
        uint256 id = otc.offer(30, mkr, 100, dai);
        vm.expectRevert(); // Closed market
        user1.doBuy(id, 15);

        uint256 balance_before = mkr.balanceOf(address(otc));
        vm.expectRevert(); // Closed market
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, /* 15 */ 0);
    }
    function testClsdSuspdblSmplMrktCancelPartialTransfersToSeller() public {
        vm.expectRevert(); // Closed market
        uint256 id = otc.offer(30, mkr, 100, dai);
        vm.expectRevert(); // Closed market
        user1.doBuy(id, 15);

        uint256 balance_before = mkr.balanceOf(address(this));
        vm.expectRevert(); // Closed market
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(this));

        assertEq(balance_after - balance_before, /* 15 */ 0);
    }

    // Same tests, but try to unsuspend
    function test2ClsdSuspdblSmplMrktCancelTransfersFromMarket() public {
        vm.expectRevert("SS299_MARKET_ALREADY_CLOSED"); // Closed market
        // Unsuspend attempt
        otc.unsuspendMarket();
        vm.expectRevert("SS201_MARKET_NOT_ACTIVE"); // Closed market
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(otc));
        vm.expectRevert("T101_OFFER_NOT_PRESENT");
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, /* 30 */ 0);
    }
    function test2ClsdSuspdblSmplMrktCancelTransfersToSeller() public {
        vm.expectRevert("SS299_MARKET_ALREADY_CLOSED"); // Closed market
        // Unsuspend attempt
        otc.unsuspendMarket();
        vm.expectRevert(); // Closed market
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(this));
        vm.expectRevert(); // Closed market
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(this));

        assertEq(balance_after - balance_before, /* 30 */ 0);
    }
    function test2ClsdSuspdblSmplMrktCancelPartialTransfersFromMarket() public {
        vm.expectRevert("SS299_MARKET_ALREADY_CLOSED"); // Closed market
        // Unsuspend attempt
        otc.unsuspendMarket();
        vm.expectRevert("SS201_MARKET_NOT_ACTIVE"); // Closed market
        uint256 id = otc.offer(30, mkr, 100, dai);
        vm.expectRevert("T101_OFFER_NOT_PRESENT");
        user1.doBuy(id, 15);

        uint256 balance_before = mkr.balanceOf(address(otc));
        vm.expectRevert(); // order doens't exist
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, /* 15 */ 0);
    }
    function test2ClsdSuspdblSmplMrktCancelPartialTransfersToSeller() public {
        vm.expectRevert("SS299_MARKET_ALREADY_CLOSED"); // Closed market
        // Unsuspend attempt
        otc.unsuspendMarket();
        vm.expectRevert("SS201_MARKET_NOT_ACTIVE"); // Closed market
        uint256 id = otc.offer(30, mkr, 100, dai);
        vm.expectRevert("T101_OFFER_NOT_PRESENT");
        user1.doBuy(id, 15);

        uint256 balance_before = mkr.balanceOf(address(this));
        vm.expectRevert(); // order doens't exist
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(this));

        assertEq(balance_after - balance_before, /* 15 */ 0);
    }
}


// ============================================================================


// --- Gas Tests ---

contract Restricted1SuspendableSimpleMarket_GasTest_OpenMarket is DSTest, VmCheat {
    IERC20 dai;
    IERC20 mkr;
    RestrictedSuspendableSimpleMarket otc;
    uint id;

    function setUp() public override {
        super.setUp();
        console2.log("GasTest: setUp()");

        otc = new RestrictedSuspendableSimpleMarket(NULL_ERC20, false); // not suspended

        dai = new DSTokenBase(10 ** 9);
        mkr = new DSTokenBase(10 ** 6);

        mkr.approve(address(otc), 60);
        dai.approve(address(otc), 100);

        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        id = otc.offer(30, mkr, 100, dai);
    }
    function testOpndSuspdblSmplMrktNewMarket()
        public
        logs_gas
    {
        new RestrictedSuspendableSimpleMarket(NULL_ERC20, false);
    }
    function testOpndSuspdblSmplMrktNewOffer()
        public
        logs_gas
    {
        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        otc.offer(30, mkr, 100, dai);
    }
    function testOpndSuspdblSmplMrktBuy()
        public
        logs_gas
    {
        vm.expectRevert(); // doesn't exist
        otc.buy(id, 30);
    }
    function testOpndSuspdblSmplMrktBuyPartial()
        public
        logs_gas
    {
        vm.expectRevert(); // doesn't exist
        otc.buy(id, 15);
    }
    function testOpndSuspdblSmplMrktCancel()
        public
        logs_gas
    {
        vm.expectRevert(); // doesn't exist
        otc.cancel(id);
    }
}

// ----------------------------------------------------------------------------

// Same tests as above, but with the market suspended

contract Restricted1SuspendableSimpleMarket_GasTest_SuspendedMarket is DSTest, VmCheat {
    IERC20 dai;
    IERC20 mkr;
    RestrictedSuspendableSimpleMarket otc;
    uint id;

    function setUp() public override {
        super.setUp();
        console2.log("GasTest: setUp()");

        otc = new RestrictedSuspendableSimpleMarket(NULL_ERC20, false);

        dai = new DSTokenBase(10 ** 9);
        mkr = new DSTokenBase(10 ** 6);

        mkr.approve(address(otc), 60);
        dai.approve(address(otc), 100);

        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        id = otc.offer(30, mkr, 100, dai);
        otc.suspendMarket(); // SUSPEND
    }
    function testSuspndSuspdblSmplMrktNewMarket()
        public
        logs_gas
    {
        new RestrictedSuspendableSimpleMarket(NULL_ERC20, false);
    }
    function testSuspndSuspdblSmplMrktNewOffer()
        public
        logs_gas
    {
        vm.expectRevert(); // Suspended market
        otc.offer(30, mkr, 100, dai);
    }
    function testSuspndSuspdblSmplMrktBuy()
        public
        logs_gas
    {
        vm.expectRevert(); // Suspended market
        otc.buy(id, 30);
    }
    function testSuspndSuspdblSmplMrktBuyPartial()
        public
        logs_gas
    {
        vm.expectRevert(); // Suspended market
        otc.buy(id, 15);
    }
    function testSuspndSuspdblSmplMrktCancel()
        public
        logs_gas
    {
        vm.expectRevert(); // doesn't exist
        otc.cancel(id);
    }
}

// Same tests as above, but with the market closed

contract Restricted1SuspendableSimpleMarket_GasTest_ClosedMarket is DSTest, VmCheat {
    IERC20 dai;
    IERC20 mkr;
    RestrictedSuspendableSimpleMarket otc;
    uint id;

    function setUp() public override {
        super.setUp();
        console2.log("GasTest: setUp()");

        otc = new RestrictedSuspendableSimpleMarket(NULL_ERC20, false);

        dai = new DSTokenBase(10 ** 9);
        mkr = new DSTokenBase(10 ** 6);

        mkr.approve(address(otc), 60);
        dai.approve(address(otc), 100);

        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        id = otc.offer(30, mkr, 100, dai);
        otc.closeMarket(); // CLOSE
    }
    function testClsdSuspdblSmplMrktNewMarket()
        public
        logs_gas
    {
        new RestrictedSuspendableSimpleMarket(NULL_ERC20, false);
    }
    function testClsdSuspdblSmplMrktNewOffer()
        public
        logs_gas
    {
        vm.expectRevert(); // Closed market
        otc.offer(30, mkr, 100, dai);
    }
    function testClsdSuspdblSmplMrktBuy()
        public
        logs_gas
    {
        vm.expectRevert(); // Closed market
        otc.buy(id, 30);
    }
    function testClsdSuspdblSmplMrktBuyPartial()
        public
        logs_gas
    {
        vm.expectRevert(); // Closed market
        otc.buy(id, 15);
    }
    function testClsdSuspdblSmplMrktCancel()
        public
        logs_gas
    {
        vm.expectRevert(); // doesn't exist
        otc.cancel(id);
    }
}

// Same tests as above, but with the market closed & unsuspended

contract Restricted1SuspendableSimpleMarket_GasTest_ClosedMarket2 is DSTest, VmCheat {
    IERC20 dai;
    IERC20 mkr;
    RestrictedSuspendableSimpleMarket otc;
    uint id;

    function setUp() public override {
        super.setUp();
        console2.log("GasTest: setUp()");

        otc = new RestrictedSuspendableSimpleMarket(NULL_ERC20, false);

        dai = new DSTokenBase(10 ** 9);
        mkr = new DSTokenBase(10 ** 6);

        mkr.approve(address(otc), 60);
        dai.approve(address(otc), 100);

        // FAIL. Reason: InvalidTradingPair
        vm.expectRevert( abi.encodeWithSelector(InvalidTradingPair.selector, mkr, dai) );
        id = otc.offer(30, mkr, 100, dai);
        otc.closeMarket(); // CLOSE
        vm.expectRevert("SS299_MARKET_ALREADY_CLOSED"); // Closed market
        otc.unsuspendMarket(); // SUSPEND
    }
    function testClsd2SuspdblSmplMrktNewMarket()
        public
        logs_gas
    {
        new RestrictedSuspendableSimpleMarket(NULL_ERC20, false);
    }
    function test2ClsdSuspdblSmplMrktNewOffer()
        public
        logs_gas
    {
        // vm.expectRevert(); // Closed market
        vm.expectRevert("SS201_MARKET_NOT_ACTIVE"); // Closed market
        otc.offer(30, mkr, 100, dai);
    }
    function test2ClsdSuspdblSmplMrktBuy()
        public
        logs_gas
    {
        // vm.expectRevert(); // Closed market
        vm.expectRevert("T101_OFFER_NOT_PRESENT");
        otc.buy(id, 30);
    }
    function test2ClsdSuspdblSmplMrktBuyPartial()
        public
        logs_gas
    {
        // vm.expectRevert(); // Closed market
        vm.expectRevert("T101_OFFER_NOT_PRESENT");
        otc.buy(id, 15);
    }
    function testClsd2SuspdblSmplMrktCancel()
        public
        logs_gas
    {
        // vm.expectRevert(); // Closed market
        vm.expectRevert("T101_OFFER_NOT_PRESENT");
        otc.cancel(id);
    }
}

// ============================================================================

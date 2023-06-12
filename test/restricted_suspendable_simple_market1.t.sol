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

// pragma solidity >= 0.8.18 < 0.9.0;
// pragma solidity ^0.8.20;
pragma solidity ^0.8.18; // latest HH supported version


import "forge-std/Test.sol"; // import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "forge-std/console2.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";// import "ds-token/base.sol";

import "../contracts/restricted_suspendable_simple_market.sol";

contract MarketTester {

    RestrictedSuspendableSimpleMarket market;

    constructor(RestrictedSuspendableSimpleMarket market_) {
        market = market_;
    }
    function doApprove(address spender, uint value, ERC20 token) public {
        token.approve(spender, value);
    }
    function doBuy(uint id, uint buy_how_much) public returns (bool _success) {
        return market.buy(id, buy_how_much);
    }
    function doCancel(uint id) public returns (bool _success) {
        return market.cancel(id);
    }
}

contract VmCheat {
    Vm vm;

    address public NULL_ADDRESS = address(0x0);
    ERC20 public NULL_ERC20 = ERC20(NULL_ADDRESS);

    bytes20 constant CHEAT_CODE =
        // bytes20(uint160(uint256(keccak256('hevm cheat code')))); // 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D
        bytes20(uint160(uint256(keccak256('vm cheat code')))); // 0xf835497c59c5c4906c0169b282e283dc3259e396

    function setUp() public virtual {
        console2.log("VmCheat: setUp()");
        // console2.logBytes20(CHEAT_CODE);
        vm = Vm(address(CHEAT_CODE));
        // vm.warp(1);
    }
}



contract DSTokenBase is ERC20{
    constructor(uint _initialSupply) ERC20("Test", "TST") {
        _mint(msg.sender, _initialSupply );
    }
}


contract Restricted1SuspendableSimpleMarket_Test is DSTest, VmCheat, EventfulMarket {
    MarketTester user1;
    ERC20 dai;
    ERC20 mkr;
    RestrictedSuspendableSimpleMarket otc;

    function setUp() public override {
        super.setUp();
        console2.log("RestrictedSuspendableSimpleMarket_Test: setUp()");

        otc = new RestrictedSuspendableSimpleMarket(NULL_ERC20, false);
        user1 = new MarketTester(otc);

        dai = new DSTokenBase(10 ** 9);
        mkr = new DSTokenBase(10 ** 6);
    }
    function testFailRstrctdSuspdblSmplMrktBasicTrade() public {
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
    function testFailRstrctdSuspdblSmplMrktPartiallyFilledOrderMkr() public {
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
        (uint256 sell_val, ERC20 sell_token, uint256 buy_val, ERC20 buy_token) = otc.getOffer(id);

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
    function testFailRstrctdSuspdblSmplMrktPartiallyFilledOrderDai() public {
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
        (uint256 sell_val, ERC20 sell_token, uint256 buy_val, ERC20 buy_token) = otc.getOffer(id);
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
    function testFailRstrctdSuspdblSmplMrktPartiallyFilledOrderMkrExcessQuantity() public {
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
        (uint256 sell_val, ERC20 sell_token, uint256 buy_val, ERC20 buy_token) = otc.getOffer(id);

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
    function testFailRstrctdSuspdblSmplMrktInsufficientlyFilledOrder() public {
        mkr.approve(address(otc), 30);
        uint256 id = otc.offer(30, mkr, 10, dai);

        dai.transfer(address(user1), 1);
        user1.doApprove(address(otc), 1, dai);
        bool success = user1.doBuy(id, 1);
        assertTrue(!success);
    }
    function testFailRstrctdSuspdblSmplMrktCancel() public {
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
    function testFailRstrctdSuspdblSmplMrktCancelNotOwner() public {
        mkr.approve(address(otc), 30);
        uint256 id = otc.offer(30, mkr, 100, dai);
        user1.doCancel(id);
    }
    function testFailRstrctdSuspdblSmplMrktCancelInactive() public {
        mkr.approve(address(otc), 30);
        uint256 id = otc.offer(30, mkr, 100, dai);
        assertTrue(otc.cancel(id));
        otc.cancel(id);
    }
    function testFailRstrctdSuspdblSmplMrktBuyInactive() public {
        mkr.approve(address(otc), 30);
        uint256 id = otc.offer(30, mkr, 100, dai);
        assertTrue(otc.cancel(id));
        otc.buy(id, 0);
    }
    function testFailRstrctdSuspdblSmplMrktOfferNotEnoughFunds() public {
        mkr.transfer(NULL_ADDRESS, mkr.balanceOf(address(this)) - 29);
        uint256 id = otc.offer(30, mkr, 100, dai);
        assertTrue(id >= 0);     //ugly hack to stop compiler from throwing a warning for unused var id
    }
    function testFailRstrctdSuspdblSmplMrktBuyNotEnoughFunds() public {
        uint256 id = otc.offer(30, mkr, 101, dai);
        emit log_named_uint("user1 dai allowance", dai.allowance(address(user1), address(otc)));
        user1.doApprove(address(otc), 101, dai);
        emit log_named_uint("user1 dai allowance", dai.allowance(address(user1), address(otc)));
        emit log_named_uint("user1 dai balance before", dai.balanceOf(address(user1)));
        assertTrue(user1.doBuy(id, 101));
        emit log_named_uint("user1 dai allowance", dai.allowance(address(user1), address(otc)));
        emit log_named_uint("user1 dai balance after", dai.balanceOf(address(user1)));
    }
    function testFailRstrctdSuspdblSmplMrktBuyNotEnoughApproval() public {
        uint256 id = otc.offer(30, mkr, 100, dai);
        emit log_named_uint("user1 dai allowance", dai.allowance(address(user1), address(otc)));
        user1.doApprove(address(otc), 99, dai);
        emit log_named_uint("user1 dai allowance", dai.allowance(address(user1), address(otc)));
        emit log_named_uint("user1 dai balance before", dai.balanceOf(address(user1)));
        assertTrue(user1.doBuy(id, 100));
        emit log_named_uint("user1 dai allowance", dai.allowance(address(user1), address(otc)));
        emit log_named_uint("user1 dai balance after", dai.balanceOf(address(user1)));
    }
    function testFailRstrctdSuspdblSmplMrktOfferSameToken() public {
        dai.approve(address(otc), 200);
        otc.offer(100, dai, 100, dai);
    }
    function testFailRstrctdSuspdblSmplMrktBuyTooMuch() public {
        mkr.approve(address(otc), 30);
        uint256 id = otc.offer(30, mkr, 100, dai);
        assertTrue(!otc.buy(id, 50));
    }
    function testFailRstrctdSuspdblSmplMrktOverflow() public {
        mkr.approve(address(otc), 30);
        uint256 id = otc.offer(30, mkr, 100, dai);
        otc.buy(id, uint(type(uint256).max+1));
    }
    function testFailRstrctdSuspdblSmplMrktTransferFromEOA() public {
        otc.offer(30, ERC20(address(123)), 100, dai);
    }
}

// ----------------------------------------------------------------------------

// Same tests as Simple market (market is NOT suspended or closed)

contract TransferTest_OpenMarket is DSTest, VmCheat {
    MarketTester user1;
    ERC20 dai;
    ERC20 mkr;
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
    function testFailRstrctdSuspdblSmplMrktOfferTransfersFromSeller() public {
        uint256 balance_before = mkr.balanceOf(address(this));
        uint256 id = otc.offer(30, mkr, 100, dai);
        uint256 balance_after = mkr.balanceOf(address(this));

        assertEq(balance_before - balance_after, 30);
        assertTrue(id > 0);
    }
    function testFailRstrctdSuspdblSmplMrktOfferTransfersToMarket() public {
        uint256 balance_before = mkr.balanceOf(address(otc));
        uint256 id = otc.offer(30, mkr, 100, dai);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_after - balance_before, 30);
        assertTrue(id > 0);
    }
}

contract Restricted1SuspendableSimpleMarket_BuyTransferTestOpened is TransferTest_OpenMarket {
    function testFailRstrctdSuspdblSmplMrktBuyTransfersFromBuyer() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(user1));
        user1.doBuy(id, 30);
        uint256 balance_after = dai.balanceOf(address(user1));

        assertEq(balance_before - balance_after, 100);
    }
    function testFailRstrctdSuspdblSmplMrktBuyTransfersToSeller() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(this));
        user1.doBuy(id, 30);
        uint256 balance_after = dai.balanceOf(address(this));

        assertEq(balance_after - balance_before, 100);
    }
    function testFailRstrctdSuspdblSmplMrktBuyTransfersFromMarket() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(otc));
        user1.doBuy(id, 30);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, 30);
    }
    function testFailRstrctdSuspdblSmplMrktBuyTransfersToBuyer() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(user1));
        user1.doBuy(id, 30);
        uint256 balance_after = mkr.balanceOf(address(user1));

        assertEq(balance_after - balance_before, 30);
    }
}

contract Restricted1SuspendableSimpleMarket_PartialBuyTransferTestOpened is TransferTest_OpenMarket {
    function testFailRstrctdSuspdblSmplMrktBuyTransfersFromBuyer() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(user1));
        user1.doBuy(id, 15);
        uint256 balance_after = dai.balanceOf(address(user1));

        assertEq(balance_before - balance_after, 50);
    }
    function testFailRstrctdSuspdblSmplMrktBuyTransfersToSeller() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(this));
        user1.doBuy(id, 15);
        uint256 balance_after = dai.balanceOf(address(this));

        assertEq(balance_after - balance_before, 50);
    }
    function testFailRstrctdSuspdblSmplMrktBuyTransfersFromMarket() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(otc));
        user1.doBuy(id, 15);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, 15);
    }
    function testFailRstrctdSuspdblSmplMrktBuyTransfersToBuyer() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(user1));
        user1.doBuy(id, 15);
        uint256 balance_after = mkr.balanceOf(address(user1));

        assertEq(balance_after - balance_before, 15);
    }
    function testFailRstrctdSuspdblSmplMrktBuyOddTransfersFromBuyer() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = dai.balanceOf(address(user1));
        user1.doBuy(id, 17);
        uint256 balance_after = dai.balanceOf(address(user1));

        assertEq(balance_before - balance_after, 56);
    }
}

contract Restricted1SuspendableSimpleMarket_CancelTransferTestOpened is TransferTest_OpenMarket {
    function testFailRstrctdSuspdblSmplMrktCancelTransfersFromMarket() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(otc));
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, 30);
    }
    function testFailRstrctdSuspdblSmplMrktCancelTransfersToSeller() public {
        uint256 id = otc.offer(30, mkr, 100, dai);

        uint256 balance_before = mkr.balanceOf(address(this));
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(this));

        assertEq(balance_after - balance_before, 30);
    }
    function testFailRstrctdSuspdblSmplMrktCancelPartialTransfersFromMarket() public {
        uint256 id = otc.offer(30, mkr, 100, dai);
        user1.doBuy(id, 15);

        uint256 balance_before = mkr.balanceOf(address(otc));
        otc.cancel(id);
        uint256 balance_after = mkr.balanceOf(address(otc));

        assertEq(balance_before - balance_after, 15);
    }
    function testFailRstrctdSuspdblSmplMrktCancelPartialTransfersToSeller() public {
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
    ERC20 dai;
    ERC20 mkr;
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

contract Restricted1SuspendableSimpleMarket_BuyTransferTestSuspended is TransferTest_SuspendedMarket {
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

contract Restricted1SuspendableSimpleMarket_PartialBuyTransferTestSuspended is TransferTest_SuspendedMarket {
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

contract Restricted1SuspendableSimpleMarket_CancelTransferTestSuspended is TransferTest_SuspendedMarket {
    function testFailSuspndSuspdblSmplMrktCancelTransfersFromMarket() public {
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
    function testFailSuspndSuspdblSmplMrktCancelTransfersToSeller() public {
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
    function testFailSuspndSuspdblSmplMrktCancelPartialTransfersFromMarket() public {
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
    function testFailSuspndSuspdblSmplMrktCancelPartialTransfersToSeller() public {
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
    ERC20 dai;
    ERC20 mkr;
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

contract Restricted1SuspendableSimpleMarket_BuyTransferTestClosed is TransferTest_ClosedMarket {
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

contract Restricted1SuspendableSimpleMarket_PartialBuyTransferTestClosed is TransferTest_ClosedMarket {
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

contract Restricted1SuspendableSimpleMarket_CancelTransferTestClosed is TransferTest_ClosedMarket {
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

contract Restricted1SuspendableSimpleMarket_GasTest_OpenMarket is DSTest, VmCheat {
    ERC20 dai;
    ERC20 mkr;
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

        // id = otc.offer(30, mkr, 100, dai);
    }
    function testOpndSuspdblSmplMrktNewMarket()
        public
        logs_gas
    {
        new RestrictedSuspendableSimpleMarket(NULL_ERC20, false);
    }
    function testFailOpndSuspdblSmplMrktNewOffer()
        public
        logs_gas
    {
        otc.offer(30, mkr, 100, dai);
    }
    function testFailOpndSuspdblSmplMrktBuy()
        public
        logs_gas
    {
        otc.buy(id, 30);
    }
    function testFailOpndSuspdblSmplMrktBuyPartial()
        public
        logs_gas
    {
        otc.buy(id, 15);
    }
    function testFailOpndSuspdblSmplMrktCancel()
        public
        logs_gas
    {
        otc.cancel(id);
    }
}

// ----------------------------------------------------------------------------

// Same tests as above, but with the market suspended

contract Restricted1SuspendableSimpleMarket_GasTest_SuspendedMarket is DSTest, VmCheat {
    ERC20 dai;
    ERC20 mkr;
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

        // id = otc.offer(30, mkr, 100, dai);
        otc.suspendMarket(); // SUSPEND
    }
    function testSuspndSuspdblSmplMrktNewMarket()
        public
        logs_gas
    {
        new RestrictedSuspendableSimpleMarket(NULL_ERC20, false);
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
    function testFailSuspndSuspdblSmplMrktCancel()
        public
        logs_gas
    {
        otc.cancel(id);
    }
}

// Same tests as above, but with the market closed

contract Restricted1SuspendableSimpleMarket_GasTest_ClosedMarket is DSTest, VmCheat {
    ERC20 dai;
    ERC20 mkr;
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

        // id = otc.offer(30, mkr, 100, dai);
        otc.closeMarket(); // CLOSE
    }
    function testClsdSuspdblSmplMrktNewMarket()
        public
        logs_gas
    {
        new RestrictedSuspendableSimpleMarket(NULL_ERC20, false);
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
    function testFailClsdSuspdblSmplMrktCancel()
        public
        logs_gas
    {
        otc.cancel(id);
    }
}

// Same tests as above, but with the market closed & unsuspended

contract Restricted1SuspendableSimpleMarket_GasTest_ClosedMarket2 is DSTest, VmCheat {
    ERC20 dai;
    ERC20 mkr;
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

        // id = otc.offer(30, mkr, 100, dai);
        otc.closeMarket(); // CLOSE
        otc.unsuspendMarket(); // SUSPEND
    }
    function testClsd2SuspdblSmplMrktNewMarket()
        public
        logs_gas
    {
        new RestrictedSuspendableSimpleMarket(NULL_ERC20, false);
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
    function testFailClsd2SuspdblSmplMrktCancel()
        public
        logs_gas
    {
        otc.cancel(id);
    }
}

// ============================================================================

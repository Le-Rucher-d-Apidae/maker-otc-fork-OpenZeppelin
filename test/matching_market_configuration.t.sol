// SPDX-License-Identifier: AGPL-3.0-or-later

/// matching_market_configuration.t.sol

// Copyright (C) 2017 - 2021 Dai Foundation

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

import "../contracts/Matching_Market_Configuration.sol";
import "../contracts/oracle/IOracle.sol";

import {VmCheat, DSTokenBase} from "./markets.t.sol";



contract DummySimplePriceOracle is IOracle {
    uint256 price;
    function setPrice(address, uint256 _price) public {
        price = _price;
    }

    // function getPriceFor(address, address, uint256) public view returns (uint256) {
    //     return price;
    // }

    function estimateAmountOut(
        address _tokenIn,
        uint24 _fee,
        uint128 _amountIn,
        uint32 _secondsAgo
    ) external view returns (uint amountOut)
    {
        _tokenIn = address(uint160(_fee * _amountIn * _secondsAgo)); // dummy code to remove compiler warnings: unused vars
        return price;
    }
}


contract MatchingMarketConfiguration_Test is DSTest, VmCheat {
    IERC20 dai;
    IERC20 mkr;
    IERC20 dgd;

    uint constant DAI_SUPPLY = (10 ** 9) * (10 ** 18);
    uint constant DGD_SUPPLY = (10 ** 9) * (10 ** 18);
    uint constant MKR_SUPPLY = (10 ** 9) * (10 ** 18);

    // MatchingMarketConfiguration mmConfig;

    DummySimplePriceOracle priceOracle;

    function setUp() public override {
        super.setUp();

        dai = new DSTokenBase(DAI_SUPPLY);
        mkr = new DSTokenBase(MKR_SUPPLY);
        dgd = new DSTokenBase(DGD_SUPPLY);

        priceOracle = new DummySimplePriceOracle();
        // otc = new MatchingMarket(address(dai), 0, address(priceOracle));
        // constructor(IERC20 _mainTradableToken, bool _suspended, IERC20 _dustToken, uint256 _dustLimit, address _priceOracle) RestrictedSuspendableSimpleMarket(_mainTradableToken, _suspended) {
        // mmConfig = new MatchingMarketConfiguration(IERC20(dai), 0, address(priceOracle));
    } // setUp()

    function testNewMatchingMarketConfigurationNullDustToken () public {
        vm.expectRevert( bytes(_MMDST000) );
        // MatchingMarketConfiguration mmConfig = 
        new MatchingMarketConfiguration( IERC20(NULL_ADDRESS), 0, address(priceOracle) );
        // assertNotEq(address(mmConfig), address(0));

    }

    function testNewMatchingMarketConfigurationNullOracle() public {
        vm.expectRevert( bytes(_MMPOR000) );
        // MatchingMarketConfiguration mmConfig =
        new MatchingMarketConfiguration( mkr, 0, NULL_ADDRESS );
        // assertNotEq(address(mmConfig), address(0));

    }

    function testNewMatchingMarketConfigurationDustLimitZero() public {
        MatchingMarketConfiguration mmConfig =
        new MatchingMarketConfiguration( mkr, 0, address(priceOracle) );
        assertNotEq(address(mmConfig), address(0));
    }

    function testNewMatchingMarketConfigurationDustLimitEq() public {
        // vm.expectRevert( bytes(_MMLMTBLW001) );
        MatchingMarketConfiguration mmConfig =
        new MatchingMarketConfiguration( mkr, DUST_LIMIT, address(priceOracle) );
        assertNotEq(address(mmConfig), address(0));
    }

    function testNewMatchingMarketConfigurationDustLimitTooHigh() public {
        vm.expectRevert( bytes(_MMLMTBLW001) );
        // MatchingMarketConfiguration mmConfig =
        new MatchingMarketConfiguration( mkr, DUST_LIMIT+1, address(priceOracle) );
        // assertNotEq(address(mmConfig), address(0));
    }

    function testNewMatchingMarketConfigurationNothing () public {
        vm.expectRevert(  );
        // MatchingMarketConfiguration mmConfig =
        new MatchingMarketConfiguration( IERC20(NULL_ADDRESS), 0, NULL_ADDRESS );
        // assertNotEq(address(mmConfig), address(0));

    }
} // contract MatchingMarketConfiguration_Test


contract MatchingMarketConfiguration_Test2 is DSTest, VmCheat {
    IERC20 dai;
    IERC20 mkr;
    IERC20 dgd;

    uint constant DAI_SUPPLY = (10 ** 9) * (10 ** 18);
    uint constant DGD_SUPPLY = (10 ** 9) * (10 ** 18);
    uint constant MKR_SUPPLY = (10 ** 9) * (10 ** 18);

    // MatchingMarketConfiguration mmConfig;
    DummySimplePriceOracle priceOracle;

    function setUp() public override {
        super.setUp();

        dai = new DSTokenBase(DAI_SUPPLY);
        mkr = new DSTokenBase(MKR_SUPPLY);
        dgd = new DSTokenBase(DGD_SUPPLY);

        priceOracle = new DummySimplePriceOracle();
        // otc = new MatchingMarket(address(dai), 0, address(priceOracle));
        // constructor(IERC20 _mainTradableToken, bool _suspended, IERC20 _dustToken, uint256 _dustLimit, address _priceOracle) RestrictedSuspendableSimpleMarket(_mainTradableToken, _suspended) {
        // mmConfig = new MatchingMarketConfiguration(IERC20(dai), 0, address(priceOracle));
    } // setUp()

    function testAnyDustToken() public {
        MatchingMarketConfiguration mmConfigDustDai = new MatchingMarketConfiguration( dai, 0, address(priceOracle) );
        assertNotEq(address(mmConfigDustDai), address(0));

        MatchingMarketConfiguration mmConfigDustMkr = new MatchingMarketConfiguration( mkr, 0, address(priceOracle) );
        assertNotEq(address(mmConfigDustMkr), address(0));

        MatchingMarketConfiguration mmConfigDustDgd = new MatchingMarketConfiguration( dgd, 0, address(priceOracle) );
        assertNotEq(address(mmConfigDustDgd), address(0));
    }

    function testAnyDustBelowEqualLimit() public {

        for (uint128 dustLimit = 0; dustLimit <= DUST_LIMIT; dustLimit++) {
            
            MatchingMarketConfiguration mmConfigDustLimit = new MatchingMarketConfiguration( dai, dustLimit, address(priceOracle) );
            assertNotEq(address(mmConfigDustLimit), address(0));
        }
    }

} // contract MatchingMarketConfiguration_Test2

contract MatchingMarketConfiguration_Test3 is DSTest, VmCheat {
    IERC20 dai;
    IERC20 mkr;
    IERC20 dgd;

    uint constant DAI_SUPPLY = (10 ** 9) * (10 ** 18);
    uint constant DGD_SUPPLY = (10 ** 9) * (10 ** 18);
    uint constant MKR_SUPPLY = (10 ** 9) * (10 ** 18);

    // MatchingMarketConfiguration mmConfig;
    DummySimplePriceOracle priceOracle;

    function setUp() public override {
        super.setUp();

        dai = new DSTokenBase(DAI_SUPPLY);
        mkr = new DSTokenBase(MKR_SUPPLY);
        dgd = new DSTokenBase(DGD_SUPPLY);

        priceOracle = new DummySimplePriceOracle();
        // otc = new MatchingMarket(address(dai), 0, address(priceOracle));
        // constructor(IERC20 _mainTradableToken, bool _suspended, IERC20 _dustToken, uint256 _dustLimit, address _priceOracle) RestrictedSuspendableSimpleMarket(_mainTradableToken, _suspended) {
        // mmConfig = new MatchingMarketConfiguration(IERC20(dai), 0, address(priceOracle));
    } // setUp()

    function testInitValues() public {
        uint128 DUSTLIMIT = 33;
        MatchingMarketConfiguration mmConfig = new MatchingMarketConfiguration( dai, DUSTLIMIT, address(priceOracle) );
        assertNotEq(address(mmConfig), address(0));

        assertEq(mmConfig.dustLimit(), DUSTLIMIT);
        assertEq(address(mmConfig.dustToken()), address(dai));
        assertEq(address(mmConfig.priceOracle()), address(priceOracle));

    }

    function testChangeValues() public {
        uint128 DUSTLIMIT = 33;
        MatchingMarketConfiguration mmConfig = new MatchingMarketConfiguration( dai, DUSTLIMIT, address(priceOracle) );
        assertNotEq(address(mmConfig), address(0));

        assertEq(mmConfig.dustLimit(), DUSTLIMIT);
        assertEq(address(mmConfig.dustToken()), address(dai));
        assertEq(address(mmConfig.priceOracle()), address(priceOracle));

        DummySimplePriceOracle newPriceOracle = new DummySimplePriceOracle();
        mmConfig.setPriceOracle(address(newPriceOracle));
        assertEq(address(mmConfig.priceOracle()), address(newPriceOracle));

        mmConfig.setDustToken(mkr);
        assertEq(address(mmConfig.dustToken()), address(mkr));

        uint128 NEWDUSTLIMIT = 91;
        mmConfig.setDustLimit(NEWDUSTLIMIT);
        assertEq(mmConfig.dustLimit(), NEWDUSTLIMIT);
        
        IERC20 newDustToken = new DSTokenBase(1000);
        mmConfig.setDustToken(newDustToken);
        assertEq(address(mmConfig.dustToken()), address(newDustToken));
        

    }

} // contract MatchingMarketConfiguration_Test3

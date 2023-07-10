//SPDX-License-Identifier: MIT

// credits: https://github.com/t4sk/uniswap-v3-twap/tree/main

// contracts/oracle/uniswap_v3/UniswapV3Twap.sol

pragma solidity 0.7.6;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";

import "../IOracle.sol";

contract UniswapV3Consts {
    uint24 public constant FEE_HIGH     = 10000;    // 0x2710   1% Fee
    uint24 public constant FEE_MEDIUM   = 3000;     // 0x0bb8   0.30% Fee
    uint24 public constant FEE_LOW      = 500;      // 0x01f4   0.05% Fee
    uint24 public constant FEE_LOWEST   = 100;      // 0x64     0.001% Fee
}

contract UniswapV3Twap is IOracle, UniswapV3Consts {
    address public immutable token0;
    // address public immutable token1;
    // address public immutable pool;
    address public immutable factory;



    constructor(
        address _factory,
        address _token0
        // address _token1,
        // uint24 _fee
    ) {
        token0 = _token0;
        factory = _factory;
/* 
        token1 = _token1;

        address _pool = IUniswapV3Factory(_factory).getPool(
            _token0,
            _token1,
            _fee
        );
        require(_pool != address(0), "pool doesn't exist");

        pool = _pool;
 */
    }

    function estimateAmountOut(
        address _tokenIn, // tokenIn
        uint24 _fee, // Uniswap V3 Pool fee
        uint128 _amountIn, // amountIn of token0 to quote against _tokenIn
        uint32 _secondsAgo // secondsAgo : Time Weighted Average Price 
    ) external view override returns (uint tokenIn_amountOut) {

        require(_tokenIn != token0, "invalid token");

        address pool = IUniswapV3Factory(factory).getPool(
            token0,
            _tokenIn,
            _fee
        );
        require(pool != address(0), "pool doesn't exist");

        // require(_tokenIn == token0 || _tokenIn == token1, "invalid token");

        // address tokenOut = _tokenIn == token0 ? token1 : token0;

        // (int24 tick, ) = OracleLibrary.consult(pool, _secondsAgo);

        // Code copied from OracleLibrary.sol, consult()
        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = _secondsAgo;
        secondsAgos[1] = 0;

        // int56 since tick * time = int24 * uint32
        // 56 = 24 + 32
        (int56[] memory tickCumulatives, ) = IUniswapV3Pool(pool).observe(
            secondsAgos
        );

        int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];

        // int56 / uint32 = int24
        int24 tick = int24(tickCumulativesDelta / _secondsAgo);
        // Always round to negative infinity
        /*
        int doesn't round down when it is negative

        int56 a = -3
        -3 / 10 = -3.3333... so round down to -4
        but we get
        a / 10 = -3

        so if tickCumulativeDelta < 0 and division has remainder, then round
        down
        */
        if (
            tickCumulativesDelta < 0 && (tickCumulativesDelta % _secondsAgo != 0)
        ) {
            tick--;
        }

        /* 
            Given a tick and a token amount, calculates the amount of token received in exchange
            Parameters:
            Name	Type	Description
            tick	int24	Tick value used to calculate the quote
            baseAmount	uint128	Amount of token to be converted
            baseToken	address	Address of an ERC20 token contract used as the baseAmount denomination
            quoteToken	address	Address of an ERC20 token contract used as the quoteAmount denomination
            Return Values:
            Name	Type	Description
            quoteAmount	uint256	Amount of quoteToken received for baseAmount of baseToken
        */
        tokenIn_amountOut = OracleLibrary.getQuoteAtTick(
            tick, // tick
            _amountIn, // baseAmount
            token0, // baseToken
            _tokenIn // quoteToken
        );
    }
}
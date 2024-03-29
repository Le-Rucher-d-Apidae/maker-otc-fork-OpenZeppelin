// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >= 0.7.6;

/**
 * @dev Interface of the Oracle
 */
interface IOracle {

// function estimateAmountOut(
//         address tokenIn,
//         uint128 amountIn,
//         uint32 secondsAgo
//     ) external view returns (uint amountOut);


    function estimateAmountOut(
        address _tokenIn,
        uint24 _fee,
        uint128 _amountIn,
        uint32 _secondsAgo
    ) external view returns (uint amountOut);

}
// SPDX-License-Identifier: UNLICENSED

/// Markets_Fees__constants.sol

pragma solidity ^0.8.21;

// One percent = 10_000
uint256 constant FEE_ONE_PERCENT = 10_000;
uint256 constant FEE_ONE_HUNDRED_PERCENT  = FEE_ONE_PERCENT * 100; // 1_000_000
uint256 constant FEE_SMALLEST = 2 /* * FEE_ONE_PERCENT / FEE_ONE_PERCENT */ ;
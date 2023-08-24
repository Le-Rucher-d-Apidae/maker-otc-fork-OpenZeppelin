
const contractName = "MatchingMarketConfiguration"



ONE_USDC = 1_000_000; // USDC: 6 decimals
ONE_USDT = ONE_USDC; // USDT: 6 decimals
ONE_BUSD = 1_000_000_000_000_000_000; // BUSD: 18 decimals
ONE_DAI = ONE_BUSD; // DAI: 18 decimals

// Minimum trade amount & dust limit
const dustLimit = ONE_USDC / 1_000; // 0.1 USDC
// const dustLimit = ONE_BUSD / 10; // 0.1 BUSD



// Parameters
// 0:        IERC20 _dustToken,
// 1:        uint128 _dustLimit,
// 2:        address _priceOracle

let params ={
  contractName: contractName,
  args: {
    31337:  [/* dustTokenAddress, */ , dustLimit, /* priceOracleAddress */ ], // HardHat : use Polygon Mumbai Testnet or Polygon Mainnet
    80001:  [/* dustTokenAddress, */ , dustLimit, /* priceOracleAddress */ ], // Polygon Mumbai Testnet
    137:    [/* dustTokenAddress, */ , dustLimit, /* priceOracleAddress */ ], // Polygon Mainnet
    },
  deploy: {
    31337:  { log: true, waitConfirmations: 1 }, // HardHat fork on Polygon Mumbai Testnet
    31337:  { log: true, waitConfirmations: 1 }, // HardHat fork on Polygon Mainnet
    80001:  { log: true, waitConfirmations: 6 }, // Polygon Mumbai Testnet
    137:    { log: true, waitConfirmations: 6 }, // Polygon Mainnet
  },
    // log: true,
}

module.exports = params;


const contractName = "MatchingMarket"

// Parameters
// 0:        IERC20 _dustToken,
// 1:        uint128 _dustLimit,
// 2:        address _priceOracle

let params ={
  contractName: contractName,
  args: {
    31337:  [ /* Everything is held by MatchingMarketConfiguration */ ], // HardHat : use Polygon Mumbai Testnet or Polygon Mainnet
    80001:  [ /* Everything is held by MatchingMarketConfiguration */ ], // Polygon Mumbai Testnet
    137:    [ /* Everything is held by MatchingMarketConfiguration */ ], // Polygon Mainnet
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

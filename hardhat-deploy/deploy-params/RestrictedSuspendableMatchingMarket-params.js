
const contractName = "RestrictedSuspendableMatchingMarket"


const isMarketSuspended = false;
// const dustToken = "0x0000000";

ONE_USDC = 1_000_000; // USDC: 6 decimals
ONE_USDT = ONE_USDC; // USDT: 6 decimals
ONE_BUSD = 1_000_000_000_000_000_000; // BUSD: 18 decimals
ONE_DAI = ONE_BUSD; // DAI: 18 decimals

// Minimum trade amount & dust limit
const dustLimit = ONE_USDC / 10; // 0.1 USDC
// const dustLimit = ONE_BUSD / 10; // 0.1 BUSD

let params ={
  contractName: contractName,
  args: {
    31337:  [isMarketSuspended, /* dustToken, */ dustLimit], // HardHat : use Polygon Mumbai Testnet or Polygon Mainnet
    80001:  [isMarketSuspended, /* dustToken, */ dustLimit], // Polygon Mumbai Testnet
    137:    [isMarketSuspended, /* dustToken, */ dustLimit], // Polygon Mainnet
    },
    log: true,
}

module.exports = params;

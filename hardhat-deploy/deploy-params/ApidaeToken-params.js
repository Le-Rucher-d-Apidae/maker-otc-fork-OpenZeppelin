
const contractName = "ApidaeERC20"

const ApidaeERC20_name = "Apidae"; // Apidae Token name
const ApidaeERC20_symbol = "APD"; // Apidae Token symbol
const ApidaeERC20_supply = 100_000_000; // Apidae Token supply

const args = [ApidaeERC20_name, ApidaeERC20_symbol, ApidaeERC20_supply];

let params ={
  contractName: contractName,
  args: {
    31337:  args, // HardHat : use Polygon Mumbai Testnet
    80001:  args, // Polygon Mumbai Testnet
    137:    args, // Polygon Mainnet
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
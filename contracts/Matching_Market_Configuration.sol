// SPDX-License-Identifier: AGPL-3.0-or-later

/// Matching_Market_Configuration.sol

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

import "forge-std/console2.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./constants/Markets__constants.sol";
import "./constants/Matching_Market_Configuration__constants.sol";


contract MatchingMarketConfiguration is Ownable {

    // address public constant NULL_ADDRESS = address(0x0);
    // dust token address
    // address public dustToken;
    IERC20 public dustToken;
    // limit of dust token
    // uint256 public dustLimit;
    uint128 public dustLimit;
    address public priceOracle;

    // event DustTokenAddressChanged( address newValue);
    event DustTokenAddressChanged( IERC20 newValue );
    event ConfigurationChanged( string parameter, uint256 newValue );
    event OracleChanged( address newValue );

    constructor (
        IERC20 _dustToken,
        uint128 _dustLimit,
        address _priceOracle ) {
        initialize( _dustToken, _dustLimit, _priceOracle ) ;
    }

    /**
     * @notice Initializer function
     */
    function initialize(
        IERC20 _dustToken,
        uint128 _dustLimit,
        address _priceOracle
         ) internal
    
    {
        setDustToken(_dustToken);
        setDustLimit(_dustLimit);
        setPriceOracle(_priceOracle);
    }

    function setDustLimit (
        uint128 _dustLimit ) public onlyOwner
    {
        require(_dustLimit <= DUST_LIMIT, _MMLMTBLW001);
        dustLimit = _dustLimit;
        emit ConfigurationChanged("dustLimit", dustLimit);
        // console2.log("dustLimit set to: ", dustLimit);
    }

    function setDustToken(
        IERC20 _dustToken
    )
    public onlyOwner
    {
        require(address(_dustToken) != NULL_ADDRESS, _MMDST000);
        dustToken = _dustToken; // address(_dustToken);
        emit DustTokenAddressChanged(dustToken);
        // console2.log("dustToken set to: ", address(dustToken));
    }

    function setPriceOracle(
        address _priceOracle
    )
    public onlyOwner
    {
        require(_priceOracle != NULL_ADDRESS, _MMPOR000);
        priceOracle = _priceOracle;
        emit OracleChanged(priceOracle);
        // console2.log("priceOracle set to: ", priceOracle);
    }

}
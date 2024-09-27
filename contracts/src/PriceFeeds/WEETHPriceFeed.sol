// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "./CompositePriceFeed.sol";
import "../Interfaces/IWEETHToken.sol";

// import "forge-std/console2.sol";

contract WEETHPriceFeed is CompositePriceFeed {
    constructor(
        address _owner,
        address _ethUsdOracleAddress,
        address _weethEthOracleAddress,
        address _rateProviderAddress,
        uint256 _ethUsdStalenessThreshold,
        uint256 _weethEthStalenessThreshold
    )
    CompositePriceFeed(
    _owner,
    _ethUsdOracleAddress,
    _weethEthOracleAddress,
    _rateProviderAddress,
    _ethUsdStalenessThreshold,
    _weethEthStalenessThreshold
    )
    {}

    function _getCanonicalRate() internal view override returns (uint256, bool) {
        try IWEETHToken(rateProviderAddress).getRate() returns (uint256 ethPerWeeth) {
            // If rate is 0, return true
            if (ethPerWeeth == 0) return (0, true);

            return (ethPerWeeth, false);
        } catch {
            // If call to exchange rate reverts, return true
            return (0, true);
        }

    }
}
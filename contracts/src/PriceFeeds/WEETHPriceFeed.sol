// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "./CompositePriceFeed.sol";
import "../Dependencies/IOsTokenVaultController.sol";

// import "forge-std/console2.sol";

contract WEETHPriceFeed is CompositePriceFeed {
    constructor(
        address _owner,
        address _ethUsdOracleAddress,
        address _lrtEthOracleAddress,
        address _rateProviderAddress,
        uint256 _ethUsdStalenessThreshold,
        uint256 _lstEthStalenessThreshold
    )
    CompositePriceFeed(
    _owner,
    _ethUsdOracleAddress,
    _lrtEthOracleAddress,
    _rateProviderAddress,
    _ethUsdStalenessThreshold,
    _lstEthStalenessThreshold
    )
    {}

    function _getCanonicalRate() internal view override returns (uint256) {
        (uint256 lrtEthPrice,) = _getOracleAnswer(lstEthOracle);
        uint256 canonicalRate = lrtEthPrice;
        return canonicalRate;

    }
}

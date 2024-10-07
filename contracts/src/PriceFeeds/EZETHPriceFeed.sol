
// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "./CompositePriceFeed.sol";
import "../Interfaces/IEZETHPriceFeed.sol";
import "../Interfaces/IBalancerRateProvider.sol";

contract EZETHPriceFeed is CompositePriceFeed, IEZETHPriceFeed {
    Oracle public ezEthEthOracle;

    constructor(
        address _owner,
        address _ethUsdOracleAddress,
        address _ezEthEthOracleAddress,
        address _balancerRateProvider,
        uint256 _ethUsdStalenessThreshold,
        uint256 _ezEthEthStalenessThreshold
    ) CompositePriceFeed(_owner, _ethUsdOracleAddress, _balancerRateProvider, _ethUsdStalenessThreshold) {
        // Store EZETH-ETH oracle
        ezEthEthOracle.aggregator = AggregatorV3Interface(_ezEthEthOracleAddress);
        ezEthEthOracle.stalenessThreshold = _ezEthEthStalenessThreshold;
        ezEthEthOracle.decimals = ezEthEthOracle.aggregator.decimals();

        _fetchPricePrimary();
        
        // Check the oracle didn't already fail
        assert(priceSource == PriceSource.primary);
    }

    function _fetchPricePrimary() internal override returns (uint256, bool) {
        assert(priceSource == PriceSource.primary);
        (uint256 ethUsdPrice, bool ethUsdOracleDown) = _getOracleAnswer(ethUsdOracle);
        (uint256 ezEthEthPrice, bool ezEthEthOracleDown) = _getOracleAnswer(ezEthEthOracle);
        (uint256 ezEthPerEth, bool exchangeRateIsDown) = _getCanonicalRate();
        // If the ETH-USD feed is down, shut down and switch to the last good price seen by the system
        // since we need both ETH-USD and canonical for primary and fallback price calcs
        if (ethUsdOracleDown || exchangeRateIsDown) {
            return (_shutDownAndSwitchToLastGoodPrice(address(ethUsdOracle.aggregator)), true);
        }
        // If the ETH-USD feed is live but the EZETH-ETH oracle is down, shutdown and substitute EZETH-ETH with the canonical rate
        if (ezEthEthOracleDown) {
            return (_shutDownAndSwitchToETHUSDxCanonical(address(ezEthEthOracle.aggregator), ethUsdPrice), true);
        }
        // Otherwise, use the primary price calculation:

        // Calculate the market LRT-USD price: USD_per_EZETH = USD_per_ETH * ETH_per_EZETH
        uint256 lrtUsdMarketPrice = ethUsdPrice * ezEthEthPrice / 1e18;

        // Calculate the canonical LRT-USD price: USD_per_EZETH = USD_per_ETH * ETH_per_EZETH
        uint256 lrtUsdCanonicalPrice = ethUsdPrice * ezEthPerEth / 1e18;

        // Take the minimum of (market, canonical) in order to mitigate against upward market price manipulation.
        uint256 lrtUsdPrice = LiquityMath._min(lrtUsdMarketPrice, lrtUsdCanonicalPrice);
        lastGoodPrice = lrtUsdPrice;
        return (lrtUsdPrice, false);
    }

    function _getCanonicalRate() internal override view returns (uint256, bool) {
        uint256 rate = IBalancerRateProvider(rateProviderAddress).getRate();
        return (rate, rate == 0);
    }

}
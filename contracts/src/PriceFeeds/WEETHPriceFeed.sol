// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "./CompositePriceFeed.sol";
import "../Interfaces/IWEETHToken.sol";
import "../Interfaces/IWEETHPriceFeed.sol";

// import "forge-std/console2.sol";

contract WEETHPriceFeed is CompositePriceFeed, IWEETHPriceFeed {

    Oracle public weEthEthOracle;

    constructor(
        address _owner,
        address _ethUsdOracleAddress,
        address _weEthEthOracleAddress,
        address _weEthTokenAddress,
        uint256 _ethUsdStalenessThreshold,
        uint256 _weEthEthStalenessThreshold
    ) CompositePriceFeed(_owner, _ethUsdOracleAddress, _weEthTokenAddress, _ethUsdStalenessThreshold) {
        // Store WEETH-ETH oracle
        weEthEthOracle.aggregator = AggregatorV3Interface(_weEthEthOracleAddress);
        weEthEthOracle.stalenessThreshold = _weEthEthStalenessThreshold;
        weEthEthOracle.decimals = weEthEthOracle.aggregator.decimals();

        _fetchPricePrimary();

        // Check the oracle didn't already fail
        assert(priceSource == PriceSource.primary);
    }

    function _fetchPricePrimary() internal override returns (uint256, bool) {
        assert(priceSource == PriceSource.primary);
        (uint256 ethUsdPrice, bool ethUsdOracleDown) = _getOracleAnswer(ethUsdOracle);
        (uint256 weEthEthPrice, bool weEthEthOracleDown) = _getOracleAnswer(weEthEthOracle);
        (uint256 weEthPerEth, bool exchangeRateIsDown) = _getCanonicalRate();

        // If the ETH-USD feed is down, shut down and switch to the last good price seen by the system
        // since we need both ETH-USD and canonical for primary and fallback price calcs
        if (ethUsdOracleDown || exchangeRateIsDown) {
            return (_shutDownAndSwitchToLastGoodPrice(address(ethUsdOracle.aggregator)), true);
        }
        // If the ETH-USD feed is live but the WEETH-ETH oracle is down, shutdown and substitute WEETH-ETH with the canonical rate
        if (weEthEthOracleDown) {
            return (_shutDownAndSwitchToETHUSDxCanonical(address(weEthEthOracle.aggregator), ethUsdPrice), true);
        }

        // Otherwise, use the primary price calculation:

        // Calculate the market LRT-USD price: USD_per_WEETH = USD_per_ETH * ETH_per_WEETH
        uint256 lrtUsdMarketPrice = ethUsdPrice * weEthEthPrice / 1e18;

        // Calculate the canonical LST-USD price: USD_per_WEETH = USD_per_ETH * ETH_per_WEETH
        // TODO: Should we also shutdown if the call to the canonical rate reverts, or returns 0?
        uint256 lrtUsdCanonicalPrice = ethUsdPrice * weEthPerEth / 1e18;

        // Take the minimum of (market, canonical) in order to mitigate against upward market price manipulation.
        // NOTE: only needed
        uint256 lrtUsdPrice = LiquityMath._min(lrtUsdMarketPrice, lrtUsdCanonicalPrice);

        lastGoodPrice = lrtUsdPrice;

        return (lrtUsdPrice, false);
    }

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
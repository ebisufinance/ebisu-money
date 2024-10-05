// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "./CompositePriceFeed.sol";
import "../Interfaces/IWEETHToken.sol";
import "../Interfaces/IWEETHPriceFeed.sol";
import "forge-std/console.sol";
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
        console.log("before");
        _fetchPricePrimary();
        console.log("after");
        // Check the oracle didn't already fail
        assert(priceSource == PriceSource.primary);
    }

    function _fetchPricePrimary() internal override returns (uint256, bool) {
        assert(priceSource == PriceSource.primary);
        (uint256 ethUsdPrice, bool ethUsdOracleDown) = _getOracleAnswer(ethUsdOracle);
        console.log("weEthEthOracle decimals: ", weEthEthOracle.stalenessThreshold);
        (uint256 weEthEthPrice, bool weEthEthOracleDown) = _getOracleAnswer(weEthEthOracle);
        console.log("before2");
        (uint256 weEthPerEth, bool exchangeRateIsDown) = _getCanonicalRate();
        console.log("before3");
        // If the ETH-USD feed is down, shut down and switch to the last good price seen by the system
        // since we need both ETH-USD and canonical for primary and fallback price calcs
        if (ethUsdOracleDown || exchangeRateIsDown) {
            console.log("ethUsdOracleDown: ",ethUsdOracleDown);
            console.log("exchangeRateIsDown: ",exchangeRateIsDown);
            return (_shutDownAndSwitchToLastGoodPrice(address(ethUsdOracle.aggregator)), true);
        }
        console.log("before4s");
        // If the ETH-USD feed is live but the WEETH-ETH oracle is down, shutdown and substitute WEETH-ETH with the canonical rate
        if (weEthEthOracleDown) {
            return (_shutDownAndSwitchToETHUSDxCanonical(address(weEthEthOracle.aggregator), ethUsdPrice), true);
        }
        console.log("before5");
        // Otherwise, use the primary price calculation:

        // Calculate the market LRT-USD price: USD_per_WEETH = USD_per_ETH * ETH_per_WEETH
        uint256 lrtUsdMarketPrice = ethUsdPrice * weEthEthPrice / 1e18;

        // Calculate the canonical LST-USD price: USD_per_RETH = USD_per_ETH * ETH_per_RETH
        // TODO: Should we also shutdown if the call to the canonical rate reverts, or returns 0?
        uint256 lrtUsdCanonicalPrice = ethUsdPrice * weEthPerEth / 1e18;

        // Take the minimum of (market, canonical) in order to mitigate against upward market price manipulation.
        // NOTE: only needed
        uint256 lrtUsdPrice = LiquityMath._min(lrtUsdMarketPrice, lrtUsdCanonicalPrice);
        console.log("before5");
        lastGoodPrice = lrtUsdPrice;
        console.log("lastGoodPrice: ",lastGoodPrice);
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
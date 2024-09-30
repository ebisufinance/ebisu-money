// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "./Interfaces/IPriceFeedTestnet.sol";

interface IWeETHOracle {
    function getPrice() external view returns (uint256);
}

/*
* PriceFeed placeholder for testnet and development. The price is simply set manually and saved in a state
* variable. The contract does not connect to a live Chainlink price feed.
*/
contract PriceFeedWeethTestnet is IPriceFeedTestnet {
    event LastGoodPriceUpdated(uint256 _lastGoodPrice);

    uint256 private _price = 200 * 1e18;
    IWeETHOracle private weETHOracle;

    // Constructor to accept the WeETHOracle address
    constructor(address _weETHOracleAddress) {
        weETHOracle = IWeETHOracle(_weETHOracleAddress);
    }

    // --- Functions ---

    // View price getter for simplicity in tests
    function getPrice() external view override returns (uint256) {
        return weETHOracle.getPrice();
    }

    function lastGoodPrice() external view returns (uint256) {
        return _price;
    }

    function fetchPrice() external override returns (uint256, bool) {
        // Fire an event just like the mainnet version would.
        // This lets the subgraph rely on events to get the latest price even when developing locally.
        emit LastGoodPriceUpdated(_price);
        return (_price, false);
    }

    // Manual external price setter.
    function setPrice(uint256 price) external returns (bool) {
        _price = price;
        return true;
    }

    function setAddresses(address _borrowerOperationsAddress) external {}
}
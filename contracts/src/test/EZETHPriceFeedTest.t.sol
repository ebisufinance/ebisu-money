// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "./TestContracts/DevTestSetup.sol";
import "../PriceFeeds/EZETHPriceFeed.sol";

contract EZETHPriceFeedTest is DevTestSetup {
    EZETHPriceFeed ezethPriceFeed;

    function setUp() public override{
        // Create a fork of the mainnet
        vm.createSelectFork(vm.rpcUrl("mainnet"));

        ezethPriceFeed = new EZETHPriceFeed(
            address(this),
            address(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419),
            address(0xF4a3e183F59D2599ee3DF213ff78b1B3b1923696),
            address(0x387dBc0fB00b26fb085aa658527D5BE98302c84C),
            5184000,
            5184000
        );
    }

    function testLastGoodPriceEzeth() public {
        assertGt(ezethPriceFeed.lastGoodPrice(), 0);
    }

    function testFetchPriceEzeth() public {
        (uint256 price, bool isDown) = ezethPriceFeed.fetchPrice();
        assertGt(price, 0);
        assertEq(isDown, false);
    }


}
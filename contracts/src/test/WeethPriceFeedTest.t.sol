// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "./TestContracts/DevTestSetup.sol";
import "../PriceFeeds/WEETHPriceFeed.sol";

contract WEETHPriceFeedTest is DevTestSetup {
    WEETHPriceFeed weethPriceFeed;

    function setUp() public override{
        // Create a fork of the mainnet
        vm.createSelectFork(vm.rpcUrl("mainnet"));

        weethPriceFeed = new WEETHPriceFeed(
            address(this),
            address(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419),
            address(0x8751F736E94F6CD167e8C5B97E245680FbD9CC36),
            address(0xCd5fE23C85820F7B72D0926FC9b05b43E359b7ee),
            5184000,
            5184000
        );

    }

    function testLastGoodPriceWeeth() public {
        assertGt(weethPriceFeed.lastGoodPrice(), 0);
    }

    function testFetchPriceWeeth() public {
        (uint256 price, bool isDown) = weethPriceFeed.fetchPrice();
        assertGt(price, 0);
        assertEq(isDown, false);
    }

    

}
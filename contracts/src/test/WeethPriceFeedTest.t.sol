// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "./TestContracts/DevTestSetup.sol";
import "../PriceFeeds/WEETHPriceFeed.sol";

contract WEETHPriceFeedTest is DevTestSetup {
    WEETHPriceFeed weethPriceFeed;

    function setUp() public override{
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
        assertEq(weethPriceFeed.lastGoodPrice(), 2560202217245400000000);
    }

    function testFetchPriceWeeth() public {
        (uint256 price, bool isDown) = weethPriceFeed.fetchPrice();
        assertEq(price, 2560202217245400000000);
        assertEq(isDown, false);
    }

    

}
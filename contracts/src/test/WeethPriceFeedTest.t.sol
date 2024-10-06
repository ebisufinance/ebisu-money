// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "./TestContracts/DevTestSetup.sol";
import "../PriceFeeds/WEETHPriceFeed.sol";
import "../PriceFeeds/EZETHPriceFeed.sol";
contract WEETHPriceFeedTest is DevTestSetup {
    WEETHPriceFeed weethPriceFeed;
    EZETHPriceFeed ezethPriceFeed;

    function setUp() public override{
        weethPriceFeed = new WEETHPriceFeed(
            address(this),
            address(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419),
            address(0x8751F736E94F6CD167e8C5B97E245680FbD9CC36),
            address(0xCd5fE23C85820F7B72D0926FC9b05b43E359b7ee),
            5184000,
            5184000
        );

        ezethPriceFeed = new EZETHPriceFeed(
            address(this),
            address(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419),
            address(0xF4a3e183F59D2599ee3DF213ff78b1B3b1923696),
            address(0xbf5495Efe5DB9ce00f80364C8B423567e58d2110),
            5184000,
            5184000
        );
    }

    function testLastGoodPriceWeeth() public {
        assertEq(weethPriceFeed.lastGoodPrice(), 2537315118026500000000);
    }
    function testLastGoodPriceEzeth() public {
        assertEq(ezethPriceFeed.lastGoodPrice(), 2537315118026500000000);
    }
    

}
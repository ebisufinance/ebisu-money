import {Script} from "forge-std/Script.sol";
import {WEETHPriceFeed} from "../PriceFeeds/WEETHPriceFeed.sol";
import "forge-std/console.sol";

uint256 constant _24_HOURS = 86400;
uint256 constant _48_HOURS = 172800;
uint256 constant _2_MONTHS = 5184000;

contract DeployWeethPriceFeed is Script {

    address ETHOracle = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    address WEETH_ADDRESS = 0xCd5fE23C85820F7B72D0926FC9b05b43E359b7ee;
    address WEETH_ORACLE = 0x8751F736E94F6CD167e8C5B97E245680FbD9CC36;

    uint256 ethUsdStalenessThreshold = _2_MONTHS;
    uint256 weethEthUsdStalenessThreshold = _2_MONTHS;

    function run() external {
            WEETHPriceFeed weethPriceFeed = new WEETHPriceFeed(
            address(this),
            ETHOracle,
            WEETH_ORACLE,
            WEETH_ADDRESS,
            ethUsdStalenessThreshold,
            weethEthUsdStalenessThreshold
        );

        console.log("WEETHPriceFeed deployed at: ", address(weethPriceFeed));
        uint256 lastGoodPrice = weethPriceFeed.lastGoodPrice();
        console.log("Last good price: ", lastGoodPrice);

    }
}
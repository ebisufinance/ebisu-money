import {Script} from "forge-std/Script.sol";
import "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "forge-std/console.sol";
contract TempTest is Script {


    function run() external {
        console.log("Hello, World!");
        console.log("msg sender: ", msg.sender);
        console.log("eth balance of msg sender: ", address(msg.sender).balance);
        address token = 0xb22cC1CeFcFa3132170a494f173f5a84585467ab;
        string memory tokenName = IERC20Metadata(token).name();
        console.log("the token name is ", tokenName);
    }
}
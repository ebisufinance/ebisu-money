import {Script} from "forge-std/Script.sol";
import "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "../Interfaces/IWETH.sol";
import "forge-std/console.sol";

contract SendWETH is Script {

    function run() external {
        address wethAddress = 0x25DD79a9D1D31B5aE0aAbcFe4Fe2A2cF1Ce8B43D;
        IWETH weth = IWETH(wethAddress);
        address recipient = 0x0F549aFb5743E16Fe09acC77a63617cA8Dd0696b;
        // Start broadcasting the transaction
        vm.startBroadcast();
        // Get the WETH balance of the sender
        uint256 wethBalance = weth.balanceOf(msg.sender);
        console.log("WETH balance of sender before transfer: ", wethBalance);

        // Approve the contract to spend WETH on behalf of the sender
        require(weth.approve(address(this), wethBalance), "Approval failed");

        // Transfer the entire WETH balance to the recipient
        require(weth.transferFrom(msg.sender, recipient, wethBalance), "Transfer failed");

        // Check the WETH balance after transfer
        wethBalance = weth.balanceOf(msg.sender);
        console.log("WETH balance of sender after transfer: ", wethBalance);

        // Print balance of recipient
        uint256 recipientBalance = weth.balanceOf(recipient);
        console.log("WETH balance of recipient: ", recipientBalance);

        // Stop broadcasting the transaction
        vm.stopBroadcast();
    }

    // Allow the contract to receive ETH
    receive() external payable {}
}
import {Script} from "forge-std/Script.sol";
import "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "../Interfaces/IWETH.sol";

import "forge-std/console.sol";

contract TempTest is Script {

    function run() external {
        address wethAddress = 0x25DD79a9D1D31B5aE0aAbcFe4Fe2A2cF1Ce8B43D;
        IWETH weth = IWETH(wethAddress);

        // Start broadcasting the transaction
        vm.startBroadcast();

        address recipient = 0x0F549aFb5743E16Fe09acC77a63617cA8Dd0696b;
        string memory tokenName = IERC20Metadata(wethAddress).name();
        console.log("the token name is ", tokenName);
//
        // Deposit 1 ether to get WETH
//        weth.deposit{value: 5 ether}();
//
        // Check the WETH balance
        uint256 wethBalance = weth.balanceOf(address(this));
        console.log("WETH balance after deposit: ", wethBalance);
//
        // Transfer the entire WETH balance to the recipient
//        require(weth.transfer(recipient, wethBalance), "Transfer failed");
//
//        // Check the WETH balance after transfer
//        wethBalance = weth.balanceOf(address(this));
//        console.log("WETH balance after transfer: ", wethBalance);

        // Print balance of recipient
        uint256 recipientBalance = weth.balanceOf(recipient);
        console.log("WETH balance of recipient: ", recipientBalance);

        uint256 msgSenderBalance = weth.balanceOf(msg.sender);
        console.log("WETH balance of msg.sender: ", msgSenderBalance);
        // send balance to recipient
//        require(weth.transfer(recipient, msgSenderBalance), "Transfer failed");
//
//        uint256 recipientBalanceAfter = weth.balanceOf(recipient);
//        console.log("WETH balance of recipient after : ", recipientBalanceAfter);

        // Stop broadcasting the transaction
        vm.stopBroadcast();
    }

    // Allow the contract to receive ETH
    receive() external payable {}
}
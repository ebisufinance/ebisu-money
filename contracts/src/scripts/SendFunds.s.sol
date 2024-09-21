// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import "forge-std/console.sol";

contract FundDeployer {
    function fund(address payable deployer) external payable {
        require(msg.value > 0, "Must send ETH to fund deployer");
        deployer.transfer(msg.value);
    }
}

contract SendFunds is Script {
    address payable recipient = payable(0xeba5864d192954D02FB0dA889bd1BD60493d83F6);
    uint256 amount_5_eth = 5 ether;

    function run() external {
        vm.startBroadcast();

        console.log("msg.sender: %s", msg.sender);
        console.log("recipient: %s", recipient);
        // console.log("sender balance: %s", sender.balance);
        console.log("address this balance: %s", address(this).balance);

        

        // Transfer 5 ether to recipient
        recipient.transfer(amount_5_eth);

        // Stop the broadcast
        vm.stopBroadcast();
    }
}
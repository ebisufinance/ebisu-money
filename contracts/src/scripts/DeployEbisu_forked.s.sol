pragma solidity ^0.8.18;
// SPDX-License-Identifier: MIT

import {Script} from "forge-std/Script.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {StringFormatting} from "../test/Utils/StringFormatting.sol";
import {TroveManagerParams, DeploymentResultMainnet} from "./Utils.sol";
import {MainnetAddresses} from "./MainnetAddresses.sol";
import {IWETH} from "../Interfaces/IWETH.sol";
import "forge-std/console.sol";



uint256 constant _24_HOURS = 86400;
uint256 constant _48_HOURS = 172800;
uint256 constant _2_MONTHS = 5184000;

contract DeployLiquity2Script is Script {
    using Strings for *;
    using StringFormatting for *;
    // Initialize MainnetAddresses instance
    MainnetAddresses mainnetAddresses = new MainnetAddresses();
    address deployer;
    IWETH weth = IWETH(mainnetAddresses.WETH());

    function run() external {

        uint256 privateKey = vm.envUint("DEPLOYER");
        deployer = vm.addr(privateKey);
        vm.startBroadcast(privateKey);

        console.log("Deploying Liquity2 contracts");
        console.log("Deployer address: ", deployer);
        console.log("weth address: ", address(weth));
        //create trove manager params
        TroveManagerParams[] memory troveManagerParamsArray = new TroveManagerParams[](3);

        troveManagerParamsArray[0] = TroveManagerParams(150e16, 110e16, 110e16, 5e16, 10e16); // WETH
        troveManagerParamsArray[1] = TroveManagerParams(150e16, 120e16, 110e16, 5e16, 10e16); // stETH
        troveManagerParamsArray[2] = TroveManagerParams(150e16, 120e16, 110e16, 5e16, 10e16); // weeth

        DeploymentResultMainnet memory deployed = _deployAndConnectContracts(troveManagerParamsArray, weth);
        vm.stopBroadcast();

        // vm.writeFile("deployment-manifest-ebisu.json", _getManifestJson(deployed));

    }

    function _deployAndConnectContracts(TroveManagerParams[] memory _troveManagerParamsArray, IWETH _weth) internal returns (DeploymentResultMainnet memory) {
        // Deploy contracts
        DeploymentResultMainnet memory result;

        result.externalAddresses.ETHOracle = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
        result.externalAddresses.WEETHETHOracle = mainnetAddresses.WEETH_ETH_ORACLE();
        result.externalAddresses.WEETHToken = mainnetAddresses.WEETH();


        return result;
    }

}
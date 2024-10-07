// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {console} from "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {StringFormatting} from "../test/Utils/StringFormatting.sol";
import {IEbusdToken} from "../Interfaces/IEbusdToken.sol";
import {ICollateralRegistry} from "../Interfaces/ICollateralRegistry.sol";
import {DECIMAL_PRECISION} from "../Dependencies/Constants.sol";

contract RedeemCollateral is Script {
    using Strings for *;
    using StringFormatting for *;

    function run() external {
        vm.startBroadcast();

        string memory manifestJson;
        try vm.readFile("deployment-manifest.json") returns (string memory content) {
            manifestJson = content;
        } catch {}

        ICollateralRegistry collateralRegistry;
        try vm.envAddress("COLLATERAL_REGISTRY") returns (address value) {
            collateralRegistry = ICollateralRegistry(value);
        } catch {
            collateralRegistry = ICollateralRegistry(vm.parseJsonAddress(manifestJson, ".collateralRegistry"));
        }
        vm.label(address(collateralRegistry), "CollateralRegistry");

        IEbusdToken ebusdToken = IEbusdToken(collateralRegistry.ebusdToken());
        vm.label(address(ebusdToken), "EbusdToken");

        uint256 ebusdBefore = ebusdToken.balanceOf(msg.sender);
        uint256[] memory collBefore = new uint256[](collateralRegistry.totalCollaterals());
        for (uint256 i = 0; i < collBefore.length; ++i) {
            collBefore[i] = collateralRegistry.getToken(i).balanceOf(msg.sender);
        }

        uint256 attemptedEbusdAmount = vm.envUint("AMOUNT") * DECIMAL_PRECISION;
        console.log("Attempting to redeem (EBUSD):", attemptedEbusdAmount.decimal());

        uint256 maxFeePct = collateralRegistry.getRedemptionRateForRedeemedAmount(attemptedEbusdAmount);
        collateralRegistry.redeemCollateral(attemptedEbusdAmount, 10, maxFeePct);

        uint256 actualEbusdAmount = ebusdBefore - ebusdToken.balanceOf(msg.sender);
        console.log("Actually redeemed (EBUSD):", actualEbusdAmount.decimal());

        uint256[] memory collAmount = new uint256[](collBefore.length);
        for (uint256 i = 0; i < collBefore.length; ++i) {
            collAmount[i] = collateralRegistry.getToken(i).balanceOf(msg.sender) - collBefore[i];
            console.log("Received coll", string.concat("#", i.toString(), ":"), collAmount[i].decimal());
        }
    }
}

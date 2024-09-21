// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
import {IAddressesRegistry} from "../interfaces/IAddressesRegistry.sol";
import {IActivePool} from "../interfaces/IActivePool.sol";
import {IBorrowerOperations} from "../interfaces/IBorrowerOperations.sol";
import {ICollSurplusPool} from "../interfaces/ICollSurplusPool.sol";
import {IDefaultPool} from "../interfaces/IDefaultPool.sol";
import {ISortedTroves} from "../interfaces/ISortedTroves.sol";
import {IStabilityPool} from "../interfaces/IStabilityPool.sol";
import {ITroveManager} from "../interfaces/ITroveManager.sol";
import {ITroveNFT} from "../interfaces/ITroveNFT.sol";
import {GasPool} from "../GasPool.sol";
import {MetadataNFT} from "../NFTMetadata/MetadataNFT.sol";
import {IPriceFeedTestnet} from "../test/TestContracts/Interfaces/IPriceFeedTestnet.sol";
import {IInterestRouter} from "../interfaces/IInterestRouter.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {WETHZapper} from "../Zappers/WETHZapper.sol";
import {GasCompZapper} from "../Zappers/GasCompZapper.sol";
import {IWETH} from "../Interfaces/IWETH.sol";
import {ICollateralRegistry} from "../interfaces/ICollateralRegistry.sol";
import {IBoldToken} from "../interfaces/IBoldToken.sol";
import {HintHelpers} from "../HintHelpers.sol";
import {MultiTroveGetter} from "../MultiTroveGetter.sol";
import {BoldToken} from "../BoldToken.sol";
import {ERC20Faucet} from "../test/TestContracts/ERC20Faucet.sol";
import {CollateralRegistry} from "../CollateralRegistry.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {StringFormatting} from "../test/Utils/StringFormatting.sol";
import "forge-std/console.sol";
import {AddressesRegistry} from "../AddressesRegistry.sol";
import {TroveManager} from "../TroveManager.sol";
pragma solidity ^0.8.18;

contract FundDeployer {
    function fund(address payable deployer) external payable {
        require(msg.value > 0, "Must send ETH to fund deployer");
        deployer.transfer(msg.value);
    }
}

contract OpenBranch is Script {
    using Strings for *;
    using StringFormatting for *;

    bytes32 SALT;
    address deployer;
    

    struct TroveManagerParams {
        uint256 CCR;
        uint256 MCR;
        uint256 SCR;
        uint256 LIQUIDATION_PENALTY_SP;
        uint256 LIQUIDATION_PENALTY_REDISTRIBUTION;
    }

    struct LiquityContractsTestnet {
        IAddressesRegistry addressesRegistry;
        IActivePool activePool;
        IBorrowerOperations borrowerOperations;
        ICollSurplusPool collSurplusPool;
        IDefaultPool defaultPool;
        ISortedTroves sortedTroves;
        IStabilityPool stabilityPool;
        ITroveManager troveManager;
        ITroveNFT troveNFT;
        MetadataNFT metadataNFT;
        IPriceFeedTestnet priceFeed; // Tester
        GasPool gasPool;
        IInterestRouter interestRouter;
        IERC20Metadata collToken;
        WETHZapper wethZapper;
        GasCompZapper gasCompZapper;
    }
    struct LiquityContractAddresses {
        address activePool;
        address borrowerOperations;
        address collSurplusPool;
        address defaultPool;
        address sortedTroves;
        address stabilityPool;
        address troveManager;
        address troveNFT;
        address metadataNFT;
        address priceFeed;
        address gasPool;
        address interestRouter;
    }
    struct DeploymentResult {
        LiquityContractsTestnet[] contractsArray;
        ICollateralRegistry collateralRegistry;
        IBoldToken boldToken;
        HintHelpers hintHelpers;
        MultiTroveGetter multiTroveGetter;
    }
    struct DeploymentVarsTestnet {
        uint256 numCollaterals;
        IERC20Metadata[] collaterals;
        IAddressesRegistry[] addressesRegistries;
        ITroveManager[] troveManagers;
        LiquityContractsTestnet contracts;
        bytes bytecode;
        address boldTokenAddress;
        uint256 i;
    }
    
    function run() external {
        //get the deployer from .env file
        uint256 privateKey = vm.envUint("DEPLOYER");
        deployer = vm.addr(privateKey);
        vm.startBroadcast(privateKey);

        console.log("Deployer: ", deployer);
        // Print the current sender
        console.log("Current sender: ", msg.sender);
        // Print current sender balance
        console.log("Current sender balance: ", msg.sender.balance);

       
        //create trove manager params
        TroveManagerParams memory troveManagerParams = TroveManagerParams(150e16, 120e16, 110e16, 5e16, 10e16);
        _deployBranchAndConnectContract(troveManagerParams);

        


    }



    function _deployBranchAndConnectContract(TroveManagerParams memory _troveManagerParams) internal {
        DeploymentVarsTestnet memory vars;
        vars.numCollaterals = 1;

        // Read the JSON file
        string memory json = vm.readFile("deployment-manifest.json");
        address boldToken = vm.parseJsonAddress(json, ".boldToken");
        console.log("boldToken: ", boldToken);

        vars.boldTokenAddress = boldToken;
        console.log("boldTokenAddress: ", vars.boldTokenAddress);

         // Deploy an ERC20Faucet
        ERC20Faucet faucet = new ERC20Faucet("Test LRT", "tLRT", 100 ether, 1 days);
        console.log("ERC20Faucet address: ", address(faucet));

        // (AddressesRegistry addressesRegistry, address troveManagerAddress) = _deployAddressesRegistry(_troveManagerParams);

        // console.log("AddressesRegistry address: ", address(addressesRegistry));
        // console.log("TroveManager predicted address: ", troveManagerAddress);
    }

    function _deployAddressesRegistry(TroveManagerParams memory _troveManagerParams)
        internal
        returns (AddressesRegistry, address)
    {
        console.log("deployer in internal func: ", deployer);
        AddressesRegistry addressesRegistry = new AddressesRegistry(
            deployer,
            _troveManagerParams.CCR,
            _troveManagerParams.MCR,
            _troveManagerParams.SCR,
            _troveManagerParams.LIQUIDATION_PENALTY_SP,
            _troveManagerParams.LIQUIDATION_PENALTY_REDISTRIBUTION
        );
        address troveManagerAddress = vm.computeCreate2Address(
            SALT, keccak256(getBytecode(type(TroveManager).creationCode, address(addressesRegistry)))
        ); // computes the address ahead of deployment

        return (addressesRegistry, troveManagerAddress);
    }

    function getBytecode(bytes memory _creationCode, address _addressesRegistry) public pure returns (bytes memory) {
        return abi.encodePacked(_creationCode, abi.encode(_addressesRegistry));
    }

}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "./TestContracts/DevTestSetup.sol";
import {ERC20Faucet} from "./TestContracts/ERC20Faucet.sol";
import {MultiTroveGetter} from "../MultiTroveGetter.sol";

contract DynamicCollateralRegistryTest is DevTestSetup {
    uint256 INITIAL_NUM_COLLATERALS = 4;
    TestDeployer.LiquityContractsDev[] public contractsArray;


    function setUp() public override {
        // Start tests at a non-zero timestamp
        vm.warp(block.timestamp + 600);

        accounts = new Accounts();
        createAccounts();

        (A, B, C, D, E, F, G) = (
            accountsList[0],
            accountsList[1],
            accountsList[2],
            accountsList[3],
            accountsList[4],
            accountsList[5],
            accountsList[6]
        );

        TestDeployer.TroveManagerParams[] memory troveManagerParamsArray =
                    new TestDeployer.TroveManagerParams[](INITIAL_NUM_COLLATERALS);
        troveManagerParamsArray[0] = TestDeployer.TroveManagerParams(150e16, 110e16, 110e16, 5e16, 10e16);
        troveManagerParamsArray[1] = TestDeployer.TroveManagerParams(160e16, 120e16, 120e16, 5e16, 10e16);
        troveManagerParamsArray[2] = TestDeployer.TroveManagerParams(160e16, 120e16, 120e16, 5e16, 10e16);
        troveManagerParamsArray[3] = TestDeployer.TroveManagerParams(160e16, 125e16, 125e16, 5e16, 10e16);

        TestDeployer deployer = new TestDeployer();
        TestDeployer.LiquityContractsDev[] memory _contractsArray;
        (_contractsArray, collateralRegistry, boldToken,,, WETH,) =
        deployer.deployAndConnectContractsMultiColl(troveManagerParamsArray);
        // Unimplemented feature (...):Copying of type struct LiquityContracts memory[] memory to storage not yet supported.
        for (uint256 c = 0; c < INITIAL_NUM_COLLATERALS; c++) {
            contractsArray.push(_contractsArray[c]);
        }
        // Set price feeds
        contractsArray[0].priceFeed.setPrice(2000e18);
        contractsArray[1].priceFeed.setPrice(200e18);
        contractsArray[2].priceFeed.setPrice(20000e18);
        contractsArray[3].priceFeed.setPrice(2500e18);
        // Just in case
        for (uint256 c = 4; c < INITIAL_NUM_COLLATERALS; c++) {
            contractsArray[c].priceFeed.setPrice(2000e18 + c * 1e18);
        }

        // Give some Collateral to test accounts, and approve it to BorrowerOperations
        uint256 initialCollateralAmount = 10_000e18;

        for (uint256 c = 0; c < INITIAL_NUM_COLLATERALS; c++) {
            for (uint256 i = 0; i < 6; i++) {
                // A to F
                giveAndApproveCollateral(
                    contractsArray[c].collToken,
                    accountsList[i],
                    initialCollateralAmount,
                    address(contractsArray[c].borrowerOperations)
                );
                // Approve WETH for gas compensation in all branches
                vm.startPrank(accountsList[i]);
                WETH.approve(address(contractsArray[c].borrowerOperations), type(uint256).max);
                vm.stopPrank();
            }
        }
    }

    function testMultiCollateralDeployment() public view {
        // check deployment
        assertEq(collateralRegistry.totalCollaterals(), INITIAL_NUM_COLLATERALS, "Wrong number of branches");
        for (uint256 c = 0; c < INITIAL_NUM_COLLATERALS; c++) {
            assertNotEq(address(collateralRegistry.getToken(c)), ZERO_ADDRESS, "Missing collateral token");
            assertNotEq(address(collateralRegistry.getTroveManager(c)), ZERO_ADDRESS, "Missing TroveManager");
        }
        for (uint256 c = INITIAL_NUM_COLLATERALS; c < 10; c++) {
            assertEq(address(collateralRegistry.getToken(c)), ZERO_ADDRESS, "Extra collateral token");
            assertEq(address(collateralRegistry.getTroveManager(c)), ZERO_ADDRESS, "Extra TroveManager");
        }
    }

    function deployBranch() public {

    }
    function testAddingNewBranch() public {
        // Add a new branch
        TestDeployer.TroveManagerParams memory troveManagerParams = TestDeployer.TroveManagerParams(160e16, 125e16, 125e16, 5e16, 10e16);

        IERC20Metadata newCollToken = new ERC20Faucet(
            "new Coll", // _name
            "nColl ", // _symbol
            100 ether, //     _tapAmount
            1 days //         _tapPeriod
        );
        HintHelpers hintHelpers = new HintHelpers(collateralRegistry);
        MultiTroveGetter multiTroveGetter = new MultiTroveGetter(collateralRegistry);


        TestDeployer deployer = new TestDeployer();

        deployer.deploySingleBranch(
            troveManagerParams,
        WETH,
        newCollToken,
            collateralRegistry,
            hintHelpers,
            multiTroveGetter
        );

        assertEq(collateralRegistry.totalCollaterals(), INITIAL_NUM_COLLATERALS + 1, "Wrong number of branches");

    }

}

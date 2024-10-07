// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "./TestContracts/DevTestSetup.sol";
import "./TestContracts/WETH.sol";
import "../Zappers/GasCompZapper.sol";

contract ZapperGasCompTest is DevTestSetup {
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

        WETH = new WETH9();

        TestDeployer.TroveManagerParams[] memory troveManagerParams = new TestDeployer.TroveManagerParams[](2);
        troveManagerParams[0] = TestDeployer.TroveManagerParams(150e16, 110e16, 110e16, 5e16, 10e16);
        troveManagerParams[1] = TestDeployer.TroveManagerParams(160e16, 120e16, 120e16, 5e16, 10e16);

        TestDeployer deployer = new TestDeployer();
        TestDeployer.LiquityContractsDev[] memory contractsArray;
        TestDeployer.Zappers[] memory zappersArray;
        (contractsArray, collateralRegistry, ebusdToken,,, zappersArray) =
            deployer.deployAndConnectContracts(troveManagerParams, WETH);

        // Set price feeds
        contractsArray[1].priceFeed.setPrice(2000e18);

        // Set first branch as default
        addressesRegistry = contractsArray[1].addressesRegistry;
        borrowerOperations = contractsArray[1].borrowerOperations;
        troveManager = contractsArray[1].troveManager;
        troveNFT = contractsArray[1].troveNFT;
        collToken = contractsArray[1].collToken;
        gasCompZapper = zappersArray[1].gasCompZapper;

        // Give some Collateral to test accounts
        uint256 initialCollateralAmount = 10_000e18;

        // A to F
        for (uint256 i = 0; i < 6; i++) {
            // Give some raw ETH to test accounts
            deal(accountsList[i], initialCollateralAmount);
            // Give and approve some coll token to test accounts
            deal(address(collToken), accountsList[i], initialCollateralAmount);
            vm.startPrank(accountsList[i]);
            collToken.approve(address(gasCompZapper), initialCollateralAmount);
            vm.stopPrank();
        }
    }

    function testCanOpenTrove() external {
        uint256 collAmount = 10 ether;
        uint256 ebusdAmount = 10000e18;

        uint256 ethBalanceBefore = A.balance;
        uint256 collBalanceBefore = collToken.balanceOf(A);

        GasCompZapper.OpenTroveParams memory params = GasCompZapper.OpenTroveParams({
            owner: A,
            ownerIndex: 0,
            collAmount: collAmount,
            ebusdAmount: ebusdAmount,
            upperHint: 0,
            lowerHint: 0,
            annualInterestRate: 5e16,
            maxUpfrontFee: 1000e18,
            addManager: address(0),
            removeManager: address(0),
            receiver: address(0)
        });
        vm.startPrank(A);
        uint256 troveId = gasCompZapper.openTroveWithRawETH{value: ETH_GAS_COMPENSATION}(params);
        vm.stopPrank();

        assertEq(troveNFT.ownerOf(troveId), A, "Wrong owner");
        assertGt(troveId, 0, "Trove id should be set");
        assertEq(troveManager.getTroveEntireColl(troveId), collAmount, "Coll mismatch");
        assertGt(troveManager.getTroveEntireDebt(troveId), ebusdAmount, "Debt mismatch");
        assertEq(ebusdToken.balanceOf(A), ebusdAmount, "EBUSD bal mismatch");
        assertEq(A.balance, ethBalanceBefore - ETH_GAS_COMPENSATION, "ETH bal mismatch");
        assertEq(collToken.balanceOf(A), collBalanceBefore - collAmount, "Coll bal mismatch");
    }

    function testCanAddColl() external {
        uint256 collAmount1 = 10 ether;
        uint256 ebusdAmount = 10000e18;
        uint256 collAmount2 = 5 ether;

        GasCompZapper.OpenTroveParams memory params = GasCompZapper.OpenTroveParams({
            owner: A,
            ownerIndex: 0,
            collAmount: collAmount1,
            ebusdAmount: ebusdAmount,
            upperHint: 0,
            lowerHint: 0,
            annualInterestRate: 5e16,
            maxUpfrontFee: 1000e18,
            addManager: address(0),
            removeManager: address(0),
            receiver: address(0)
        });
        vm.startPrank(A);
        uint256 troveId = gasCompZapper.openTroveWithRawETH{value: ETH_GAS_COMPENSATION}(params);
        vm.stopPrank();

        uint256 collBalanceBefore = collToken.balanceOf(A);
        vm.startPrank(A);
        gasCompZapper.addColl(troveId, collAmount2);
        vm.stopPrank();

        assertEq(troveManager.getTroveEntireColl(troveId), collAmount1 + collAmount2, "Coll mismatch");
        assertGt(troveManager.getTroveEntireDebt(troveId), ebusdAmount, "Debt mismatch");
        assertEq(ebusdToken.balanceOf(A), ebusdAmount, "EBUSD bal mismatch");
        assertEq(collToken.balanceOf(A), collBalanceBefore - collAmount2, "Coll bal mismatch");
    }

    function testCanWithdrawColl() external {
        uint256 collAmount1 = 10 ether;
        uint256 ebusdAmount = 10000e18;
        uint256 collAmount2 = 1 ether;

        GasCompZapper.OpenTroveParams memory params = GasCompZapper.OpenTroveParams({
            owner: A,
            ownerIndex: 0,
            collAmount: collAmount1,
            ebusdAmount: ebusdAmount,
            upperHint: 0,
            lowerHint: 0,
            annualInterestRate: 5e16,
            maxUpfrontFee: 1000e18,
            addManager: address(0),
            removeManager: address(0),
            receiver: address(0)
        });
        vm.startPrank(A);
        uint256 troveId = gasCompZapper.openTroveWithRawETH{value: ETH_GAS_COMPENSATION}(params);
        vm.stopPrank();

        uint256 collBalanceBefore = collToken.balanceOf(A);
        vm.startPrank(A);
        gasCompZapper.withdrawColl(troveId, collAmount2);
        vm.stopPrank();

        assertEq(troveManager.getTroveEntireColl(troveId), collAmount1 - collAmount2, "Coll mismatch");
        assertGt(troveManager.getTroveEntireDebt(troveId), ebusdAmount, "Debt mismatch");
        assertEq(ebusdToken.balanceOf(A), ebusdAmount, "EBUSD bal mismatch");
        assertEq(collToken.balanceOf(A), collBalanceBefore + collAmount2, "Coll bal mismatch");
    }

    function testCanRepayEbusd() external {
        uint256 collAmount = 10 ether;
        uint256 ebusdAmount1 = 10000e18;
        uint256 ebusdAmount2 = 1000e18;

        GasCompZapper.OpenTroveParams memory params = GasCompZapper.OpenTroveParams({
            owner: A,
            ownerIndex: 0,
            collAmount: collAmount,
            ebusdAmount: ebusdAmount1,
            upperHint: 0,
            lowerHint: 0,
            annualInterestRate: MIN_ANNUAL_INTEREST_RATE,
            maxUpfrontFee: 1000e18,
            addManager: address(0),
            removeManager: address(0),
            receiver: address(0)
        });
        vm.startPrank(A);
        uint256 troveId = gasCompZapper.openTroveWithRawETH{value: ETH_GAS_COMPENSATION}(params);
        vm.stopPrank();

        uint256 ebusdBalanceBeforeA = ebusdToken.balanceOf(A);
        uint256 collBalanceBeforeA = collToken.balanceOf(A);
        uint256 ebusdBalanceBeforeB = ebusdToken.balanceOf(B);
        uint256 collBalanceBeforeB = collToken.balanceOf(B);

        // Add a remove manager for the zapper, and send ebusd
        vm.startPrank(A);
        gasCompZapper.setRemoveManagerWithReceiver(troveId, B, A);
        ebusdToken.transfer(B, ebusdAmount2);
        vm.stopPrank();

        // Approve and repay
        vm.startPrank(B);
        ebusdToken.approve(address(gasCompZapper), ebusdAmount2);
        gasCompZapper.repayEbusd(troveId, ebusdAmount2);
        vm.stopPrank();

        assertEq(troveManager.getTroveEntireColl(troveId), collAmount, "Trove coll mismatch");
        assertApproxEqAbs(
            troveManager.getTroveEntireDebt(troveId), ebusdAmount1 - ebusdAmount2, 2e18, "Trove  debt mismatch"
        );
        assertEq(ebusdToken.balanceOf(A), ebusdBalanceBeforeA - ebusdAmount2, "A EBUSD bal mismatch");
        assertEq(collToken.balanceOf(A), collBalanceBeforeA, "A Coll bal mismatch");
        assertEq(ebusdToken.balanceOf(B), ebusdBalanceBeforeB, "B EBUSD bal mismatch");
        assertEq(collToken.balanceOf(B), collBalanceBeforeB, "B Coll bal mismatch");
    }

    function testCanWithdrawEbusd() external {
        uint256 collAmount = 10 ether;
        uint256 ebusdAmount1 = 10000e18;
        uint256 ebusdAmount2 = 1000e18;

        GasCompZapper.OpenTroveParams memory params = GasCompZapper.OpenTroveParams({
            owner: A,
            ownerIndex: 0,
            collAmount: collAmount,
            ebusdAmount: ebusdAmount1,
            upperHint: 0,
            lowerHint: 0,
            annualInterestRate: MIN_ANNUAL_INTEREST_RATE,
            maxUpfrontFee: 1000e18,
            addManager: address(0),
            removeManager: address(0),
            receiver: address(0)
        });
        vm.startPrank(A);
        uint256 troveId = gasCompZapper.openTroveWithRawETH{value: ETH_GAS_COMPENSATION}(params);
        vm.stopPrank();

        uint256 ebusdBalanceBeforeA = ebusdToken.balanceOf(A);
        uint256 collBalanceBeforeA = collToken.balanceOf(A);
        uint256 ebusdBalanceBeforeB = ebusdToken.balanceOf(B);
        uint256 collBalanceBeforeB = collToken.balanceOf(B);

        // Add a remove manager for the zapper
        vm.startPrank(A);
        gasCompZapper.setRemoveManagerWithReceiver(troveId, B, A);
        vm.stopPrank();

        // Withdraw ebusd
        vm.startPrank(B);
        gasCompZapper.withdrawEbusd(troveId, ebusdAmount2, ebusdAmount2);
        vm.stopPrank();

        assertEq(troveManager.getTroveEntireColl(troveId), collAmount, "Trove coll mismatch");
        assertApproxEqAbs(
            troveManager.getTroveEntireDebt(troveId), ebusdAmount1 + ebusdAmount2, 2e18, "Trove  debt mismatch"
        );
        assertEq(ebusdToken.balanceOf(A), ebusdBalanceBeforeA + ebusdAmount2, "A EBUSD bal mismatch");
        assertEq(collToken.balanceOf(A), collBalanceBeforeA, "A Coll bal mismatch");
        assertEq(ebusdToken.balanceOf(B), ebusdBalanceBeforeB, "B EBUSD bal mismatch");
        assertEq(collToken.balanceOf(B), collBalanceBeforeB, "B Coll bal mismatch");
    }

    // TODO: more adjustment combinations
    function testCanAdjustTroveWithdrawCollAndEbusd() external {
        uint256 collAmount1 = 10 ether;
        uint256 collAmount2 = 1 ether;
        uint256 ebusdAmount1 = 10000e18;
        uint256 ebusdAmount2 = 1000e18;

        GasCompZapper.OpenTroveParams memory params = GasCompZapper.OpenTroveParams({
            owner: A,
            ownerIndex: 0,
            collAmount: collAmount1,
            ebusdAmount: ebusdAmount1,
            upperHint: 0,
            lowerHint: 0,
            annualInterestRate: MIN_ANNUAL_INTEREST_RATE,
            maxUpfrontFee: 1000e18,
            addManager: address(0),
            removeManager: address(0),
            receiver: address(0)
        });
        vm.startPrank(A);
        uint256 troveId = gasCompZapper.openTroveWithRawETH{value: ETH_GAS_COMPENSATION}(params);
        vm.stopPrank();

        uint256 ebusdBalanceBeforeA = ebusdToken.balanceOf(A);
        uint256 collBalanceBeforeA = collToken.balanceOf(A);
        uint256 ebusdBalanceBeforeB = ebusdToken.balanceOf(B);
        uint256 collBalanceBeforeB = collToken.balanceOf(B);

        // Add a remove manager for the zapper
        vm.startPrank(A);
        gasCompZapper.setRemoveManagerWithReceiver(troveId, B, A);
        vm.stopPrank();

        // Adjust (withdraw coll and Ebusd)
        vm.startPrank(B);
        gasCompZapper.adjustTroveWithRawETH(troveId, collAmount2, false, ebusdAmount2, true, ebusdAmount2);
        vm.stopPrank();

        assertEq(troveManager.getTroveEntireColl(troveId), collAmount1 - collAmount2, "Trove coll mismatch");
        assertApproxEqAbs(
            troveManager.getTroveEntireDebt(troveId), ebusdAmount1 + ebusdAmount2, 2e18, "Trove  debt mismatch"
        );
        assertEq(ebusdToken.balanceOf(A), ebusdBalanceBeforeA + ebusdAmount2, "A EBUSD bal mismatch");
        assertEq(collToken.balanceOf(A), collBalanceBeforeA + collAmount2, "A Coll bal mismatch");
        assertEq(ebusdToken.balanceOf(B), ebusdBalanceBeforeB, "B EBUSD bal mismatch");
        assertEq(collToken.balanceOf(B), collBalanceBeforeB, "B Coll bal mismatch");
    }

    // TODO: more adjustment combinations
    function testCanAdjustZombieTroveWithdrawCollAndEbusd() external {
        uint256 collAmount1 = 10 ether;
        uint256 collAmount2 = 1 ether;
        uint256 ebusdAmount1 = 10000e18;
        uint256 ebusdAmount2 = 1000e18;

        GasCompZapper.OpenTroveParams memory params = GasCompZapper.OpenTroveParams({
            owner: A,
            ownerIndex: 0,
            collAmount: collAmount1,
            ebusdAmount: ebusdAmount1,
            upperHint: 0,
            lowerHint: 0,
            annualInterestRate: MIN_ANNUAL_INTEREST_RATE,
            maxUpfrontFee: 1000e18,
            addManager: address(0),
            removeManager: address(0),
            receiver: address(0)
        });
        vm.startPrank(A);
        uint256 troveId = gasCompZapper.openTroveWithRawETH{value: ETH_GAS_COMPENSATION}(params);
        vm.stopPrank();

        // Add a remove manager for the zapper
        vm.startPrank(A);
        gasCompZapper.setRemoveManagerWithReceiver(troveId, B, A);
        vm.stopPrank();

        // Redeem to make trove zombie
        vm.startPrank(A);
        collateralRegistry.redeemCollateral(ebusdAmount1 - ebusdAmount2, 10, 1e18);
        vm.stopPrank();

        uint256 troveCollBefore = troveManager.getTroveEntireColl(troveId);
        uint256 ebusdBalanceBeforeA = ebusdToken.balanceOf(A);
        uint256 collBalanceBeforeA = collToken.balanceOf(A);
        uint256 collBalanceBeforeB = collToken.balanceOf(B);

        // Adjust (withdraw coll and Ebusd)
        vm.startPrank(B);
        gasCompZapper.adjustZombieTroveWithRawETH(troveId, collAmount2, false, ebusdAmount2, true, 0, 0, ebusdAmount2);
        vm.stopPrank();

        assertEq(troveManager.getTroveEntireColl(troveId), troveCollBefore - collAmount2, "Trove coll mismatch");
        assertApproxEqAbs(troveManager.getTroveEntireDebt(troveId), 2 * ebusdAmount2, 2e18, "Trove  debt mismatch");
        assertEq(ebusdToken.balanceOf(A), ebusdBalanceBeforeA + ebusdAmount2, "A EBUSD bal mismatch");
        assertEq(collToken.balanceOf(A), collBalanceBeforeA + collAmount2, "A Coll bal mismatch");
        assertEq(ebusdToken.balanceOf(B), 0, "B EBUSD bal mismatch");
        assertEq(collToken.balanceOf(B), collBalanceBeforeB, "B Coll bal mismatch");
    }

    function testCanCloseTrove() external {
        uint256 collAmount = 10 ether;
        uint256 ebusdAmount = 10000e18;

        uint256 ethBalanceBefore = A.balance;
        uint256 collBalanceBefore = collToken.balanceOf(A);

        GasCompZapper.OpenTroveParams memory params = GasCompZapper.OpenTroveParams({
            owner: A,
            ownerIndex: 0,
            collAmount: collAmount,
            ebusdAmount: ebusdAmount,
            upperHint: 0,
            lowerHint: 0,
            annualInterestRate: MIN_ANNUAL_INTEREST_RATE,
            maxUpfrontFee: 1000e18,
            addManager: address(0),
            removeManager: address(0),
            receiver: address(0)
        });
        vm.startPrank(A);
        uint256 troveId = gasCompZapper.openTroveWithRawETH{value: ETH_GAS_COMPENSATION}(params);
        vm.stopPrank();

        // open a 2nd trove so we can close the 1st one, and send Ebusd to account for interest and fee
        vm.startPrank(B);
        deal(address(WETH), B, ETH_GAS_COMPENSATION);
        WETH.approve(address(borrowerOperations), ETH_GAS_COMPENSATION);
        deal(address(collToken), B, 100 ether);
        collToken.approve(address(borrowerOperations), 100 ether);
        borrowerOperations.openTrove(
            B,
            0, // index,
            100 ether, // coll,
            10000e18, //ebusdAmount,
            0, // _upperHint
            0, // _lowerHint
            MIN_ANNUAL_INTEREST_RATE, // annualInterestRate,
            10000e18, // upfrontFee
            address(0),
            address(0),
            address(0)
        );
        ebusdToken.transfer(A, troveManager.getTroveEntireDebt(troveId) - ebusdAmount);
        vm.stopPrank();

        vm.startPrank(A);
        ebusdToken.approve(address(gasCompZapper), type(uint256).max);
        gasCompZapper.closeTroveToRawETH(troveId);
        vm.stopPrank();

        assertEq(troveManager.getTroveEntireColl(troveId), 0, "Coll mismatch");
        assertEq(troveManager.getTroveEntireDebt(troveId), 0, "Debt mismatch");
        assertEq(ebusdToken.balanceOf(A), 0, "EBUSD bal mismatch");
        assertEq(A.balance, ethBalanceBefore, "ETH bal mismatch");
        assertEq(collToken.balanceOf(A), collBalanceBefore, "Coll bal mismatch");
    }
}

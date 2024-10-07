// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "./TestContracts/DevTestSetup.sol";
import "./TestContracts/WETH.sol";
import "../Zappers/WETHZapper.sol";

contract ZapperWETHTest is DevTestSetup {
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

        TestDeployer.TroveManagerParams[] memory troveManagerParams = new TestDeployer.TroveManagerParams[](1);
        troveManagerParams[0] = TestDeployer.TroveManagerParams(150e16, 110e16, 110e16, 5e16, 10e16);

        TestDeployer deployer = new TestDeployer();
        TestDeployer.LiquityContractsDev[] memory contractsArray;
        TestDeployer.Zappers[] memory zappersArray;
        (contractsArray, collateralRegistry, ebusdToken,,, zappersArray) =
            deployer.deployAndConnectContracts(troveManagerParams, WETH);

        // Set price feeds
        contractsArray[0].priceFeed.setPrice(2000e18);

        // Give some Collateral to test accounts
        uint256 initialCollateralAmount = 10_000e18;

        // A to F
        for (uint256 i = 0; i < 6; i++) {
            // Give some raw ETH to test accounts
            deal(accountsList[i], initialCollateralAmount);
        }

        // Set first branch as default
        addressesRegistry = contractsArray[0].addressesRegistry;
        borrowerOperations = contractsArray[0].borrowerOperations;
        troveManager = contractsArray[0].troveManager;
        troveNFT = contractsArray[0].troveNFT;
        wethZapper = zappersArray[0].wethZapper;
    }

    function testCanOpenTrove() external {
        uint256 ethAmount = 10 ether;
        uint256 ebusdAmount = 10000e18;

        uint256 ethBalanceBefore = A.balance;

        WETHZapper.OpenTroveParams memory params = WETHZapper.OpenTroveParams({
            owner: A,
            ownerIndex: 0,
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
        uint256 troveId = wethZapper.openTroveWithRawETH{value: ethAmount + ETH_GAS_COMPENSATION}(params);
        vm.stopPrank();

        assertEq(troveNFT.ownerOf(troveId), A, "Wrong owner");
        assertGt(troveId, 0, "Trove id should be set");
        assertEq(troveManager.getTroveEntireColl(troveId), ethAmount, "Coll mismatch");
        assertGt(troveManager.getTroveEntireDebt(troveId), ebusdAmount, "Debt mismatch");
        assertEq(ebusdToken.balanceOf(A), ebusdAmount, "EBUSD bal mismatch");
        assertEq(A.balance, ethBalanceBefore - (ethAmount + ETH_GAS_COMPENSATION), "ETH bal mismatch");
    }

    function testCanAddColl() external {
        uint256 ethAmount1 = 10 ether;
        uint256 ebusdAmount = 10000e18;
        uint256 ethAmount2 = 5 ether;

        WETHZapper.OpenTroveParams memory params = WETHZapper.OpenTroveParams({
            owner: A,
            ownerIndex: 0,
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
        uint256 troveId = wethZapper.openTroveWithRawETH{value: ethAmount1 + ETH_GAS_COMPENSATION}(params);
        vm.stopPrank();

        uint256 ethBalanceBefore = A.balance;
        vm.startPrank(A);
        wethZapper.addCollWithRawETH{value: ethAmount2}(troveId);
        vm.stopPrank();

        assertEq(troveManager.getTroveEntireColl(troveId), ethAmount1 + ethAmount2, "Coll mismatch");
        assertGt(troveManager.getTroveEntireDebt(troveId), ebusdAmount, "Debt mismatch");
        assertEq(ebusdToken.balanceOf(A), ebusdAmount, "EBUSD bal mismatch");
        assertEq(A.balance, ethBalanceBefore - ethAmount2, "ETH bal mismatch");
    }

    function testCanWithdrawColl() external {
        uint256 ethAmount1 = 10 ether;
        uint256 ebusdAmount = 10000e18;
        uint256 ethAmount2 = 1 ether;

        WETHZapper.OpenTroveParams memory params = WETHZapper.OpenTroveParams({
            owner: A,
            ownerIndex: 0,
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
        uint256 troveId = wethZapper.openTroveWithRawETH{value: ethAmount1 + ETH_GAS_COMPENSATION}(params);
        vm.stopPrank();

        uint256 ethBalanceBefore = A.balance;
        vm.startPrank(A);
        wethZapper.withdrawCollToRawETH(troveId, ethAmount2);
        vm.stopPrank();

        assertEq(troveManager.getTroveEntireColl(troveId), ethAmount1 - ethAmount2, "Coll mismatch");
        assertGt(troveManager.getTroveEntireDebt(troveId), ebusdAmount, "Debt mismatch");
        assertEq(ebusdToken.balanceOf(A), ebusdAmount, "EBUSD bal mismatch");
        assertEq(A.balance, ethBalanceBefore + ethAmount2, "ETH bal mismatch");
    }

    function testCanRepayEbusd() external {
        uint256 ethAmount = 10 ether;
        uint256 ebusdAmount1 = 10000e18;
        uint256 ebusdAmount2 = 1000e18;

        WETHZapper.OpenTroveParams memory params = WETHZapper.OpenTroveParams({
            owner: A,
            ownerIndex: 0,
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
        uint256 troveId = wethZapper.openTroveWithRawETH{value: ethAmount + ETH_GAS_COMPENSATION}(params);
        vm.stopPrank();

        uint256 ebusdBalanceBeforeA = ebusdToken.balanceOf(A);
        uint256 ethBalanceBeforeA = A.balance;
        uint256 ebusdBalanceBeforeB = ebusdToken.balanceOf(B);
        uint256 ethBalanceBeforeB = B.balance;

        // Add a remove manager for the zapper, and send ebusd
        vm.startPrank(A);
        wethZapper.setRemoveManagerWithReceiver(troveId, B, A);
        ebusdToken.transfer(B, ebusdAmount2);
        vm.stopPrank();

        // Approve and repay
        vm.startPrank(B);
        ebusdToken.approve(address(wethZapper), ebusdAmount2);
        wethZapper.repayEbusd(troveId, ebusdAmount2);
        vm.stopPrank();

        assertEq(troveManager.getTroveEntireColl(troveId), ethAmount, "Trove coll mismatch");
        assertApproxEqAbs(
            troveManager.getTroveEntireDebt(troveId), ebusdAmount1 - ebusdAmount2, 2e18, "Trove  debt mismatch"
        );
        assertEq(ebusdToken.balanceOf(A), ebusdBalanceBeforeA - ebusdAmount2, "A EBUSD bal mismatch");
        assertEq(A.balance, ethBalanceBeforeA, "A ETH bal mismatch");
        assertEq(ebusdToken.balanceOf(B), ebusdBalanceBeforeB, "B EBUSD bal mismatch");
        assertEq(B.balance, ethBalanceBeforeB, "B ETH bal mismatch");
    }

    function testCanWithdrawEbusd() external {
        uint256 ethAmount = 10 ether;
        uint256 ebusdAmount1 = 10000e18;
        uint256 ebusdAmount2 = 1000e18;

        WETHZapper.OpenTroveParams memory params = WETHZapper.OpenTroveParams({
            owner: A,
            ownerIndex: 0,
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
        uint256 troveId = wethZapper.openTroveWithRawETH{value: ethAmount + ETH_GAS_COMPENSATION}(params);
        vm.stopPrank();

        uint256 ebusdBalanceBeforeA = ebusdToken.balanceOf(A);
        uint256 ethBalanceBeforeA = A.balance;
        uint256 ebusdBalanceBeforeB = ebusdToken.balanceOf(B);
        uint256 ethBalanceBeforeB = B.balance;

        // Add a remove manager for the zapper
        vm.startPrank(A);
        wethZapper.setRemoveManagerWithReceiver(troveId, B, A);
        vm.stopPrank();

        // Withdraw ebusd
        vm.startPrank(B);
        wethZapper.withdrawEbusd(troveId, ebusdAmount2, ebusdAmount2);
        vm.stopPrank();

        assertEq(troveManager.getTroveEntireColl(troveId), ethAmount, "Trove coll mismatch");
        assertApproxEqAbs(
            troveManager.getTroveEntireDebt(troveId), ebusdAmount1 + ebusdAmount2, 2e18, "Trove  debt mismatch"
        );
        assertEq(ebusdToken.balanceOf(A), ebusdBalanceBeforeA + ebusdAmount2, "A EBUSD bal mismatch");
        assertEq(A.balance, ethBalanceBeforeA, "A ETH bal mismatch");
        assertEq(ebusdToken.balanceOf(B), ebusdBalanceBeforeB, "B EBUSD bal mismatch");
        assertEq(B.balance, ethBalanceBeforeB, "B ETH bal mismatch");
    }

    // TODO: more adjustment combinations
    function testCanAdjustTroveWithdrawCollAndEbusd() external {
        uint256 ethAmount1 = 10 ether;
        uint256 ethAmount2 = 1 ether;
        uint256 ebusdAmount1 = 10000e18;
        uint256 ebusdAmount2 = 1000e18;

        WETHZapper.OpenTroveParams memory params = WETHZapper.OpenTroveParams({
            owner: A,
            ownerIndex: 0,
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
        uint256 troveId = wethZapper.openTroveWithRawETH{value: ethAmount1 + ETH_GAS_COMPENSATION}(params);
        vm.stopPrank();

        uint256 ebusdBalanceBeforeA = ebusdToken.balanceOf(A);
        uint256 ethBalanceBeforeA = A.balance;
        uint256 ebusdBalanceBeforeB = ebusdToken.balanceOf(B);
        uint256 ethBalanceBeforeB = B.balance;

        // Add a remove manager for the zapper
        vm.startPrank(A);
        wethZapper.setRemoveManagerWithReceiver(troveId, B, A);
        vm.stopPrank();

        // Adjust (withdraw coll and Ebusd)
        vm.startPrank(B);
        wethZapper.adjustTroveWithRawETH(troveId, ethAmount2, false, ebusdAmount2, true, ebusdAmount2);
        vm.stopPrank();

        assertEq(troveManager.getTroveEntireColl(troveId), ethAmount1 - ethAmount2, "Trove coll mismatch");
        assertApproxEqAbs(
            troveManager.getTroveEntireDebt(troveId), ebusdAmount1 + ebusdAmount2, 2e18, "Trove  debt mismatch"
        );
        assertEq(ebusdToken.balanceOf(A), ebusdBalanceBeforeA + ebusdAmount2, "A EBUSD bal mismatch");
        assertEq(A.balance, ethBalanceBeforeA + ethAmount2, "A ETH bal mismatch");
        assertEq(ebusdToken.balanceOf(B), ebusdBalanceBeforeB, "B EBUSD bal mismatch");
        assertEq(B.balance, ethBalanceBeforeB, "B ETH bal mismatch");
    }

    function testCanAdjustTroveAddCollAndEbusd() external {
        uint256 ethAmount1 = 10 ether;
        uint256 ethAmount2 = 1 ether;
        uint256 ebusdAmount1 = 10000e18;
        uint256 ebusdAmount2 = 1000e18;

        WETHZapper.OpenTroveParams memory params = WETHZapper.OpenTroveParams({
            owner: A,
            ownerIndex: 0,
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
        uint256 troveId = wethZapper.openTroveWithRawETH{value: ethAmount1 + ETH_GAS_COMPENSATION}(params);
        // A sends Ebusd to B
        ebusdToken.transfer(B, ebusdAmount2);
        vm.stopPrank();

        uint256 ebusdBalanceBeforeA = ebusdToken.balanceOf(A);
        uint256 ethBalanceBeforeA = A.balance;
        uint256 ebusdBalanceBeforeB = ebusdToken.balanceOf(B);
        uint256 ethBalanceBeforeB = B.balance;

        // Add an add manager for the zapper
        vm.startPrank(A);
        wethZapper.setAddManager(troveId, B);
        vm.stopPrank();

        // Adjust (add coll and Ebusd)
        vm.startPrank(B);
        ebusdToken.approve(address(wethZapper), ebusdAmount2);
        wethZapper.adjustTroveWithRawETH{value: ethAmount2}(troveId, ethAmount2, true, ebusdAmount2, false, ebusdAmount2);
        vm.stopPrank();

        assertEq(troveManager.getTroveEntireColl(troveId), ethAmount1 + ethAmount2, "Trove coll mismatch");
        assertApproxEqAbs(
            troveManager.getTroveEntireDebt(troveId), ebusdAmount1 - ebusdAmount2, 2e18, "Trove  debt mismatch"
        );
        assertEq(ebusdToken.balanceOf(A), ebusdBalanceBeforeA, "A EBUSD bal mismatch");
        assertEq(A.balance, ethBalanceBeforeA, "A ETH bal mismatch");
        assertEq(ebusdToken.balanceOf(B), ebusdBalanceBeforeB - ebusdAmount2, "B EBUSD bal mismatch");
        assertEq(B.balance, ethBalanceBeforeB - ethAmount2, "B ETH bal mismatch");
    }

    // TODO: more adjustment combinations
    function testCanAdjustZombieTroveWithdrawCollAndEbusd() external {
        uint256 ethAmount1 = 10 ether;
        uint256 ethAmount2 = 1 ether;
        uint256 ebusdAmount1 = 10000e18;
        uint256 ebusdAmount2 = 1000e18;

        WETHZapper.OpenTroveParams memory params = WETHZapper.OpenTroveParams({
            owner: A,
            ownerIndex: 0,
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
        uint256 troveId = wethZapper.openTroveWithRawETH{value: ethAmount1 + ETH_GAS_COMPENSATION}(params);
        vm.stopPrank();

        // Add a remove manager for the zapper
        vm.startPrank(A);
        wethZapper.setRemoveManagerWithReceiver(troveId, B, A);
        vm.stopPrank();

        // Redeem to make trove zombie
        vm.startPrank(A);
        collateralRegistry.redeemCollateral(ebusdAmount1 - ebusdAmount2, 10, 1e18);
        vm.stopPrank();

        uint256 troveCollBefore = troveManager.getTroveEntireColl(troveId);
        uint256 ebusdBalanceBeforeA = ebusdToken.balanceOf(A);
        uint256 ethBalanceBeforeA = A.balance;
        uint256 ethBalanceBeforeB = B.balance;

        // Adjust (withdraw coll and Ebusd)
        vm.startPrank(B);
        wethZapper.adjustZombieTroveWithRawETH(troveId, ethAmount2, false, ebusdAmount2, true, 0, 0, ebusdAmount2);
        vm.stopPrank();

        assertEq(troveManager.getTroveEntireColl(troveId), troveCollBefore - ethAmount2, "Trove coll mismatch");
        assertApproxEqAbs(troveManager.getTroveEntireDebt(troveId), 2 * ebusdAmount2, 2e18, "Trove  debt mismatch");
        assertEq(ebusdToken.balanceOf(A), ebusdBalanceBeforeA + ebusdAmount2, "A EBUSD bal mismatch");
        assertEq(A.balance, ethBalanceBeforeA + ethAmount2, "A ETH bal mismatch");
        assertEq(ebusdToken.balanceOf(B), 0, "B EBUSD bal mismatch");
        assertEq(B.balance, ethBalanceBeforeB, "B ETH bal mismatch");
    }

    function testCanCloseTrove() external {
        uint256 ethAmount = 10 ether;
        uint256 ebusdAmount = 10000e18;

        uint256 ethBalanceBefore = A.balance;

        WETHZapper.OpenTroveParams memory params = WETHZapper.OpenTroveParams({
            owner: A,
            ownerIndex: 0,
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
        uint256 troveId = wethZapper.openTroveWithRawETH{value: ethAmount + ETH_GAS_COMPENSATION}(params);
        vm.stopPrank();

        // open a 2nd trove so we can close the 1st one, and send Ebusd to account for interest and fee
        vm.startPrank(B);
        deal(address(WETH), B, 100 ether + ETH_GAS_COMPENSATION);
        WETH.approve(address(borrowerOperations), 100 ether + ETH_GAS_COMPENSATION);
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
        ebusdToken.approve(address(wethZapper), type(uint256).max);
        wethZapper.closeTroveToRawETH(troveId);
        vm.stopPrank();

        assertEq(troveManager.getTroveEntireColl(troveId), 0, "Coll mismatch");
        assertEq(troveManager.getTroveEntireDebt(troveId), 0, "Debt mismatch");
        assertEq(ebusdToken.balanceOf(A), 0, "EBUSD bal mismatch");
        assertEq(A.balance, ethBalanceBefore, "ETH bal mismatch");
    }
}

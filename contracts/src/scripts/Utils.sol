pragma solidity ^0.8.18;
// SPDX-License-Identifier: MIT
import {ICollateralRegistry} from "../Interfaces/ICollateralRegistry.sol";
import {IBoldToken} from "../Interfaces/IBoldToken.sol";
import {HintHelpers} from "../HintHelpers.sol";
import {MultiTroveGetter} from "../MultiTroveGetter.sol";
import {IAddressesRegistry} from "../Interfaces/IAddressesRegistry.sol";
import {IActivePool} from "../Interfaces/IActivePool.sol";
import {IBorrowerOperations} from "../Interfaces/IBorrowerOperations.sol";
import {ICollSurplusPool} from "../Interfaces/ICollSurplusPool.sol";
import {IDefaultPool} from "../Interfaces/IDefaultPool.sol";
import {ISortedTroves} from "../Interfaces/ISortedTroves.sol";
import {IStabilityPool} from "../Interfaces/IStabilityPool.sol";
import {ITroveManager} from "../Interfaces/ITroveManager.sol";
import {ITroveNFT} from "../Interfaces/ITroveNFT.sol";
import {IPriceFeed} from "../Interfaces/IPriceFeed.sol";
import {GasPool} from "../GasPool.sol";
import {IInterestRouter} from "../Interfaces/IInterestRouter.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {WETHZapper} from "../Zappers/WETHZapper.sol";
import {GasCompZapper} from "../Zappers/GasCompZapper.sol";
import {ILeverageZapper} from "../Zappers/Interfaces/ILeverageZapper.sol";


    struct  TroveManagerParams {
        uint256 CCR;
        uint256 MCR;
        uint256 SCR;
        uint256 LIQUIDATION_PENALTY_SP;
        uint256 LIQUIDATION_PENALTY_REDISTRIBUTION;
    }

    struct DeploymentResultMainnet {
        LiquityContracts[] contractsArray;
        ExternalAddresses externalAddresses;
        ICollateralRegistry collateralRegistry;
        IBoldToken boldToken;
        HintHelpers hintHelpers;
        MultiTroveGetter multiTroveGetter;
        Zappers[] zappersArray;
    }

    struct LiquityContracts {
        IAddressesRegistry addressesRegistry;
        IActivePool activePool;
        IBorrowerOperations borrowerOperations;
        ICollSurplusPool collSurplusPool;
        IDefaultPool defaultPool;
        ISortedTroves sortedTroves;
        IStabilityPool stabilityPool;
        ITroveManager troveManager;
        ITroveNFT troveNFT;
        IPriceFeed priceFeed;
        GasPool gasPool;
        IInterestRouter interestRouter;
        IERC20Metadata collToken;
    }

    struct ExternalAddresses {
        address ETHOracle;
        address WEETHETHOracle;
        address WEETHToken;
    }

    struct Zappers {
        WETHZapper wethZapper;
        GasCompZapper gasCompZapper;
        ILeverageZapper leverageZapperCurve;
        ILeverageZapper leverageZapperUniV3;
    }

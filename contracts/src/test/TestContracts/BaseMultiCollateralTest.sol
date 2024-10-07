// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IEbusdToken} from "../../Interfaces/IEbusdToken.sol";
import {ICollateralRegistry} from "../../Interfaces/ICollateralRegistry.sol";
import {IWETH} from "../../Interfaces/IWETH.sol";
import {HintHelpers} from "../../HintHelpers.sol";
import {TestDeployer} from "./Deployment.t.sol";

contract BaseMultiCollateralTest {
    struct Contracts {
        IWETH weth;
        ICollateralRegistry collateralRegistry;
        IEbusdToken ebusdToken;
        HintHelpers hintHelpers;
        TestDeployer.LiquityContractsDev[] branches;
    }

    IERC20 weth;
    ICollateralRegistry collateralRegistry;
    IEbusdToken ebusdToken;
    HintHelpers hintHelpers;
    TestDeployer.LiquityContractsDev[] branches;

    function setupContracts(Contracts memory contracts) internal {
        weth = contracts.weth;
        collateralRegistry = contracts.collateralRegistry;
        ebusdToken = contracts.ebusdToken;
        hintHelpers = contracts.hintHelpers;

        for (uint256 i = 0; i < contracts.branches.length; ++i) {
            branches.push(contracts.branches[i]);
        }
    }
}

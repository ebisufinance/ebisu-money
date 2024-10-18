// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./IBoldToken.sol";
import "./ITroveManager.sol";
import "./IGovernance.sol";

interface ICollateralRegistry {
    function baseRate() external view returns (uint256);
    function lastFeeOperationTime() external view returns (uint256);

    function redeemCollateral(uint256 _boldamount, uint256 _maxIterations, uint256 _maxFeePercentage) external;
    // getters
    function totalCollaterals() external view returns (uint256);
    function getToken(uint256 _index) external view returns (IERC20Metadata);
    function getTroveManager(uint256 _index) external view returns (ITroveManager);
    function boldToken() external view returns (IBoldToken);
    function governance() external view returns (IGovernance);
    function troveManagerAddresses(address _address) external view returns (bool);
    function stabilityPoolAddresses(address _address) external view returns (bool);
    function borrowerOperationsAddresses(address _address) external view returns (bool);
    function activePoolAddresses(address _address) external view returns (bool);

    function getRedemptionRate() external view returns (uint256);
    function getRedemptionRateWithDecay() external view returns (uint256);
    function getRedemptionRateForRedeemedAmount(uint256 _redeemAmount) external view returns (uint256);

    function getRedemptionFeeWithDecay(uint256 _ETHDrawn) external view returns (uint256);
    function getEffectiveRedemptionFeeInBold(uint256 _redeemAmount) external view returns (uint256);

    // add branches
    function addNewBranch(address _token, ITroveManager _troveManager, address _stabilityPoolAddress, address _borrowerOperationsAddress, address _activePoolAddress) external;
    function removeBranch(address _token) external;
    function setBranchAddresses(address _troveManagerAddress, address _stabilityPoolAddress, address _borrowerOperationsAddress, address _activePoolAddress) external;
}

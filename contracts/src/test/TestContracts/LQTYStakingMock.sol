// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

contract LQTYStakingMock {
    function setAddresses(
        address _lqtyTokenAddress,
        address _ebusdTokenAddress,
        address _troveManagerAddress,
        address _borrowerOperationsAddress,
        address _activePoolAddress
    ) external {}

    function stake(uint256 _LQTYamount) external {}

    function unstake(uint256 _LQTYamount) external {}

    function increaseF_ETH(uint256 _ETHFee) external {}

    function increaseF_ebusd(uint256 _LQTYFee) external {}

    function getPendingETHGain(address _user) external view returns (uint256) {}

    function getPendingEbusdGain(address _user) external view returns (uint256) {}
}

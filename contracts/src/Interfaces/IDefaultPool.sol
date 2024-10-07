// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IDefaultPool {
    function troveManagerAddress() external view returns (address);
    function activePoolAddress() external view returns (address);
    // --- Functions ---
    function getCollBalance() external view returns (uint256);
    function getEbusdDebt() external view returns (uint256);
    function sendCollToActivePool(uint256 _amount) external;
    function receiveColl(uint256 _amount) external;

    function increaseEbusdDebt(uint256 _amount) external;
    function decreaseEbusdDebt(uint256 _amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IEbusdRewardsReceiver {
    function triggerEbusdRewards(uint256 _ebusdYield) external;
}

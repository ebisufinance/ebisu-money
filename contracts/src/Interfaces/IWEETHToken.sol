// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

interface IWEETHToken {
    function getRate() external view returns (uint256);
}

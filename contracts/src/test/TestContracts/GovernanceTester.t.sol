// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "../../Interfaces/IGovernance.sol";

contract GovernanceTester is IGovernance {
    function registeredInitiatives(address _initiative) external pure override returns (uint16 atEpoch) {
        return 1; // Mock number for every initiative
    }
}
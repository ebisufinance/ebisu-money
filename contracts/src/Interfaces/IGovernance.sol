pragma solidity ^0.8.18;

interface IGovernance {
    /// @notice Returns when an initiative was registered
    /// @param _initiative Address of the initiative
    /// @return atEpoch Epoch at which the initiative was registered
    function registeredInitiatives(address _initiative) external view returns (uint16 atEpoch);

}
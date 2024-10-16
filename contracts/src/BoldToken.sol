// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.18;

import "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "./Dependencies/Ownable.sol";
import "./Interfaces/IBoldToken.sol";
import "./Interfaces/ICollateralRegistry.sol";
//import "forge-std/console2.sol";

/*
 * --- Functionality added specific to the BoldToken ---
 *
 * 1) Transfer protection: blacklist of addresses that are invalid recipients (i.e. core Liquity contracts) in external
 * transfer() and transferFrom() calls. The purpose is to protect users from losing tokens by mistakenly sending Bold directly to a Liquity
 * core contract, when they should rather call the right function.
 *
 * 2) sendToPool() and returnFromPool(): functions callable only Liquity core contracts, which move Bold tokens between Liquity <-> user.
 */

contract BoldToken is Ownable, IBoldToken, ERC20Permit {
    string internal constant _NAME = "ebUSD";
    string internal constant _SYMBOL = "ebUSD";

    // --- Addresses ---
    ICollateralRegistry internal collateralRegistry;
    // TODO: optimize to make them immutable
    address public collateralRegistryAddress;


    // --- Events ---
    event CollateralRegistryAddressChanged(address _newCollateralRegistryAddress);

    // --- Errors ---
    error CallerNotGovernanceInitiative();

    constructor(address _owner) Ownable(_owner) ERC20(_NAME, _SYMBOL) ERC20Permit(_NAME) {}

    function setCollateralRegistry(address _collateralRegistryAddress)
        external
        override
        onlyOwner
    {
        collateralRegistry = ICollateralRegistry(_collateralRegistryAddress);
        collateralRegistryAddress = _collateralRegistryAddress;
        emit CollateralRegistryAddressChanged(_collateralRegistryAddress);

        _renounceOwnership();
    }

    // --- Functions for intra-Liquity calls ---

    function mint(address _account, uint256 _amount) external override {
        _requireCallerIsBOorAP();
        _mint(_account, _amount);
    }

    function burn(address _account, uint256 _amount) external override {
        _requireCallerIsCRorBOorTMorSP();
        _burn(_account, _amount);
    }

    function sendToPool(address _sender, address _poolAddress, uint256 _amount) external override {
        _requireCallerIsStabilityPool();
        _transfer(_sender, _poolAddress, _amount);
    }

    function returnFromPool(address _poolAddress, address _receiver, uint256 _amount) external override {
        _requireCallerIsStabilityPool();
        _transfer(_poolAddress, _receiver, _amount);
    }

    // --- External functions ---

    function transfer(address recipient, uint256 amount) public override(ERC20, IERC20) returns (bool) {
        _requireValidRecipient(recipient);
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount)
        public
        override(ERC20, IERC20)
        returns (bool)
    {
        _requireValidRecipient(recipient);
        return super.transferFrom(sender, recipient, amount);
    }

    // --- 'require' functions ---

    function _requireValidRecipient(address _recipient) internal view {
        require(
            _recipient != address(0) && _recipient != address(this),
            "Bold: Cannot transfer tokens directly to the Bold token contract or the zero address"
        );
    }

    function _requireCallerIsBOorAP() internal view {
        require(
        collateralRegistry.borrowerOperationsAddresses(msg.sender) || collateralRegistry.activePoolAddresses(msg.sender),
            "BoldToken: Caller is not BO or AP"
        );
    }

    function _requireCallerIsCRorBOorTMorSP() internal view {
        require(
            msg.sender == collateralRegistryAddress || collateralRegistry.borrowerOperationsAddresses(msg.sender)
                || collateralRegistry.troveManagerAddresses(msg.sender) || collateralRegistry.stabilityPoolAddresses(msg.sender),
            "Bold: Caller is neither CR nor BorrowerOperations nor TroveManager nor StabilityPool"
        );

    }

    function _requireCallerIsStabilityPool() internal view {
        require(collateralRegistry.stabilityPoolAddresses(msg.sender), "Bold: Caller is not the StabilityPool");
    }

}

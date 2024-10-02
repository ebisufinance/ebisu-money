pragma solidity ^0.8.18;
// SPDX-License-Identifier: MIT
import "../AddressesRegistry.sol";
import {Script} from "forge-std/Script.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {StringFormatting} from "../test/Utils/StringFormatting.sol";
import {TroveManagerParams, DeploymentResultMainnet, DeploymentVarsMainnet, LiquityContracts, Zappers, LiquityContractAddresses} from "./Utils.sol";
import {MainnetAddresses} from "./MainnetAddresses.sol";
import {IWETH} from "../Interfaces/IWETH.sol";
import {IPriceFeed} from "../Interfaces/IPriceFeed.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {IAddressesRegistry} from "../Interfaces/IAddressesRegistry.sol";
import {ITroveManager} from "../Interfaces/ITroveManager.sol";
import {BoldToken} from "../BoldToken.sol";
import {TroveManager} from "../TroveManager.sol";
import {CollateralRegistry} from "../CollateralRegistry.sol";
import {HintHelpers} from "../HintHelpers.sol";
import {MultiTroveGetter} from "../MultiTroveGetter.sol";
import "../PriceFeeds/WETHPriceFeed.sol";
import "../PriceFeeds/WEETHPriceFeed.sol";
import "../MockInterestRouter.sol";

import "forge-std/console.sol";



uint256 constant _24_HOURS = 86400;
uint256 constant _48_HOURS = 172800;
uint256 constant _2_MONTHS = 5184000;

contract DeployEbisuForked is Script {
    using Strings for *;
    using StringFormatting for *;

    bytes32 constant SALT = keccak256("LiquityV2");
    // Initialize MainnetAddresses instance
    MainnetAddresses mainnetAddresses = new MainnetAddresses();
    address deployer;

    IWETH weth = IWETH(mainnetAddresses.WETH());
    IERC20Metadata weeth = IERC20Metadata(mainnetAddresses.WEETH());

    function run() external {

        uint256 privateKey = vm.envUint("DEPLOYER");
        deployer = vm.addr(privateKey);
        vm.startBroadcast(privateKey);

        console.log("Deploying Liquity2 contracts");
        console.log("Deployer address: ", deployer);
        console.log("weth address: ", address(weth));
        //create trove manager params
        TroveManagerParams[] memory troveManagerParamsArray = new TroveManagerParams[](2);

        troveManagerParamsArray[0] = TroveManagerParams(150e16, 110e16, 110e16, 5e16, 10e16); // WETH  
        troveManagerParamsArray[1] = TroveManagerParams(150e16, 120e16, 110e16, 5e16, 10e16); // weeth

        DeploymentResultMainnet memory deployed = _deployAndConnectContracts(troveManagerParamsArray, weth, deployer);
        vm.stopBroadcast();

        // vm.writeFile("deployment-manifest-ebisu.json", _getManifestJson(deployed));

    }

    function _deployAndConnectContracts(TroveManagerParams[] memory _troveManagerParamsArray, IWETH _weth, address _deployer) internal returns (DeploymentResultMainnet memory) {
        // Deploy contracts
        DeploymentResultMainnet memory result;
        DeploymentVarsMainnet memory vars;

        result.externalAddresses.ETHOracle = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
        result.externalAddresses.WEETHOracle = mainnetAddresses.WEETH_ETH_ORACLE();
        result.externalAddresses.WEETHToken = mainnetAddresses.WEETH();

        vars.oracleParams.ethUsdStalenessThreshold = _2_MONTHS;
        vars.oracleParams.weEthUsdStalenessThreshold = _2_MONTHS;

        vars.numCollaterals = 2;
        result.contractsArray = new LiquityContracts[](vars.numCollaterals);
        result.zappersArray = new Zappers[](vars.numCollaterals);
        vars.priceFeeds = new IPriceFeed[](vars.numCollaterals);
        vars.collaterals = new IERC20Metadata[](vars.numCollaterals);
        vars.addressesRegistries = new IAddressesRegistry[](vars.numCollaterals);
        vars.troveManagers = new ITroveManager[](vars.numCollaterals);
        
        // Price feeds
        // ETH
        vars.priceFeeds[0] = new WETHPriceFeed(
            address(this), result.externalAddresses.ETHOracle, vars.oracleParams.ethUsdStalenessThreshold
        );

        // RETH
        vars.priceFeeds[1] = new WEETHPriceFeed(
            address(this),
            result.externalAddresses.ETHOracle,
            result.externalAddresses.WEETHOracle,
            result.externalAddresses.WEETHToken,
            vars.oracleParams.ethUsdStalenessThreshold,
            vars.oracleParams.weEthEthStalenessThreshold
        );

        // Deploy Bold
        vars.bytecode = abi.encodePacked(type(BoldToken).creationCode, abi.encode(address(this))); 
        result.boldToken = new BoldToken{salt: SALT}(address(this));
        vars.boldTokenAddress = address(result.boldToken);
        console.log("BoldToken deployed at: ", address(result.boldToken));
        console.log("Expected BoldToken address: ", vars.boldTokenAddress);
        console.log("Deployer address: ", address(this));
        // console.log("Salt: ", string(SALT));
        // console.log("Bytecode hash: ", string(keccak256(vars.bytecode)));
        assert(address(result.boldToken) == vars.boldTokenAddress);

        address troveManagerAddress;
        // weth
        vars.collaterals[0] = weth;
        (vars.addressesRegistries[0], troveManagerAddress) =
            _deployAddressesRegistryMainnet(_troveManagerParamsArray[0]);
        vars.troveManagers[0] = ITroveManager(troveManagerAddress);
        // weeth
        vars.collaterals[1] = weeth;
        (vars.addressesRegistries[1], troveManagerAddress) =
            _deployAddressesRegistryMainnet(_troveManagerParamsArray[1]);

        result.collateralRegistry = new CollateralRegistry(result.boldToken, vars.collaterals, vars.troveManagers);

        result.hintHelpers = new HintHelpers(result.collateralRegistry);
        result.multiTroveGetter = new MultiTroveGetter(result.collateralRegistry);

        // Deploy each set of core contracts
        for (vars.i = 0; vars.i < vars.numCollaterals; vars.i++) {
            (result.contractsArray[vars.i], result.zappersArray[vars.i]) = _deployAndConnectCollateralContractsMainnet(
                vars.collaterals[vars.i],
                vars.priceFeeds[vars.i],
                result.boldToken,
                result.collateralRegistry,
                weth,
                vars.addressesRegistries[vars.i],
                address(vars.troveManagers[vars.i]),
                result.hintHelpers,
                result.multiTroveGetter
            );
        }




        return result;
    }

    function getAddress(address _deployer, bytes memory _bytecode, bytes32 _salt) public pure returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), _deployer, _salt, keccak256(_bytecode)));

        // NOTE: cast last 20 bytes of hash to address
        return address(uint160(uint256(hash)));
    }

    function _deployAddressesRegistryMainnet(TroveManagerParams memory _troveManagerParams)
        internal
        returns (IAddressesRegistry, address)
    {
        IAddressesRegistry addressesRegistry = new AddressesRegistry(
            address(this),
            _troveManagerParams.CCR,
            _troveManagerParams.MCR,
            _troveManagerParams.SCR,
            _troveManagerParams.LIQUIDATION_PENALTY_SP,
            _troveManagerParams.LIQUIDATION_PENALTY_REDISTRIBUTION
        );
        address troveManagerAddress =
            getAddress(address(this), getBytecode(type(TroveManager).creationCode, address(addressesRegistry)), SALT);

        return (addressesRegistry, troveManagerAddress);
    }

    function getBytecode(bytes memory _creationCode, address _addressesRegistry) public pure returns (bytes memory) {
        return abi.encodePacked(_creationCode, abi.encode(_addressesRegistry));
    }

    function _deployAndConnectCollateralContractsMainnet(
        IERC20Metadata _collToken,
        IPriceFeed _priceFeed,
        IBoldToken _boldToken,
        ICollateralRegistry _collateralRegistry,
        IWETH _weth,
        IAddressesRegistry _addressesRegistry,
        address _troveManagerAddress,
        IHintHelpers _hintHelpers,
        IMultiTroveGetter _multiTroveGetter
    ) internal returns (LiquityContracts memory contracts, Zappers memory zappers) {
        LiquityContractAddresses memory addresses;
        contracts.collToken = _collToken;
        contracts.priceFeed = _priceFeed;
        contracts.interestRouter = new MockInterestRouter();

        contracts.addressesRegistry = _addressesRegistry;



    }

}
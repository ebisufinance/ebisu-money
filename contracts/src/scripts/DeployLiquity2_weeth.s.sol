// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {StringFormatting} from "../test/Utils/StringFormatting.sol";
import {Accounts} from "../test/TestContracts/Accounts.sol";
import {ERC20Faucet} from "../test/TestContracts/ERC20Faucet.sol";
import {ETH_GAS_COMPENSATION} from "../Dependencies/Constants.sol";
import {IBorrowerOperations} from "../Interfaces/IBorrowerOperations.sol";
import "../AddressesRegistry.sol";
import "../ActivePool.sol";
import "../BoldToken.sol";
import "../BorrowerOperations.sol";
import "../CollSurplusPool.sol";
import "../DefaultPool.sol";
import "../GasPool.sol";
import "../HintHelpers.sol";
import "../MultiTroveGetter.sol";
import "../SortedTroves.sol";
import "../StabilityPool.sol";
import "../test/TestContracts/BorrowerOperationsTester.t.sol";
import "../test/TestContracts/TroveManagerTester.t.sol";
import "../TroveNFT.sol";
import "../CollateralRegistry.sol";
import "../MockInterestRouter.sol";
import "../test/TestContracts/PriceFeedTestnet.sol";
import "../test/TestContracts/MetadataDeployment.sol";
import "../Zappers/WETHZapper.sol";
import "../Zappers/GasCompZapper.sol";
import "../Zappers/Interfaces/ILeverageZapper.sol";
import "../Zappers/LeverageWETHZapper.sol";
import "../Zappers/Modules/FlashLoans/BalancerFlashLoan.sol";
import "../Zappers/Modules/Exchanges/UniV3Exchange.sol";
import "../Zappers/LeverageLSTZapper.sol";
import "../Zappers/Modules/Exchanges/UniV3Exchange.sol";
import "../Zappers/Modules/Exchanges/UniswapV3/INonfungiblePositionManager.sol";
import "../Zappers/Modules/Exchanges/Curve/ICurveFactory.sol";
import "../Zappers/Modules/Exchanges/Curve/ICurvePool.sol";
import "../Zappers/Modules/Exchanges/CurveExchange.sol";
import {WETHTester} from "../test/TestContracts/WETHTester.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {PriceFeedWeethTestnet} from "../test/TestContracts/PriceFeedWeethTestnet.sol";
import {WEETHPriceFeed} from "../PriceFeeds/WEETHPriceFeed.sol";
import "forge-std/console.sol";

uint256 constant _24_HOURS = 86400;
uint256 constant _48_HOURS = 172800;


contract DeployLiquity2Script is Script, StdCheats, MetadataDeployment {
    using Strings for *;
    using StringFormatting for *;

    ICurveFactory constant curveFactory = ICurveFactory(0x98EE851a00abeE0d95D08cF4CA2BdCE32aeaAF7F);
    ISwapRouter constant uniV3Router = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    IQuoterV2 constant uniV3Quoter = IQuoterV2(0x61fFE014bA17989E743c5F6cB21bF9697530B21e);
    INonfungiblePositionManager constant uniV3PositionManager =
    INonfungiblePositionManager(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);

    uint24 constant UNIV3_FEE = 3000; // 0.3%
    bytes32 SALT;
    address deployer;
    address ETHOracle = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    address WEETH_ADDRESS = 0xCd5fE23C85820F7B72D0926FC9b05b43E359b7ee;
    address WEETH_ORACLE = 0x8751F736E94F6CD167e8C5B97E245680FbD9CC36;

    uint256 ethUsdStalenessThreshold = _24_HOURS;
    uint256 weethEthUsdStalenessThreshold = _48_HOURS;

    struct LiquityContracts {
        IAddressesRegistry addressesRegistry;
        IActivePool activePool;
        IBorrowerOperations borrowerOperations;
        ICollSurplusPool collSurplusPool;
        IDefaultPool defaultPool;
        ISortedTroves sortedTroves;
        IStabilityPool stabilityPool;
        ITroveManager troveManager;
        ITroveNFT troveNFT;
        IPriceFeed priceFeed;
        GasPool gasPool;
        IInterestRouter interestRouter;
        IERC20Metadata collToken;
    }

    struct LiquityContractsTestnet {
        IAddressesRegistry addressesRegistry;
        IActivePool activePool;
        IBorrowerOperations borrowerOperations;
        ICollSurplusPool collSurplusPool;
        IDefaultPool defaultPool;
        ISortedTroves sortedTroves;
        IStabilityPool stabilityPool;
        ITroveManager troveManager;
        ITroveNFT troveNFT;
        MetadataNFT metadataNFT;
        IPriceFeedTestnet priceFeed; // Tester
        GasPool gasPool;
        IInterestRouter interestRouter;
        IERC20Metadata collToken;
        WETHZapper wethZapper;
        GasCompZapper gasCompZapper;
    }

    struct LiquityContractAddresses {
        address activePool;
        address borrowerOperations;
        address collSurplusPool;
        address defaultPool;
        address sortedTroves;
        address stabilityPool;
        address troveManager;
        address troveNFT;
        address metadataNFT;
        address priceFeed;
        address gasPool;
        address interestRouter;
    }

    struct UniV3Vars {
        IExchange uniV3Exchange;
        uint256 price;
        address[2] tokens;
    }

    struct Zappers {
        WETHZapper wethZapper;
        GasCompZapper gasCompZapper;
        ILeverageZapper leverageZapperCurve;
        ILeverageZapper leverageZapperUniV3;
    }

    struct TroveManagerParams {
        uint256 CCR;
        uint256 MCR;
        uint256 SCR;
        uint256 LIQUIDATION_PENALTY_SP;
        uint256 LIQUIDATION_PENALTY_REDISTRIBUTION;
    }

    struct DeploymentVarsTestnet {
        uint256 numCollaterals;
        IERC20Metadata[] collaterals;
        IAddressesRegistry[] addressesRegistries;
        ITroveManager[] troveManagers;
        LiquityContractsTestnet contracts;
        bytes bytecode;
        address boldTokenAddress;
        uint256 i;
    }

    struct DemoTroveParams {
        uint256 collIndex;
        uint256 owner;
        uint256 ownerIndex;
        uint256 coll;
        uint256 debt;
        uint256 annualInterestRate;
    }

    struct DeploymentResult {
        LiquityContractsTestnet[] contractsArray;
        ICollateralRegistry collateralRegistry;
        IBoldToken boldToken;
        HintHelpers hintHelpers;
        MultiTroveGetter multiTroveGetter;
    }

    function _getBranchContractsJson(LiquityContractsTestnet memory c) internal pure returns (string memory) {
        return string.concat(
            "{",
            string.concat(
            // Avoid stack too deep by chunking concats
                string.concat(
                    string.concat('"addressesRegistry":"', address(c.addressesRegistry).toHexString(), '",'),
                    string.concat('"activePool":"', address(c.activePool).toHexString(), '",'),
                    string.concat('"borrowerOperations":"', address(c.borrowerOperations).toHexString(), '",'),
                    string.concat('"collSurplusPool":"', address(c.collSurplusPool).toHexString(), '",'),
                    string.concat('"defaultPool":"', address(c.defaultPool).toHexString(), '",'),
                    string.concat('"sortedTroves":"', address(c.sortedTroves).toHexString(), '",'),
                    string.concat('"stabilityPool":"', address(c.stabilityPool).toHexString(), '",'),
                    string.concat('"troveManager":"', address(c.troveManager).toHexString(), '",')
                ),
                string.concat(
                    string.concat('"troveNFT":"', address(c.troveNFT).toHexString(), '",'),
                    string.concat('"metadataNFT":"', address(c.metadataNFT).toHexString(), '",'),
                    string.concat('"priceFeed":"', address(c.priceFeed).toHexString(), '",'),
                    string.concat('"gasPool":"', address(c.gasPool).toHexString(), '",'),
                    string.concat('"interestRouter":"', address(c.interestRouter).toHexString(), '",'),
                    string.concat('"wethZapper":"', address(c.wethZapper).toHexString(), '",'),
                    string.concat('"gasCompZapper":"', address(c.gasCompZapper).toHexString(), '",'),
                    string.concat('"collToken":"', address(c.collToken).toHexString(), '"') // no comma
                )
            ),
            "}"
        );
    }

    function _getManifestJson(DeploymentResult memory deployed) internal pure returns (string memory) {
        string[] memory branches = new string[](deployed.contractsArray.length);

        // Poor man's .map()
        for (uint256 i = 0; i < branches.length; ++i) {
            branches[i] = _getBranchContractsJson(deployed.contractsArray[i]);
        }

        return string.concat(
            "{",
            string.concat(
                string.concat('"collateralRegistry":"', address(deployed.collateralRegistry).toHexString(), '",'),
                string.concat('"boldToken":"', address(deployed.boldToken).toHexString(), '",'),
                string.concat('"hintHelpers":"', address(deployed.hintHelpers).toHexString(), '",'),
                string.concat('"multiTroveGetter":"', address(deployed.multiTroveGetter).toHexString(), '",'),
                string.concat('"branches":[', branches.join(","), "]") // no comma
            ),
            "}"
        );
    }

    function run() external {
        SALT = keccak256(abi.encodePacked(block.timestamp));

        if (vm.envBytes("DEPLOYER").length == 20) {
            // address
            deployer = vm.envAddress("DEPLOYER");
            vm.startBroadcast(deployer);
        } else {
            // private key
            uint256 privateKey = vm.envUint("DEPLOYER");
            deployer = vm.addr(privateKey);
            vm.startBroadcast(privateKey);
        }

        TroveManagerParams[] memory troveManagerParamsArray = new TroveManagerParams[](3);

        troveManagerParamsArray[0] = TroveManagerParams(150e16, 110e16, 110e16, 5e16, 10e16); // WETH
        troveManagerParamsArray[1] = TroveManagerParams(150e16, 120e16, 110e16, 5e16, 10e16); // stETH
        troveManagerParamsArray[2] = TroveManagerParams(150e16, 120e16, 110e16, 5e16, 10e16); // weeth

        // used for gas compensation and as collateral of the first branch
        IWETH WETH = new WETHTester({_tapAmount: 100 ether, _tapPeriod: 1 days});
        DeploymentResult memory deployed = _deployAndConnectContracts(troveManagerParamsArray, WETH);
        vm.stopBroadcast();

        vm.writeFile("deployment-manifest.json", _getManifestJson(deployed));

        if (vm.envOr("OPEN_DEMO_TROVES", false)) {
            // Anvil default accounts
            // TODO: get accounts from env
            uint256[] memory demoAccounts = new uint256[](8);
            demoAccounts[0] = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
            demoAccounts[1] = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
            demoAccounts[2] = 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a;
            demoAccounts[3] = 0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6;
            demoAccounts[4] = 0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a;
            demoAccounts[5] = 0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba;
            demoAccounts[6] = 0x92db14e403b83dfe3df233f83dfa3a0d7096f21ca9b0d6d6b8d88b2b4ec1564e;
            demoAccounts[7] = 0x4bbbf85ce3377467afe5d46f804f221813b2bb87f24d81f60f1fcdbf7cbf4356;

            DemoTroveParams[] memory demoTroves = new DemoTroveParams[](16);

            demoTroves[0] = DemoTroveParams(0, demoAccounts[0], 0, 25e18, 2800e18, 5.0e16);
            demoTroves[1] = DemoTroveParams(0, demoAccounts[1], 0, 37e18, 2400e18, 4.7e16);
            demoTroves[2] = DemoTroveParams(0, demoAccounts[2], 0, 30e18, 4000e18, 3.3e16);
            demoTroves[3] = DemoTroveParams(0, demoAccounts[3], 0, 65e18, 6000e18, 4.3e16);

            demoTroves[4] = DemoTroveParams(0, demoAccounts[4], 0, 19e18, 2280e18, 5.0e16);
            demoTroves[5] = DemoTroveParams(0, demoAccounts[5], 0, 48.37e18, 4400e18, 4.7e16);
            demoTroves[6] = DemoTroveParams(0, demoAccounts[6], 0, 33.92e18, 5500e18, 3.8e16);
            demoTroves[7] = DemoTroveParams(0, demoAccounts[7], 0, 47.2e18, 6000e18, 4.3e16);

            demoTroves[8] = DemoTroveParams(1, demoAccounts[0], 0, 21e18, 2000e18, 3.3e16);
            demoTroves[9] = DemoTroveParams(1, demoAccounts[1], 1, 16e18, 2000e18, 4.1e16);
            demoTroves[10] = DemoTroveParams(1, demoAccounts[2], 1, 18e18, 2300e18, 3.8e16);
            demoTroves[11] = DemoTroveParams(1, demoAccounts[3], 1, 22e18, 2200e18, 4.3e16);

            demoTroves[12] = DemoTroveParams(1, demoAccounts[4], 1, 85e18, 12000e18, 7.0e16);
            demoTroves[13] = DemoTroveParams(1, demoAccounts[5], 1, 87e18, 4000e18, 4.4e16);
            demoTroves[14] = DemoTroveParams(1, demoAccounts[6], 1, 71e18, 11000e18, 3.3e16);
            demoTroves[15] = DemoTroveParams(1, demoAccounts[7], 1, 84e18, 12800e18, 4.4e16);

            for (uint256 i = 0; i < deployed.contractsArray.length; i++) {
                tapFaucet(demoAccounts, deployed.contractsArray[i]);
            }

            openDemoTroves(demoTroves, deployed.contractsArray);
        }
    }

    function tapFaucet(uint256[] memory accounts, LiquityContractsTestnet memory contracts) internal {
        for (uint256 i = 0; i < accounts.length; i++) {
            ERC20Faucet token = ERC20Faucet(address(contracts.collToken));

            vm.startBroadcast(accounts[i]);
            token.tap();
            vm.stopBroadcast();

            console.log(
                "%s.tap() => %s (balance: %s)",
                token.symbol(),
                vm.addr(accounts[i]),
                string.concat(formatAmount(token.balanceOf(vm.addr(accounts[i])), 18, 2), " ", token.symbol())
            );
        }
    }

    function openDemoTroves(DemoTroveParams[] memory demoTroves, LiquityContractsTestnet[] memory contractsArray)
    internal
    {
        for (uint256 i = 0; i < demoTroves.length; i++) {
            DemoTroveParams memory trove = demoTroves[i];
            LiquityContractsTestnet memory contracts = contractsArray[trove.collIndex];

            vm.startBroadcast(trove.owner);

            IERC20 collToken = IERC20(contracts.collToken);
            IERC20 wethToken = IERC20(contracts.addressesRegistry.WETH());

            // Approve collToken to BorrowerOperations
            if (collToken == wethToken) {
                wethToken.approve(address(contracts.borrowerOperations), trove.coll + ETH_GAS_COMPENSATION);
            } else {
                wethToken.approve(address(contracts.borrowerOperations), ETH_GAS_COMPENSATION);
                collToken.approve(address(contracts.borrowerOperations), trove.coll);
            }

            IBorrowerOperations(contracts.borrowerOperations).openTrove(
                vm.addr(trove.owner), // _owner
                trove.ownerIndex, //     _ownerIndex
                trove.coll, //           _collAmount
                trove.debt, //           _boldAmount
                0, //                    _upperHint
                0, //                    _lowerHint
                0.05e18, //              _annualInterestRate
                type(uint256).max, //    _maxUpfrontFee
                address(0), //           _addManager
                address(0), //           _removeManager
                address(0) //           _receiver
            );

            vm.stopBroadcast();
        }
    }

    // See: https://solidity-by-example.org/app/create2/
    function getBytecode(bytes memory _creationCode, address _addressesRegistry) public pure returns (bytes memory) {
        return abi.encodePacked(_creationCode, abi.encode(_addressesRegistry));
    }

    function _deployAndConnectContracts(TroveManagerParams[] memory troveManagerParamsArray, IWETH _WETH)
    internal
    returns (DeploymentResult memory r)
    {
        DeploymentVarsTestnet memory vars;
        vars.numCollaterals = troveManagerParamsArray.length;
        // Deploy Bold
        vars.bytecode = abi.encodePacked(type(BoldToken).creationCode, abi.encode(deployer));
        vars.boldTokenAddress = vm.computeCreate2Address(SALT, keccak256(vars.bytecode));
        r.boldToken = new BoldToken{salt: SALT}(deployer);
        assert(address(r.boldToken) == vars.boldTokenAddress);

        r.contractsArray = new LiquityContractsTestnet[](vars.numCollaterals);
        vars.collaterals = new IERC20Metadata[](vars.numCollaterals);
        vars.addressesRegistries = new IAddressesRegistry[](vars.numCollaterals);
        vars.troveManagers = new ITroveManager[](vars.numCollaterals);

        // Use WETH as collateral for the first branch
        vars.collaterals[0] = _WETH;
        vars.collaterals[1] = new ERC20Faucet(
            string.concat("Staked ETH", string(abi.encode(vars.i))), // _name
            string.concat("stETH", string(abi.encode(vars.i))), // _symbol
            100 ether, //     _tapAmount
            1 days //         _tapPeriod
        );

        vars.collaterals[2] = IERC20Metadata(WEETH_ADDRESS);

        // Deploy AddressesRegistries and get TroveManager addresses
        for (vars.i = 0; vars.i < vars.numCollaterals; vars.i++) {
            (IAddressesRegistry addressesRegistry, address troveManagerAddress) =
                            _deployAddressesRegistry(troveManagerParamsArray[vars.i]);
            vars.addressesRegistries[vars.i] = addressesRegistry;
            vars.troveManagers[vars.i] = ITroveManager(troveManagerAddress);
        }

        r.collateralRegistry = new CollateralRegistry(r.boldToken, vars.collaterals, vars.troveManagers);
        r.hintHelpers = new HintHelpers(r.collateralRegistry);
        r.multiTroveGetter = new MultiTroveGetter(r.collateralRegistry);

        // Deploy per-branch contracts for each branch
        for (vars.i = 0; vars.i < vars.numCollaterals -1; vars.i++) {
            vars.contracts = _deployAndConnectCollateralContractsTestnet(
                vars.collaterals[vars.i],
                r.boldToken,
                r.collateralRegistry,
                _WETH,
                vars.addressesRegistries[vars.i],
                address(vars.troveManagers[vars.i]),
                r.hintHelpers,
                r.multiTroveGetter
            );
            r.contractsArray[vars.i] = vars.contracts;
        }

        WEETHPriceFeed weethPriceFeed = new WEETHPriceFeed(
            address(this),
            ETHOracle,
            WEETH_ORACLE,
            WEETH_ADDRESS,
            ethUsdStalenessThreshold,
            weethEthUsdStalenessThreshold
        );

        LiquityContractsTestnet memory contracts;

        _deployAndConnectCollateralContractsMainnet(
            IERC20Metadata(WEETH_ADDRESS),
            weethPriceFeed,
            r.boldToken,
            r.collateralRegistry,
            _WETH,
            vars.addressesRegistries[2],
            address(vars.troveManagers[2]),
            r.hintHelpers,
            r.multiTroveGetter
        );

        r.boldToken.setCollateralRegistry(address(r.collateralRegistry));
    }

    function _deployAddressesRegistry(TroveManagerParams memory _troveManagerParams)
    internal
    returns (IAddressesRegistry, address)
    {
        IAddressesRegistry addressesRegistry = new AddressesRegistry(
            deployer,
            _troveManagerParams.CCR,
            _troveManagerParams.MCR,
            _troveManagerParams.SCR,
            _troveManagerParams.LIQUIDATION_PENALTY_SP,
            _troveManagerParams.LIQUIDATION_PENALTY_REDISTRIBUTION
        );
        address troveManagerAddress = vm.computeCreate2Address(
            SALT, keccak256(getBytecode(type(TroveManager).creationCode, address(addressesRegistry)))
        );

        return (addressesRegistry, troveManagerAddress);
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

        // Deploy Metadata
        MetadataNFT metadataNFT = deployMetadata(SALT);
        addresses.metadataNFT = getAddress(
            address(this), getBytecode(type(MetadataNFT).creationCode, address(initializedFixedAssetReader)), SALT
        );
        assert(address(metadataNFT) == addresses.metadataNFT);

        // Pre-calc addresses
        addresses.borrowerOperations = getAddress(
            address(this),
            getBytecode(type(BorrowerOperationsTester).creationCode, address(contracts.addressesRegistry)),
            SALT
        );
        addresses.troveManager = _troveManagerAddress;
        addresses.troveNFT = getAddress(
            address(this), getBytecode(type(TroveNFT).creationCode, address(contracts.addressesRegistry)), SALT
        );
        addresses.stabilityPool = getAddress(
            address(this), getBytecode(type(StabilityPool).creationCode, address(contracts.addressesRegistry)), SALT
        );
        addresses.activePool = getAddress(
            address(this), getBytecode(type(ActivePool).creationCode, address(contracts.addressesRegistry)), SALT
        );
        addresses.defaultPool = getAddress(
            address(this), getBytecode(type(DefaultPool).creationCode, address(contracts.addressesRegistry)), SALT
        );
        addresses.gasPool = getAddress(
            address(this), getBytecode(type(GasPool).creationCode, address(contracts.addressesRegistry)), SALT
        );
        addresses.collSurplusPool = getAddress(
            address(this), getBytecode(type(CollSurplusPool).creationCode, address(contracts.addressesRegistry)), SALT
        );
        addresses.sortedTroves = getAddress(
            address(this), getBytecode(type(SortedTroves).creationCode, address(contracts.addressesRegistry)), SALT
        );

        // Deploy contracts
        IAddressesRegistry.AddressVars memory addressVars = IAddressesRegistry.AddressVars({
            collToken: _collToken,
            borrowerOperations: IBorrowerOperations(addresses.borrowerOperations),
            troveManager: ITroveManager(addresses.troveManager),
            troveNFT: ITroveNFT(addresses.troveNFT),
            metadataNFT: IMetadataNFT(addresses.metadataNFT),
            stabilityPool: IStabilityPool(addresses.stabilityPool),
            priceFeed: contracts.priceFeed,
            activePool: IActivePool(addresses.activePool),
            defaultPool: IDefaultPool(addresses.defaultPool),
            gasPoolAddress: addresses.gasPool,
            collSurplusPool: ICollSurplusPool(addresses.collSurplusPool),
            sortedTroves: ISortedTroves(addresses.sortedTroves),
            interestRouter: contracts.interestRouter,
            hintHelpers: _hintHelpers,
            multiTroveGetter: _multiTroveGetter,
            collateralRegistry: _collateralRegistry,
            boldToken: _boldToken,
            WETH: _weth
        });
        contracts.addressesRegistry.setAddresses(addressVars);

        contracts.borrowerOperations = new BorrowerOperationsTester{salt: SALT}(contracts.addressesRegistry);
        contracts.troveManager = new TroveManager{salt: SALT}(contracts.addressesRegistry);
        contracts.troveNFT = new TroveNFT{salt: SALT}(contracts.addressesRegistry);
        contracts.stabilityPool = new StabilityPool{salt: SALT}(contracts.addressesRegistry);
        contracts.activePool = new ActivePool{salt: SALT}(contracts.addressesRegistry);
        contracts.defaultPool = new DefaultPool{salt: SALT}(contracts.addressesRegistry);
        contracts.gasPool = new GasPool{salt: SALT}(contracts.addressesRegistry);
        contracts.collSurplusPool = new CollSurplusPool{salt: SALT}(contracts.addressesRegistry);
        contracts.sortedTroves = new SortedTroves{salt: SALT}(contracts.addressesRegistry);

        assert(address(contracts.borrowerOperations) == addresses.borrowerOperations);
        assert(address(contracts.troveManager) == addresses.troveManager);
        assert(address(contracts.troveNFT) == addresses.troveNFT);
        assert(address(contracts.stabilityPool) == addresses.stabilityPool);
        assert(address(contracts.activePool) == addresses.activePool);
        assert(address(contracts.defaultPool) == addresses.defaultPool);
        assert(address(contracts.gasPool) == addresses.gasPool);
        assert(address(contracts.collSurplusPool) == addresses.collSurplusPool);
        assert(address(contracts.sortedTroves) == addresses.sortedTroves);

        // Connect contracts
        _boldToken.setBranchAddresses(
            address(contracts.troveManager),
            address(contracts.stabilityPool),
            address(contracts.borrowerOperations),
            address(contracts.activePool)
        );

        console.log("setting borrower address to priceFeed: ", addresses.borrowerOperations);
        // TODO: remove this and set address in constructor as per the CREATE2 approach above
        _priceFeed.setAddresses(addresses.borrowerOperations);

        // deploy zappers
        (zappers.gasCompZapper, zappers.wethZapper, zappers.leverageZapperCurve, zappers.leverageZapperUniV3) =
        _deployZappersMainnet(contracts.addressesRegistry, contracts.collToken, _boldToken, _weth, contracts.priceFeed, true);

    }

    function _deployAndConnectCollateralContractsTestnet(
        IERC20Metadata _collToken,
        IBoldToken _boldToken,
        ICollateralRegistry _collateralRegistry,
        IWETH _weth,
        IAddressesRegistry _addressesRegistry,
        address _troveManagerAddress,
        IHintHelpers _hintHelpers,
        IMultiTroveGetter _multiTroveGetter
    ) internal returns (LiquityContractsTestnet memory contracts) {
        LiquityContractAddresses memory addresses;
        contracts.collToken = _collToken;

        // Deploy all contracts, using testers for TM and PriceFeed
        contracts.addressesRegistry = _addressesRegistry;

        // Deploy Metadata
        contracts.metadataNFT = deployMetadata(SALT);
        addresses.metadataNFT = vm.computeCreate2Address(
            SALT, keccak256(getBytecode(type(MetadataNFT).creationCode, address(initializedFixedAssetReader)))
        );
        assert(address(contracts.metadataNFT) == addresses.metadataNFT);

        if (address(_collToken) == WEETH_ADDRESS) {
            contracts.priceFeed = new PriceFeedWeethTestnet(WEETH_ORACLE);

//            contracts.priceFeed = new WEETHPriceFeed(
//                address(this),
//                ETHOracle,
//                WEETH_ORACLE,
//                WEETH_ADDRESS,
//                ethUsdStalenessThreshold,
//                weethEthUsdStalenessThreshold
//            );


        } else {
            contracts.priceFeed = new PriceFeedTestnet();
        }
        // contracts.priceFeed = new PriceFeedTestnet();
        contracts.interestRouter = new MockInterestRouter();
        addresses.borrowerOperations = vm.computeCreate2Address(
            SALT, keccak256(getBytecode(type(BorrowerOperations).creationCode, address(contracts.addressesRegistry)))
        );
        addresses.troveManager = _troveManagerAddress;
        addresses.troveNFT = vm.computeCreate2Address(
            SALT, keccak256(getBytecode(type(TroveNFT).creationCode, address(contracts.addressesRegistry)))
        );
        addresses.stabilityPool = vm.computeCreate2Address(
            SALT, keccak256(getBytecode(type(StabilityPool).creationCode, address(contracts.addressesRegistry)))
        );
        addresses.activePool = vm.computeCreate2Address(
            SALT, keccak256(getBytecode(type(ActivePool).creationCode, address(contracts.addressesRegistry)))
        );
        addresses.defaultPool = vm.computeCreate2Address(
            SALT, keccak256(getBytecode(type(DefaultPool).creationCode, address(contracts.addressesRegistry)))
        );
        addresses.gasPool = vm.computeCreate2Address(
            SALT, keccak256(getBytecode(type(GasPool).creationCode, address(contracts.addressesRegistry)))
        );
        addresses.collSurplusPool = vm.computeCreate2Address(
            SALT, keccak256(getBytecode(type(CollSurplusPool).creationCode, address(contracts.addressesRegistry)))
        );
        addresses.sortedTroves = vm.computeCreate2Address(
            SALT, keccak256(getBytecode(type(SortedTroves).creationCode, address(contracts.addressesRegistry)))
        );

        IAddressesRegistry.AddressVars memory addressVars = IAddressesRegistry.AddressVars({
            collToken: _collToken,
            borrowerOperations: IBorrowerOperations(addresses.borrowerOperations),
            troveManager: ITroveManager(addresses.troveManager),
            troveNFT: ITroveNFT(addresses.troveNFT),
            metadataNFT: IMetadataNFT(addresses.metadataNFT),
            stabilityPool: IStabilityPool(addresses.stabilityPool),
            priceFeed: contracts.priceFeed,
            activePool: IActivePool(addresses.activePool),
            defaultPool: IDefaultPool(addresses.defaultPool),
            gasPoolAddress: addresses.gasPool,
            collSurplusPool: ICollSurplusPool(addresses.collSurplusPool),
            sortedTroves: ISortedTroves(addresses.sortedTroves),
            interestRouter: contracts.interestRouter,
            hintHelpers: _hintHelpers,
            multiTroveGetter: _multiTroveGetter,
            collateralRegistry: _collateralRegistry,
            boldToken: _boldToken,
            WETH: _weth
        });
        contracts.addressesRegistry.setAddresses(addressVars);

        contracts.borrowerOperations = new BorrowerOperations{salt: SALT}(contracts.addressesRegistry);
        contracts.troveManager = new TroveManager{salt: SALT}(contracts.addressesRegistry);
        contracts.troveNFT = new TroveNFT{salt: SALT}(contracts.addressesRegistry);
        contracts.stabilityPool = new StabilityPool{salt: SALT}(contracts.addressesRegistry);
        contracts.activePool = new ActivePool{salt: SALT}(contracts.addressesRegistry);
        contracts.defaultPool = new DefaultPool{salt: SALT}(contracts.addressesRegistry);
        contracts.gasPool = new GasPool{salt: SALT}(contracts.addressesRegistry);
        contracts.collSurplusPool = new CollSurplusPool{salt: SALT}(contracts.addressesRegistry);
        contracts.sortedTroves = new SortedTroves{salt: SALT}(contracts.addressesRegistry);

        assert(address(contracts.borrowerOperations) == addresses.borrowerOperations);
        assert(address(contracts.troveManager) == addresses.troveManager);
        assert(address(contracts.troveNFT) == addresses.troveNFT);
        assert(address(contracts.stabilityPool) == addresses.stabilityPool);
        assert(address(contracts.activePool) == addresses.activePool);
        assert(address(contracts.defaultPool) == addresses.defaultPool);
        assert(address(contracts.gasPool) == addresses.gasPool);
        assert(address(contracts.collSurplusPool) == addresses.collSurplusPool);
        assert(address(contracts.sortedTroves) == addresses.sortedTroves);

        // Connect contracts
        _boldToken.setBranchAddresses(
            address(contracts.troveManager),
            address(contracts.stabilityPool),
            address(contracts.borrowerOperations),
            address(contracts.activePool)
        );

        // deploy zappers
        (contracts.gasCompZapper, contracts.wethZapper) =
        _deployZappers(contracts.addressesRegistry, contracts.collToken, _weth);
    }
    function _deployZappersMainnet(
        IAddressesRegistry _addressesRegistry,
        IERC20 _collToken,
        IBoldToken _boldToken,
        IWETH _weth,
        IPriceFeed _priceFeed,
        bool mainnet
    )
    internal
    returns (
        GasCompZapper gasCompZapper,
        WETHZapper wethZapper,
        ILeverageZapper leverageZapperCurve,
        ILeverageZapper leverageZapperUniV3
    )
    {
        bool lst = _collToken != _weth;
        if (lst) {
            gasCompZapper = new GasCompZapper(_addressesRegistry);
        } else {
            wethZapper = new WETHZapper(_addressesRegistry);
        }

        if (mainnet) {
            (leverageZapperCurve, leverageZapperUniV3) =
            _deployLeverageZappers(_addressesRegistry, _collToken, _boldToken, _priceFeed, lst);
        }

        return (gasCompZapper, wethZapper, leverageZapperCurve, leverageZapperUniV3);
    }

    function _deployLeverageZappers(
        IAddressesRegistry _addressesRegistry,
        IERC20 _collToken,
        IBoldToken _boldToken,
        IPriceFeed _priceFeed,
        bool _lst
    ) internal returns (ILeverageZapper, ILeverageZapper) {
        IFlashLoanProvider flashLoanProvider = new BalancerFlashLoan();

        ILeverageZapper leverageZapperCurve =
                        _deployCurveLeverageZapper(_addressesRegistry, _collToken, _boldToken, _priceFeed, flashLoanProvider, _lst);
        ILeverageZapper leverageZapperUniV3 =
                        _deployUniV3LeverageZapper(_addressesRegistry, _collToken, _boldToken, _priceFeed, flashLoanProvider, _lst);

        return (leverageZapperCurve, leverageZapperUniV3);
    }

    function _deployUniV3LeverageZapper(
        IAddressesRegistry _addressesRegistry,
        IERC20 _collToken,
        IBoldToken _boldToken,
        IPriceFeed _priceFeed,
        IFlashLoanProvider _flashLoanProvider,
        bool _lst
    ) internal returns (ILeverageZapper) {
        UniV3Vars memory vars;
        vars.uniV3Exchange = new UniV3Exchange(_collToken, _boldToken, UNIV3_FEE, uniV3Router, uniV3Quoter);
        ILeverageZapper leverageZapperUniV3;
        if (_lst) {
            leverageZapperUniV3 = new LeverageLSTZapper(_addressesRegistry, _flashLoanProvider, vars.uniV3Exchange);
        } else {
            leverageZapperUniV3 = new LeverageWETHZapper(_addressesRegistry, _flashLoanProvider, vars.uniV3Exchange);
        }

        // Create Uni V3 pool
        (vars.price,) = _priceFeed.fetchPrice();
        if (address(_boldToken) < address(_collToken)) {
            //console2.log("b < c");
            vars.tokens[0] = address(_boldToken);
            vars.tokens[1] = address(_collToken);
        } else {
            //console2.log("c < b");
            vars.tokens[0] = address(_collToken);
            vars.tokens[1] = address(_boldToken);
        }
        uniV3PositionManager.createAndInitializePoolIfNecessary(
            vars.tokens[0], // token0,
            vars.tokens[1], // token1,
            UNIV3_FEE, // fee,
            UniV3Exchange(address(vars.uniV3Exchange)).priceToSqrtPrice(_boldToken, _collToken, vars.price) // sqrtPriceX96
        );

        return leverageZapperUniV3;
    }
    function _deployZappers(
        IAddressesRegistry _addressesRegistry,
        IERC20 _collToken,
        IWETH _weth
    )
    internal
    returns (
        GasCompZapper gasCompZapper,
        WETHZapper wethZapper
    )
    {
        bool lst = _collToken != _weth;
        if (lst) {
            gasCompZapper = new GasCompZapper(_addressesRegistry);
        } else {
            wethZapper = new WETHZapper(_addressesRegistry);
        }

        return (gasCompZapper, wethZapper);
    }

    function formatAmount(uint256 amount, uint256 decimals, uint256 digits) internal pure returns (string memory) {
        if (digits > decimals) {
            digits = decimals;
        }

        uint256 scaled = amount / (10 ** (decimals - digits));
        string memory whole = Strings.toString(scaled / (10 ** digits));

        if (digits == 0) {
            return whole;
        }

        string memory fractional = Strings.toString(scaled % (10 ** digits));
        for (uint256 i = bytes(fractional).length; i < digits; i++) {
            fractional = string.concat("0", fractional);
        }
        return string.concat(whole, ".", fractional);
    }

    function getAddress(address _deployer, bytes memory _bytecode, bytes32 _salt) public pure returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), _deployer, _salt, keccak256(_bytecode)));

        // NOTE: cast last 20 bytes of hash to address
        return address(uint160(uint256(hash)));
    }
    function _deployCurveLeverageZapper(
        IAddressesRegistry _addressesRegistry,
        IERC20 _collToken,
        IBoldToken _boldToken,
        IPriceFeed _priceFeed,
        IFlashLoanProvider _flashLoanProvider,
        bool _lst
    ) internal returns (ILeverageZapper) {
        (uint256 price,) = _priceFeed.fetchPrice();

        // deploy Curve Twocrypto NG pool
        address[2] memory coins;
        coins[0] = address(_boldToken);
        coins[1] = address(_collToken);
        ICurvePool curvePool = curveFactory.deploy_pool(
            "LST-Bold pool",
            "LBLD",
            coins,
            0, // implementation id
            400000, // A
            145000000000000, // gamma
            26000000, // mid_fee
            45000000, // out_fee
            230000000000000, // fee_gamma
            2000000000000, // allowed_extra_profit
            146000000000000, // adjustment_step
            600, // ma_exp_time
            price // initial_price
        );

        IExchange curveExchange = new CurveExchange(_collToken, _boldToken, curvePool, 1, 0);
        ILeverageZapper leverageZapperCurve;
        if (_lst) {
            leverageZapperCurve = new LeverageLSTZapper(_addressesRegistry, _flashLoanProvider, curveExchange);
        } else {
            leverageZapperCurve = new LeverageWETHZapper(_addressesRegistry, _flashLoanProvider, curveExchange);
        }

        return leverageZapperCurve;
    }

}

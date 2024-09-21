import {Script} from "forge-std/Script.sol";
import {ERC20Faucet} from "../test/TestContracts/ERC20Faucet.sol";
import {ITroveManager} from "../interfaces/ITroveManager.sol";
import {ISortedTroves} from "../interfaces/ISortedTroves.sol";
import {IBorrowerOperations} from "../interfaces/IBorrowerOperations.sol";
import {ITroveNFT} from "../interfaces/ITroveNFT.sol";
import {IHintHelpers} from "../interfaces/IHintHelpers.sol";
import {ICollateralRegistry} from "../interfaces/ICollateralRegistry.sol";
import {Clones} from "openzeppelin-contracts/contracts/proxy/Clones.sol";
import "forge-std/console.sol";

import {
    ETH_GAS_COMPENSATION,
    MAX_ANNUAL_INTEREST_RATE,
    MIN_ANNUAL_INTEREST_RATE,
    MIN_INTEREST_RATE_CHANGE_PERIOD
} from "../Dependencies/Constants.sol";

function sqrt(uint256 y) pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

contract Proxy {
    function tap(ERC20Faucet faucet) external {
        faucet.tap();
        faucet.transfer(msg.sender, faucet.balanceOf(address(this)));
    }

    function sweepTrove(ITroveNFT nft, uint256 troveId) external {
        nft.transferFrom(address(this), msg.sender, troveId);
    }
}

contract OpenTrove is Script {
    struct BranchContracts {
        ERC20Faucet collateral;
        ITroveManager troveManager;
        ISortedTroves sortedTroves;
        IBorrowerOperations borrowerOperations;
        ITroveNFT nft;
    }

    function _findHints(IHintHelpers hintHelpers, BranchContracts memory c, uint256 interestRate)
        internal
        view
        returns (uint256 upperHint, uint256 lowerHint)
    {
        // Find approx hint (off-chain)
        (uint256 approxHint,,) = hintHelpers.getApproxHint({
            _collIndex: 0,
            _interestRate: interestRate,
            _numTrials: sqrt(100 * c.troveManager.getTroveIdsCount()),
            _inputRandomSeed: block.timestamp
        });

        // Find concrete insert position (off-chain)
        (upperHint, lowerHint) = c.sortedTroves.findInsertPosition(interestRate, approxHint, approxHint);
    }

    function run() external {
        vm.startBroadcast();

        string memory manifestJson;
        try vm.readFile("deployment-manifest.json") returns (string memory content) {
            manifestJson = content;
        } catch {}

        ICollateralRegistry collateralRegistry;
        try vm.envAddress("COLLATERAL_REGISTRY") returns (address value) {
            collateralRegistry = ICollateralRegistry(value);
        } catch {
            collateralRegistry = ICollateralRegistry(vm.parseJsonAddress(manifestJson, ".collateralRegistry"));
        }
        vm.label(address(collateralRegistry), "CollateralRegistry");

        IHintHelpers hintHelpers;
        try vm.envAddress("HINT_HELPERS") returns (address value) {
            hintHelpers = IHintHelpers(value);
        } catch {
            hintHelpers = IHintHelpers(vm.parseJsonAddress(manifestJson, ".hintHelpers"));
        }
        vm.label(address(hintHelpers), "HintHelpers");

        address proxyImplementation = address(new Proxy());
        vm.label(proxyImplementation, "ProxyImplementation");

        // Correct constructor parameters for ERC20Faucet
        ERC20Faucet testRETH = new ERC20Faucet("testRETH", "tRETH", 1000 ether, 1 days);
        vm.label(address(testRETH), "testRETH");

        BranchContracts memory c;
        c.collateral = testRETH;
        c.troveManager = collateralRegistry.getTroveManager(0);
        vm.label(address(c.troveManager), "TroveManager");
        c.sortedTroves = c.troveManager.sortedTroves();
        vm.label(address(c.sortedTroves), "SortedTroves");
        c.borrowerOperations = c.troveManager.borrowerOperations();
        vm.label(address(c.borrowerOperations), "BorrowerOperations");
        c.nft = c.troveManager.troveNFT();
        vm.label(address(c.nft), "TroveNFT");

        // approve the faucet to spend the collateral

        if (c.borrowerOperations.getInterestBatchManager(msg.sender).maxInterestRate == 0) {
            // Register ourselves as batch manager, if we haven't
            c.borrowerOperations.registerBatchManager({
                minInterestRate: uint128(MIN_ANNUAL_INTEREST_RATE),
                maxInterestRate: uint128(MAX_ANNUAL_INTEREST_RATE),
                currentInterestRate: 0.025 ether,
                fee: 0.001 ether,
                minInterestRateChangePeriod: MIN_INTEREST_RATE_CHANGE_PERIOD
            });
        }

        Proxy proxy = Proxy(Clones.clone(proxyImplementation));
        vm.label(address(proxy), "Proxy");

        proxy.tap(c.collateral);
        uint256 ethAmount = c.collateral.tapAmount() / 2;

        console.log("ethAmount: %d", ethAmount);
        console.log("address(c.borrowerOperations): ", address(c.borrowerOperations));

        // Ensure sufficient allowance
        (bool approveSuccess, ) = address(proxy).call(
            abi.encodeWithSignature("approve(address,uint256)", address(c.borrowerOperations), ethAmount + ETH_GAS_COMPENSATION)
        );
        console.log("approveSuccess: %s", approveSuccess);

        uint256 allowance = c.collateral.allowance(address(proxy), address(c.borrowerOperations));
        console.log("allowance: %d", allowance);

        uint256 interestRate = 0.01 ether;
        (uint256 upperHint, uint256 lowerHint) = _findHints(hintHelpers, c, interestRate);

        uint256 troveId = c.borrowerOperations.openTrove({
            _owner: address(proxy),
            _ownerIndex: 0,
            _ETHAmount: ethAmount,
            _boldAmount: 2_000 ether,
            _upperHint: upperHint,
            _lowerHint: lowerHint,
            _annualInterestRate: interestRate,
            _maxUpfrontFee: type(uint256).max, // we don't care about fee slippage
            _addManager: address(0),
            _removeManager: address(0),
            _receiver: address(0)
        });

        proxy.sweepTrove(c.nft, troveId);
        c.collateral.transfer(address(0xdead), c.collateral.balanceOf(msg.sender));
    }
    
    
}
import "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";
import {ERC20Faucet} from "../test/TestContracts/ERC20Faucet.sol";
import {ITroveManager} from "../interfaces/ITroveManager.sol";
import {ISortedTroves} from "../interfaces/ISortedTroves.sol";
import {IBorrowerOperations} from "../interfaces/IBorrowerOperations.sol";
import {ITroveNFT} from "../interfaces/ITroveNFT.sol";
import {IHintHelpers} from "../interfaces/IHintHelpers.sol";
import {ICollateralRegistry} from "../interfaces/ICollateralRegistry.sol";
import {Clones} from "openzeppelin-contracts/contracts/proxy/Clones.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";


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

contract OpenTroveWETH is Script {
    struct BranchContracts {
        ERC20Faucet collateral;
        ITroveManager troveManager;
        ISortedTroves sortedTroves;
        IBorrowerOperations borrowerOperations;
        ITroveNFT nft;
    }

    function _findHints(IHintHelpers hintHelpers, BranchContracts memory c, uint256 branch, uint256 interestRate)
        internal
        view
        returns (uint256 upperHint, uint256 lowerHint)
    {
        // Find approx hint (off-chain)
        (uint256 approxHint,,) = hintHelpers.getApproxHint({
            _collIndex: branch,
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
        
        collateralRegistry = ICollateralRegistry(vm.parseJsonAddress(manifestJson, ".collateralRegistry"));
        console.log("collateralRegistry: ", address(collateralRegistry));
        vm.label(address(collateralRegistry), "CollateralRegistry");
        console.log("here");
        IHintHelpers hintHelpers;
        
        hintHelpers = IHintHelpers(vm.parseJsonAddress(manifestJson, ".hintHelpers"));
        console.log("here");
        vm.label(address(hintHelpers), "HintHelpers");

        address proxyImplementation = address(new Proxy());
        vm.label(proxyImplementation, "ProxyImplementation");
        console.log("here");
        uint256 token_index = 0;
        console.log("here2");
        uint256 res = collateralRegistry.getRedemptionRateWithDecay();
        console.log("res: ", res);
        IERC20Metadata token = collateralRegistry.getToken(token_index);
        console.log("here3");
        // try collateralRegistry.getToken(token_index) returns (IERC20Metadata token) {
        //     console.log("Token fetched: ", token);
        // } catch {
        //     console.log("Failed to get token from collateralRegistry");
        // }

        // address token = address(collateralRegistry.getToken(token_index));
        // console.log("token: ", token);
        ERC20Faucet weth = ERC20Faucet(address(collateralRegistry.getToken(token_index))); // branch #0 is WETH
        console.log("here");
        BranchContracts memory c;
        c.collateral = ERC20Faucet(address(collateralRegistry.getToken(token_index)));
        vm.label(address(c.collateral), "ERC20Faucet");
        c.troveManager = collateralRegistry.getTroveManager(token_index);
        vm.label(address(c.troveManager), "TroveManager");
        c.sortedTroves = c.troveManager.sortedTroves();
        vm.label(address(c.sortedTroves), "SortedTroves");
        c.borrowerOperations = c.troveManager.borrowerOperations();
        vm.label(address(c.borrowerOperations), "BorrowerOperations");
        c.nft = c.troveManager.troveNFT();
        vm.label(address(c.nft), "TroveNFT");

        // approve the faucet to spend the collateral

        console.log("msg.sender: ", msg.sender);
        //print all branch contracts
        console.log("c.collateral: ", address(c.collateral));
        console.log("c.troveManager: ", address(c.troveManager));
        console.log("c.sortedTroves: ", address(c.sortedTroves));
        console.log("c.borrowerOperations: ", address(c.borrowerOperations));
        console.log("c.nft: ", address(c.nft));

        
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
        c.collateral.approve(address(c.borrowerOperations), ethAmount + ETH_GAS_COMPENSATION);

        console.log("ethAmount: %d", ethAmount);
        console.log("address(c.borrowerOperations): ", address(c.borrowerOperations));

        //approve spend
        c.collateral.approve(address(c.borrowerOperations), ethAmount + ETH_GAS_COMPENSATION);
        console.log("approved spend");
        uint256 interestRate = 0.01 ether;
        (uint256 upperHint, uint256 lowerHint) = _findHints(hintHelpers, c, 0, interestRate);
        console.log("open trove");
        console.log("proxy address: ", address(proxy));
        console.log("balance of proxy: ", c.collateral.balanceOf(address(proxy)));

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
        console.log("troveId: %d", troveId);
        console.log("sweep trove");
        proxy.sweepTrove(c.nft, troveId);
        console.log("after sweep trove");
        // uint256 balanceOfMsgSender = c.collateral.balanceOf(msg.sender);
        // console.log("balanceOfMsgSender: %d", balanceOfMsgSender);
        // c.collateral.transfer(address(0xdead), c.collateral.balanceOf(msg.sender)); //send to dead address
    }
    
    
}
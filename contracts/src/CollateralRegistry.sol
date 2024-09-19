// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.18;

import "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "./Interfaces/ITroveManager.sol";
import "./Interfaces/IBoldToken.sol";
import "./Dependencies/Constants.sol";
import "./Dependencies/LiquityMath.sol";

import "./Interfaces/ICollateralRegistry.sol";

// import "forge-std/console2.sol";

contract CollateralRegistry is ICollateralRegistry {
    // mapping from Collateral token address to the corresponding TroveManagers
    //mapping(address => address) troveManagers;
    // See: https://github.com/ethereum/solidity/issues/12587
    uint256 public immutable totalCollaterals;

    IERC20Metadata internal immutable token0;
    IERC20Metadata internal immutable token1;
    IERC20Metadata internal immutable token2;
    IERC20Metadata internal immutable token3;
    IERC20Metadata internal immutable token4;
    IERC20Metadata internal immutable token5;
    IERC20Metadata internal immutable token6;
    IERC20Metadata internal immutable token7;
    IERC20Metadata internal immutable token8;
    IERC20Metadata internal immutable token9;
    IERC20Metadata internal immutable token10;
    IERC20Metadata internal immutable token11;
    IERC20Metadata internal immutable token12;
    IERC20Metadata internal immutable token13;
    IERC20Metadata internal immutable token14;
    IERC20Metadata internal immutable token15;
    IERC20Metadata internal immutable token16;
    IERC20Metadata internal immutable token17;
    IERC20Metadata internal immutable token18;
    IERC20Metadata internal immutable token19;
    IERC20Metadata internal immutable token20;
    IERC20Metadata internal immutable token21;
    IERC20Metadata internal immutable token22;
    IERC20Metadata internal immutable token23;
    IERC20Metadata internal immutable token24;
    IERC20Metadata internal immutable token25;
    IERC20Metadata internal immutable token26;
    IERC20Metadata internal immutable token27;
    IERC20Metadata internal immutable token28;
    IERC20Metadata internal immutable token29;
    IERC20Metadata internal immutable token30;
    IERC20Metadata internal immutable token31;
    IERC20Metadata internal immutable token32;
    IERC20Metadata internal immutable token33;
    IERC20Metadata internal immutable token34;
    IERC20Metadata internal immutable token35;
    IERC20Metadata internal immutable token36;
    IERC20Metadata internal immutable token37;
    IERC20Metadata internal immutable token38;
    IERC20Metadata internal immutable token39;
    IERC20Metadata internal immutable token40;
    IERC20Metadata internal immutable token41;
    IERC20Metadata internal immutable token42;
    IERC20Metadata internal immutable token43;
    IERC20Metadata internal immutable token44;
    IERC20Metadata internal immutable token45;
    IERC20Metadata internal immutable token46;
    IERC20Metadata internal immutable token47;
    IERC20Metadata internal immutable token48;
    IERC20Metadata internal immutable token49;
    IERC20Metadata internal immutable token50;
    IERC20Metadata internal immutable token51;
    IERC20Metadata internal immutable token52;
    IERC20Metadata internal immutable token53;
    IERC20Metadata internal immutable token54;
    IERC20Metadata internal immutable token55;
    IERC20Metadata internal immutable token56;
    IERC20Metadata internal immutable token57;
    IERC20Metadata internal immutable token58;
    IERC20Metadata internal immutable token59;
    IERC20Metadata internal immutable token60;
    IERC20Metadata internal immutable token61;
    IERC20Metadata internal immutable token62;
    IERC20Metadata internal immutable token63;
    IERC20Metadata internal immutable token64;
    IERC20Metadata internal immutable token65;
    IERC20Metadata internal immutable token66;
    IERC20Metadata internal immutable token67;
    IERC20Metadata internal immutable token68;
    IERC20Metadata internal immutable token69;

    ITroveManager internal immutable troveManager0;
    ITroveManager internal immutable troveManager1;
    ITroveManager internal immutable troveManager2;
    ITroveManager internal immutable troveManager3;
    ITroveManager internal immutable troveManager4;
    ITroveManager internal immutable troveManager5;
    ITroveManager internal immutable troveManager6;
    ITroveManager internal immutable troveManager7;
    ITroveManager internal immutable troveManager8;
    ITroveManager internal immutable troveManager9;
    ITroveManager internal immutable troveManager10;
    ITroveManager internal immutable troveManager11;
    ITroveManager internal immutable troveManager12;
    ITroveManager internal immutable troveManager13;
    ITroveManager internal immutable troveManager14;
    ITroveManager internal immutable troveManager15;
    ITroveManager internal immutable troveManager16;
    ITroveManager internal immutable troveManager17;
    ITroveManager internal immutable troveManager18;
    ITroveManager internal immutable troveManager19;
    ITroveManager internal immutable troveManager20;
    ITroveManager internal immutable troveManager21;
    ITroveManager internal immutable troveManager22;
    ITroveManager internal immutable troveManager23;
    ITroveManager internal immutable troveManager24;
    ITroveManager internal immutable troveManager25;
    ITroveManager internal immutable troveManager26;
    ITroveManager internal immutable troveManager27;
    ITroveManager internal immutable troveManager28;
    ITroveManager internal immutable troveManager29;
    ITroveManager internal immutable troveManager30;
    ITroveManager internal immutable troveManager31;
    ITroveManager internal immutable troveManager32;
    ITroveManager internal immutable troveManager33;
    ITroveManager internal immutable troveManager34;
    ITroveManager internal immutable troveManager35;
    ITroveManager internal immutable troveManager36;
    ITroveManager internal immutable troveManager37;
    ITroveManager internal immutable troveManager38;
    ITroveManager internal immutable troveManager39;
    ITroveManager internal immutable troveManager40;
    ITroveManager internal immutable troveManager41;
    ITroveManager internal immutable troveManager42;
    ITroveManager internal immutable troveManager43;
    ITroveManager internal immutable troveManager44;
    ITroveManager internal immutable troveManager45;
    ITroveManager internal immutable troveManager46;
    ITroveManager internal immutable troveManager47;
    ITroveManager internal immutable troveManager48;
    ITroveManager internal immutable troveManager49;
    ITroveManager internal immutable troveManager50;
    ITroveManager internal immutable troveManager51;
    ITroveManager internal immutable troveManager52;
    ITroveManager internal immutable troveManager53;
    ITroveManager internal immutable troveManager54;
    ITroveManager internal immutable troveManager55;
    ITroveManager internal immutable troveManager56;
    ITroveManager internal immutable troveManager57;
    ITroveManager internal immutable troveManager58;
    ITroveManager internal immutable troveManager59;
    ITroveManager internal immutable troveManager60;
    ITroveManager internal immutable troveManager61;
    ITroveManager internal immutable troveManager62;
    ITroveManager internal immutable troveManager63;
    ITroveManager internal immutable troveManager64;
    ITroveManager internal immutable troveManager65;
    ITroveManager internal immutable troveManager66;
    ITroveManager internal immutable troveManager67;
    ITroveManager internal immutable troveManager68;
    ITroveManager internal immutable troveManager69;

    IBoldToken public immutable boldToken;

    uint256 public baseRate;

    // The timestamp of the latest fee operation (redemption or new Bold issuance)
    uint256 public lastFeeOperationTime = block.timestamp;

    event BaseRateUpdated(uint256 _baseRate);
    event LastFeeOpTimeUpdated(uint256 _lastFeeOpTime);

    constructor(IBoldToken _boldToken, IERC20Metadata[] memory _tokens, ITroveManager[] memory _troveManagers) {
        uint256 numTokens = _tokens.length;
        require(numTokens > 0, "Collateral list cannot be empty");
        require(numTokens <= 10, "Collateral list too long");
        totalCollaterals = numTokens;

        boldToken = _boldToken;

        token0 = _tokens[0];
        token1 = numTokens > 1 ? _tokens[1] : IERC20Metadata(address(0));
        token2 = numTokens > 2 ? _tokens[2] : IERC20Metadata(address(0));
        token3 = numTokens > 3 ? _tokens[3] : IERC20Metadata(address(0));
        token4 = numTokens > 4 ? _tokens[4] : IERC20Metadata(address(0));
        token5 = numTokens > 5 ? _tokens[5] : IERC20Metadata(address(0));
        token6 = numTokens > 6 ? _tokens[6] : IERC20Metadata(address(0));
        token7 = numTokens > 7 ? _tokens[7] : IERC20Metadata(address(0));
        token8 = numTokens > 8 ? _tokens[8] : IERC20Metadata(address(0));
        token9 = numTokens > 9 ? _tokens[9] : IERC20Metadata(address(0));
        token10 = numTokens > 10 ? _tokens[10] : IERC20Metadata(address(0));
        token11 = numTokens > 11 ? _tokens[11] : IERC20Metadata(address(0));
        token12 = numTokens > 12 ? _tokens[12] : IERC20Metadata(address(0));
        token13 = numTokens > 13 ? _tokens[13] : IERC20Metadata(address(0));
        token14 = numTokens > 14 ? _tokens[14] : IERC20Metadata(address(0));
        token15 = numTokens > 15 ? _tokens[15] : IERC20Metadata(address(0));
        token16 = numTokens > 16 ? _tokens[16] : IERC20Metadata(address(0));
        token17 = numTokens > 17 ? _tokens[17] : IERC20Metadata(address(0));
        token18 = numTokens > 18 ? _tokens[18] : IERC20Metadata(address(0));
        token19 = numTokens > 19 ? _tokens[19] : IERC20Metadata(address(0));
        token20 = numTokens > 20 ? _tokens[20] : IERC20Metadata(address(0));
        token21 = numTokens > 21 ? _tokens[21] : IERC20Metadata(address(0));
        token22 = numTokens > 22 ? _tokens[22] : IERC20Metadata(address(0));
        token23 = numTokens > 23 ? _tokens[23] : IERC20Metadata(address(0));
        token24 = numTokens > 24 ? _tokens[24] : IERC20Metadata(address(0));
        token25 = numTokens > 25 ? _tokens[25] : IERC20Metadata(address(0));
        token26 = numTokens > 26 ? _tokens[26] : IERC20Metadata(address(0));
        token27 = numTokens > 27 ? _tokens[27] : IERC20Metadata(address(0));
        token28 = numTokens > 28 ? _tokens[28] : IERC20Metadata(address(0));
        token29 = numTokens > 29 ? _tokens[29] : IERC20Metadata(address(0));
        token30 = numTokens > 30 ? _tokens[30] : IERC20Metadata(address(0));
        token31 = numTokens > 31 ? _tokens[31] : IERC20Metadata(address(0));
        token32 = numTokens > 32 ? _tokens[32] : IERC20Metadata(address(0));
        token33 = numTokens > 33 ? _tokens[33] : IERC20Metadata(address(0));
        token34 = numTokens > 34 ? _tokens[34] : IERC20Metadata(address(0));
        token35 = numTokens > 35 ? _tokens[35] : IERC20Metadata(address(0));
        token36 = numTokens > 36 ? _tokens[36] : IERC20Metadata(address(0));
        token37 = numTokens > 37 ? _tokens[37] : IERC20Metadata(address(0));
        token38 = numTokens > 38 ? _tokens[38] : IERC20Metadata(address(0));
        token39 = numTokens > 39 ? _tokens[39] : IERC20Metadata(address(0));
        token40 = numTokens > 40 ? _tokens[40] : IERC20Metadata(address(0));
        token41 = numTokens > 41 ? _tokens[41] : IERC20Metadata(address(0));
        token42 = numTokens > 42 ? _tokens[42] : IERC20Metadata(address(0));
        token43 = numTokens > 43 ? _tokens[43] : IERC20Metadata(address(0));
        token44 = numTokens > 44 ? _tokens[44] : IERC20Metadata(address(0));
        token45 = numTokens > 45 ? _tokens[45] : IERC20Metadata(address(0));
        token46 = numTokens > 46 ? _tokens[46] : IERC20Metadata(address(0));
        token47 = numTokens > 47 ? _tokens[47] : IERC20Metadata(address(0));
        token48 = numTokens > 48 ? _tokens[48] : IERC20Metadata(address(0));
        token49 = numTokens > 49 ? _tokens[49] : IERC20Metadata(address(0));
        token50 = numTokens > 50 ? _tokens[50] : IERC20Metadata(address(0));
        token51 = numTokens > 51 ? _tokens[51] : IERC20Metadata(address(0));
        token52 = numTokens > 52 ? _tokens[52] : IERC20Metadata(address(0));
        token53 = numTokens > 53 ? _tokens[53] : IERC20Metadata(address(0));
        token54 = numTokens > 54 ? _tokens[54] : IERC20Metadata(address(0));
        token55 = numTokens > 55 ? _tokens[55] : IERC20Metadata(address(0));
        token56 = numTokens > 56 ? _tokens[56] : IERC20Metadata(address(0));
        token57 = numTokens > 57 ? _tokens[57] : IERC20Metadata(address(0));
        token58 = numTokens > 58 ? _tokens[58] : IERC20Metadata(address(0));
        token59 = numTokens > 59 ? _tokens[59] : IERC20Metadata(address(0));
        token60 = numTokens > 60 ? _tokens[60] : IERC20Metadata(address(0));
        token61 = numTokens > 61 ? _tokens[61] : IERC20Metadata(address(0));
        token62 = numTokens > 62 ? _tokens[62] : IERC20Metadata(address(0));
        token63 = numTokens > 63 ? _tokens[63] : IERC20Metadata(address(0));
        token64 = numTokens > 64 ? _tokens[64] : IERC20Metadata(address(0));
        token65 = numTokens > 65 ? _tokens[65] : IERC20Metadata(address(0));
        token66 = numTokens > 66 ? _tokens[66] : IERC20Metadata(address(0));
        token67 = numTokens > 67 ? _tokens[67] : IERC20Metadata(address(0));
        token68 = numTokens > 68 ? _tokens[68] : IERC20Metadata(address(0));
        token69 = numTokens > 69 ? _tokens[69] : IERC20Metadata(address(0));

        troveManager0 = _troveManagers[0];
        troveManager1 = numTokens > 1 ? _troveManagers[1] : ITroveManager(address(0));
        troveManager2 = numTokens > 2 ? _troveManagers[2] : ITroveManager(address(0));
        troveManager3 = numTokens > 3 ? _troveManagers[3] : ITroveManager(address(0));
        troveManager4 = numTokens > 4 ? _troveManagers[4] : ITroveManager(address(0));
        troveManager5 = numTokens > 5 ? _troveManagers[5] : ITroveManager(address(0));
        troveManager6 = numTokens > 6 ? _troveManagers[6] : ITroveManager(address(0));
        troveManager7 = numTokens > 7 ? _troveManagers[7] : ITroveManager(address(0));
        troveManager8 = numTokens > 8 ? _troveManagers[8] : ITroveManager(address(0));
        troveManager9 = numTokens > 9 ? _troveManagers[9] : ITroveManager(address(0));
        troveManager10 = numTokens > 10 ? _troveManagers[10] : ITroveManager(address(0));
        troveManager11 = numTokens > 11 ? _troveManagers[11] : ITroveManager(address(0));
        troveManager12 = numTokens > 12 ? _troveManagers[12] : ITroveManager(address(0));
        troveManager13 = numTokens > 13 ? _troveManagers[13] : ITroveManager(address(0));
        troveManager14 = numTokens > 14 ? _troveManagers[14] : ITroveManager(address(0));
        troveManager15 = numTokens > 15 ? _troveManagers[15] : ITroveManager(address(0));
        troveManager16 = numTokens > 16 ? _troveManagers[16] : ITroveManager(address(0));
        troveManager17 = numTokens > 17 ? _troveManagers[17] : ITroveManager(address(0));
        troveManager18 = numTokens > 18 ? _troveManagers[18] : ITroveManager(address(0));
        troveManager19 = numTokens > 19 ? _troveManagers[19] : ITroveManager(address(0));
        troveManager20 = numTokens > 20 ? _troveManagers[20] : ITroveManager(address(0));
        troveManager21 = numTokens > 21 ? _troveManagers[21] : ITroveManager(address(0));
        troveManager22 = numTokens > 22 ? _troveManagers[22] : ITroveManager(address(0));
        troveManager23 = numTokens > 23 ? _troveManagers[23] : ITroveManager(address(0));
        troveManager24 = numTokens > 24 ? _troveManagers[24] : ITroveManager(address(0));
        troveManager25 = numTokens > 25 ? _troveManagers[25] : ITroveManager(address(0));
        troveManager26 = numTokens > 26 ? _troveManagers[26] : ITroveManager(address(0));
        troveManager27 = numTokens > 27 ? _troveManagers[27] : ITroveManager(address(0));
        troveManager28 = numTokens > 28 ? _troveManagers[28] : ITroveManager(address(0));
        troveManager29 = numTokens > 29 ? _troveManagers[29] : ITroveManager(address(0));
        troveManager30 = numTokens > 30 ? _troveManagers[30] : ITroveManager(address(0));
        troveManager31 = numTokens > 31 ? _troveManagers[31] : ITroveManager(address(0));
        troveManager32 = numTokens > 32 ? _troveManagers[32] : ITroveManager(address(0));
        troveManager33 = numTokens > 33 ? _troveManagers[33] : ITroveManager(address(0));
        troveManager34 = numTokens > 34 ? _troveManagers[34] : ITroveManager(address(0));
        troveManager35 = numTokens > 35 ? _troveManagers[35] : ITroveManager(address(0));
        troveManager36 = numTokens > 36 ? _troveManagers[36] : ITroveManager(address(0));
        troveManager37 = numTokens > 37 ? _troveManagers[37] : ITroveManager(address(0));
        troveManager38 = numTokens > 38 ? _troveManagers[38] : ITroveManager(address(0));
        troveManager39 = numTokens > 39 ? _troveManagers[39] : ITroveManager(address(0));
        troveManager40 = numTokens > 40 ? _troveManagers[40] : ITroveManager(address(0));
        troveManager41 = numTokens > 41 ? _troveManagers[41] : ITroveManager(address(0));
        troveManager42 = numTokens > 42 ? _troveManagers[42] : ITroveManager(address(0));
        troveManager43 = numTokens > 43 ? _troveManagers[43] : ITroveManager(address(0));
        troveManager44 = numTokens > 44 ? _troveManagers[44] : ITroveManager(address(0));
        troveManager45 = numTokens > 45 ? _troveManagers[45] : ITroveManager(address(0));
        troveManager46 = numTokens > 46 ? _troveManagers[46] : ITroveManager(address(0));
        troveManager47 = numTokens > 47 ? _troveManagers[47] : ITroveManager(address(0));
        troveManager48 = numTokens > 48 ? _troveManagers[48] : ITroveManager(address(0));
        troveManager49 = numTokens > 49 ? _troveManagers[49] : ITroveManager(address(0));
        troveManager50 = numTokens > 50 ? _troveManagers[50] : ITroveManager(address(0));
        troveManager51 = numTokens > 51 ? _troveManagers[51] : ITroveManager(address(0));
        troveManager52 = numTokens > 52 ? _troveManagers[52] : ITroveManager(address(0));
        troveManager53 = numTokens > 53 ? _troveManagers[53] : ITroveManager(address(0));
        troveManager54 = numTokens > 54 ? _troveManagers[54] : ITroveManager(address(0));
        troveManager55 = numTokens > 55 ? _troveManagers[55] : ITroveManager(address(0));
        troveManager56 = numTokens > 56 ? _troveManagers[56] : ITroveManager(address(0));
        troveManager57 = numTokens > 57 ? _troveManagers[57] : ITroveManager(address(0));
        troveManager58 = numTokens > 58 ? _troveManagers[58] : ITroveManager(address(0));
        troveManager59 = numTokens > 59 ? _troveManagers[59] : ITroveManager(address(0));
        troveManager60 = numTokens > 60 ? _troveManagers[60] : ITroveManager(address(0));
        troveManager61 = numTokens > 61 ? _troveManagers[61] : ITroveManager(address(0));
        troveManager62 = numTokens > 62 ? _troveManagers[62] : ITroveManager(address(0));
        troveManager63 = numTokens > 63 ? _troveManagers[63] : ITroveManager(address(0));
        troveManager64 = numTokens > 64 ? _troveManagers[64] : ITroveManager(address(0));
        troveManager65 = numTokens > 65 ? _troveManagers[65] : ITroveManager(address(0));
        troveManager66 = numTokens > 66 ? _troveManagers[66] : ITroveManager(address(0));
        troveManager67 = numTokens > 67 ? _troveManagers[67] : ITroveManager(address(0));
        troveManager68 = numTokens > 68 ? _troveManagers[68] : ITroveManager(address(0));
        troveManager69 = numTokens > 69 ? _troveManagers[69] : ITroveManager(address(0));

        // Initialize the baseRate state variable
        baseRate = INITIAL_BASE_RATE;
        emit BaseRateUpdated(INITIAL_BASE_RATE);
    }

    struct RedemptionTotals {
        uint256 numCollaterals;
        uint256 boldSupplyAtStart;
        uint256 unbacked;
        uint256 redeemedAmount;
    }

    function redeemCollateral(uint256 _boldAmount, uint256 _maxIterationsPerCollateral, uint256 _maxFeePercentage)
        external
    {
        _requireValidMaxFeePercentage(_maxFeePercentage);
        _requireAmountGreaterThanZero(_boldAmount);
        _requireBoldBalanceCoversRedemption(boldToken, msg.sender, _boldAmount);

        RedemptionTotals memory totals;

        totals.numCollaterals = totalCollaterals;
        uint256[] memory unbackedPortions = new uint256[](totals.numCollaterals);
        uint256[] memory prices = new uint256[](totals.numCollaterals);

        totals.boldSupplyAtStart = boldToken.totalSupply();
        // Decay the baseRate due to time passed, and then increase it according to the size of this redemption.
        // Use the saved total Bold supply value, from before it was reduced by the redemption.
        // We only compute it here, and update it at the end,
        // because the final redeemed amount may be less than the requested amount
        // Redeemers should take this into account in order to request the optimal amount to not overpay
        uint256 redemptionRate =
            _calcRedemptionRate(_getUpdatedBaseRateFromRedemption(_boldAmount, totals.boldSupplyAtStart));
        require(redemptionRate <= _maxFeePercentage, "CR: Fee exceeded provided maximum");
        // Implicit by the above and the _requireValidMaxFeePercentage checks
        //require(newBaseRate < DECIMAL_PRECISION, "CR: Fee would eat up all collateral");

        // Gather and accumulate unbacked portions
        for (uint256 index = 0; index < totals.numCollaterals; index++) {
            ITroveManager troveManager = getTroveManager(index);
            (uint256 unbackedPortion, uint256 price, bool redeemable) =
                troveManager.getUnbackedPortionPriceAndRedeemability();
            prices[index] = price;
            if (redeemable) {
                totals.unbacked += unbackedPortion;
                unbackedPortions[index] = unbackedPortion;
            }
        }

        // There’s an unlikely scenario where all the normally redeemable branches (i.e. having TCR > SCR) have 0 unbacked
        // In that case, we redeem proportinally to branch size
        if (totals.unbacked == 0) {
            unbackedPortions = new uint256[](totals.numCollaterals);
            for (uint256 index = 0; index < totals.numCollaterals; index++) {
                ITroveManager troveManager = getTroveManager(index);
                (,, bool redeemable) = troveManager.getUnbackedPortionPriceAndRedeemability();
                if (redeemable) {
                    uint256 unbackedPortion = troveManager.getEntireSystemDebt();
                    totals.unbacked += unbackedPortion;
                    unbackedPortions[index] = unbackedPortion;
                }
            }
        }

        // Compute redemption amount for each collateral and redeem against the corresponding TroveManager
        for (uint256 index = 0; index < totals.numCollaterals; index++) {
            //uint256 unbackedPortion = unbackedPortions[index];
            if (unbackedPortions[index] > 0) {
                uint256 redeemAmount = _boldAmount * unbackedPortions[index] / totals.unbacked;
                if (redeemAmount > 0) {
                    ITroveManager troveManager = getTroveManager(index);
                    uint256 redeemedAmount = troveManager.redeemCollateral(
                        msg.sender, redeemAmount, prices[index], redemptionRate, _maxIterationsPerCollateral
                    );
                    totals.redeemedAmount += redeemedAmount;
                }
            }
        }

        _updateBaseRateAndGetRedemptionRate(totals.redeemedAmount, totals.boldSupplyAtStart);

        // Burn the total Bold that is cancelled with debt
        if (totals.redeemedAmount > 0) {
            boldToken.burn(msg.sender, totals.redeemedAmount);
        }
    }

    // --- Internal fee functions ---

    // Update the last fee operation time only if time passed >= decay interval. This prevents base rate griefing.
    function _updateLastFeeOpTime() internal {
        uint256 timePassed = block.timestamp - lastFeeOperationTime;

        if (timePassed >= ONE_MINUTE) {
            lastFeeOperationTime = block.timestamp;
            emit LastFeeOpTimeUpdated(block.timestamp);
        }
    }

    function _minutesPassedSinceLastFeeOp() internal view returns (uint256) {
        return (block.timestamp - lastFeeOperationTime) / ONE_MINUTE;
    }

    // Updates the `baseRate` state with math from `_getUpdatedBaseRateFromRedemption`
    function _updateBaseRateAndGetRedemptionRate(uint256 _boldAmount, uint256 _totalBoldSupplyAtStart) internal {
        uint256 newBaseRate = _getUpdatedBaseRateFromRedemption(_boldAmount, _totalBoldSupplyAtStart);

        //assert(newBaseRate <= DECIMAL_PRECISION); // This is already enforced in `_getUpdatedBaseRateFromRedemption`

        // Update the baseRate state variable
        baseRate = newBaseRate;
        emit BaseRateUpdated(newBaseRate);

        _updateLastFeeOpTime();
    }

    /*
     * This function calculates the new baseRate in the following way:
     * 1) decays the baseRate based on time passed since last redemption or Bold borrowing operation.
     * then,
     * 2) increases the baseRate based on the amount redeemed, as a proportion of total supply
     */
    function _getUpdatedBaseRateFromRedemption(uint256 _redeemAmount, uint256 _totalBoldSupply)
        internal
        view
        returns (uint256)
    {
        // decay the base rate
        uint256 decayedBaseRate = _calcDecayedBaseRate();

        // get the fraction of total supply that was redeemed
        uint256 redeemedBoldFraction = _redeemAmount * DECIMAL_PRECISION / _totalBoldSupply;

        uint256 newBaseRate = decayedBaseRate + redeemedBoldFraction / REDEMPTION_BETA;
        newBaseRate = LiquityMath._min(newBaseRate, DECIMAL_PRECISION); // cap baseRate at a maximum of 100%

        return newBaseRate;
    }

    function _calcDecayedBaseRate() internal view returns (uint256) {
        uint256 minutesPassed = _minutesPassedSinceLastFeeOp();
        uint256 decayFactor = LiquityMath._decPow(REDEMPTION_MINUTE_DECAY_FACTOR, minutesPassed);

        return baseRate * decayFactor / DECIMAL_PRECISION;
    }

    function _calcRedemptionRate(uint256 _baseRate) internal pure returns (uint256) {
        return LiquityMath._min(
            REDEMPTION_FEE_FLOOR + _baseRate,
            DECIMAL_PRECISION // cap at a maximum of 100%
        );
    }

    function _calcRedemptionFee(uint256 _redemptionRate, uint256 _amount) internal pure returns (uint256) {
        uint256 redemptionFee = _redemptionRate * _amount / DECIMAL_PRECISION;
        return redemptionFee;
    }

    // external redemption rate/fee getters

    function getRedemptionRate() external view override returns (uint256) {
        return _calcRedemptionRate(baseRate);
    }

    function getRedemptionRateWithDecay() public view override returns (uint256) {
        return _calcRedemptionRate(_calcDecayedBaseRate());
    }

    function getRedemptionRateForRedeemedAmount(uint256 _redeemAmount) external view returns (uint256) {
        uint256 totalBoldSupply = boldToken.totalSupply();
        uint256 newBaseRate = _getUpdatedBaseRateFromRedemption(_redeemAmount, totalBoldSupply);
        return _calcRedemptionRate(newBaseRate);
    }

    function getRedemptionFeeWithDecay(uint256 _ETHDrawn) external view override returns (uint256) {
        return _calcRedemptionFee(getRedemptionRateWithDecay(), _ETHDrawn);
    }

    function getEffectiveRedemptionFeeInBold(uint256 _redeemAmount) external view override returns (uint256) {
        uint256 totalBoldSupply = boldToken.totalSupply();
        uint256 newBaseRate = _getUpdatedBaseRateFromRedemption(_redeemAmount, totalBoldSupply);
        return _calcRedemptionFee(_calcRedemptionRate(newBaseRate), _redeemAmount);
    }

    // getters

    function getToken(uint256 _index) external view returns (IERC20Metadata) {
        if (_index == 0) return token0;
        else if (_index == 1) return token1;
        else if (_index == 2) return token2;
        else if (_index == 3) return token3;
        else if (_index == 4) return token4;
        else if (_index == 5) return token5;
        else if (_index == 6) return token6;
        else if (_index == 7) return token7;
        else if (_index == 8) return token8;
        else if (_index == 9) return token9;
        else revert("Invalid index");
    }

    function getTroveManager(uint256 _index) public view returns (ITroveManager) {
        if (_index == 0) return troveManager0;
        else if (_index == 1) return troveManager1;
        else if (_index == 2) return troveManager2;
        else if (_index == 3) return troveManager3;
        else if (_index == 4) return troveManager4;
        else if (_index == 5) return troveManager5;
        else if (_index == 6) return troveManager6;
        else if (_index == 7) return troveManager7;
        else if (_index == 8) return troveManager8;
        else if (_index == 9) return troveManager9;
        else revert("Invalid index");
    }

    // require functions

    function _requireValidMaxFeePercentage(uint256 _maxFeePercentage) internal pure {
        require(
            _maxFeePercentage >= REDEMPTION_FEE_FLOOR && _maxFeePercentage <= DECIMAL_PRECISION,
            "Max fee percentage must be between 0.5% and 100%"
        );
    }

    function _requireAmountGreaterThanZero(uint256 _amount) internal pure {
        require(_amount > 0, "CollateralRegistry: Amount must be greater than zero");
    }

    function _requireBoldBalanceCoversRedemption(IBoldToken _boldToken, address _redeemer, uint256 _amount)
        internal
        view
    {
        uint256 boldBalance = _boldToken.balanceOf(_redeemer);
        // Confirm redeemer's balance is less than total Bold supply
        assert(boldBalance <= _boldToken.totalSupply());
        require(
            boldBalance >= _amount,
            "CollateralRegistry: Requested redemption amount must be <= user's Bold token balance"
        );
    }
}

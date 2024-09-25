// this file was generated by scripts/update-liquity-abis.ts
// please do not edit it manually
export const ActivePool = [
  {
    "type": "constructor",
    "inputs": [{ "name": "_addressesRegistry", "type": "address", "internalType": "contract IAddressesRegistry" }],
    "stateMutability": "nonpayable",
  },
  {
    "type": "function",
    "name": "NAME",
    "inputs": [],
    "outputs": [{ "name": "", "type": "string", "internalType": "string" }],
    "stateMutability": "view",
  },
  {
    "type": "function",
    "name": "accountForReceivedColl",
    "inputs": [{ "name": "_amount", "type": "uint256", "internalType": "uint256" }],
    "outputs": [],
    "stateMutability": "nonpayable",
  },
  {
    "type": "function",
    "name": "aggBatchManagementFees",
    "inputs": [],
    "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
    "stateMutability": "view",
  },
  {
    "type": "function",
    "name": "aggRecordedDebt",
    "inputs": [],
    "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
    "stateMutability": "view",
  },
  {
    "type": "function",
    "name": "aggWeightedBatchManagementFeeSum",
    "inputs": [],
    "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
    "stateMutability": "view",
  },
  {
    "type": "function",
    "name": "aggWeightedDebtSum",
    "inputs": [],
    "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
    "stateMutability": "view",
  },
  {
    "type": "function",
    "name": "borrowerOperationsAddress",
    "inputs": [],
    "outputs": [{ "name": "", "type": "address", "internalType": "address" }],
    "stateMutability": "view",
  },
  {
    "type": "function",
    "name": "calcPendingAggBatchManagementFee",
    "inputs": [],
    "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
    "stateMutability": "view",
  },
  {
    "type": "function",
    "name": "calcPendingAggInterest",
    "inputs": [],
    "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
    "stateMutability": "view",
  },
  {
    "type": "function",
    "name": "calcPendingSPYield",
    "inputs": [],
    "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
    "stateMutability": "view",
  },
  {
    "type": "function",
    "name": "collToken",
    "inputs": [],
    "outputs": [{ "name": "", "type": "address", "internalType": "contract IERC20" }],
    "stateMutability": "view",
  },
  {
    "type": "function",
    "name": "defaultPoolAddress",
    "inputs": [],
    "outputs": [{ "name": "", "type": "address", "internalType": "address" }],
    "stateMutability": "view",
  },
  {
    "type": "function",
    "name": "getBoldDebt",
    "inputs": [],
    "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
    "stateMutability": "view",
  },
  {
    "type": "function",
    "name": "getCollBalance",
    "inputs": [],
    "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
    "stateMutability": "view",
  },
  {
    "type": "function",
    "name": "getNewApproxAvgInterestRateFromTroveChange",
    "inputs": [{
      "name": "_troveChange",
      "type": "tuple",
      "internalType": "struct TroveChange",
      "components": [
        { "name": "appliedRedistBoldDebtGain", "type": "uint256", "internalType": "uint256" },
        { "name": "appliedRedistCollGain", "type": "uint256", "internalType": "uint256" },
        { "name": "collIncrease", "type": "uint256", "internalType": "uint256" },
        { "name": "collDecrease", "type": "uint256", "internalType": "uint256" },
        { "name": "debtIncrease", "type": "uint256", "internalType": "uint256" },
        { "name": "debtDecrease", "type": "uint256", "internalType": "uint256" },
        { "name": "newWeightedRecordedDebt", "type": "uint256", "internalType": "uint256" },
        { "name": "oldWeightedRecordedDebt", "type": "uint256", "internalType": "uint256" },
        { "name": "upfrontFee", "type": "uint256", "internalType": "uint256" },
        { "name": "batchAccruedManagementFee", "type": "uint256", "internalType": "uint256" },
        { "name": "newWeightedRecordedBatchManagementFee", "type": "uint256", "internalType": "uint256" },
        { "name": "oldWeightedRecordedBatchManagementFee", "type": "uint256", "internalType": "uint256" },
      ],
    }],
    "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
    "stateMutability": "view",
  },
  {
    "type": "function",
    "name": "hasBeenShutDown",
    "inputs": [],
    "outputs": [{ "name": "", "type": "bool", "internalType": "bool" }],
    "stateMutability": "view",
  },
  {
    "type": "function",
    "name": "interestRouter",
    "inputs": [],
    "outputs": [{ "name": "", "type": "address", "internalType": "contract IInterestRouter" }],
    "stateMutability": "view",
  },
  {
    "type": "function",
    "name": "lastAggBatchManagementFeesUpdateTime",
    "inputs": [],
    "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
    "stateMutability": "view",
  },
  {
    "type": "function",
    "name": "lastAggUpdateTime",
    "inputs": [],
    "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
    "stateMutability": "view",
  },
  { "type": "function", "name": "mintAggInterest", "inputs": [], "outputs": [], "stateMutability": "nonpayable" },
  {
    "type": "function",
    "name": "mintAggInterestAndAccountForTroveChange",
    "inputs": [{
      "name": "_troveChange",
      "type": "tuple",
      "internalType": "struct TroveChange",
      "components": [
        { "name": "appliedRedistBoldDebtGain", "type": "uint256", "internalType": "uint256" },
        { "name": "appliedRedistCollGain", "type": "uint256", "internalType": "uint256" },
        { "name": "collIncrease", "type": "uint256", "internalType": "uint256" },
        { "name": "collDecrease", "type": "uint256", "internalType": "uint256" },
        { "name": "debtIncrease", "type": "uint256", "internalType": "uint256" },
        { "name": "debtDecrease", "type": "uint256", "internalType": "uint256" },
        { "name": "newWeightedRecordedDebt", "type": "uint256", "internalType": "uint256" },
        { "name": "oldWeightedRecordedDebt", "type": "uint256", "internalType": "uint256" },
        { "name": "upfrontFee", "type": "uint256", "internalType": "uint256" },
        { "name": "batchAccruedManagementFee", "type": "uint256", "internalType": "uint256" },
        { "name": "newWeightedRecordedBatchManagementFee", "type": "uint256", "internalType": "uint256" },
        { "name": "oldWeightedRecordedBatchManagementFee", "type": "uint256", "internalType": "uint256" },
      ],
    }, { "name": "_batchAddress", "type": "address", "internalType": "address" }],
    "outputs": [],
    "stateMutability": "nonpayable",
  },
  {
    "type": "function",
    "name": "mintBatchManagementFeeAndAccountForChange",
    "inputs": [{
      "name": "_troveChange",
      "type": "tuple",
      "internalType": "struct TroveChange",
      "components": [
        { "name": "appliedRedistBoldDebtGain", "type": "uint256", "internalType": "uint256" },
        { "name": "appliedRedistCollGain", "type": "uint256", "internalType": "uint256" },
        { "name": "collIncrease", "type": "uint256", "internalType": "uint256" },
        { "name": "collDecrease", "type": "uint256", "internalType": "uint256" },
        { "name": "debtIncrease", "type": "uint256", "internalType": "uint256" },
        { "name": "debtDecrease", "type": "uint256", "internalType": "uint256" },
        { "name": "newWeightedRecordedDebt", "type": "uint256", "internalType": "uint256" },
        { "name": "oldWeightedRecordedDebt", "type": "uint256", "internalType": "uint256" },
        { "name": "upfrontFee", "type": "uint256", "internalType": "uint256" },
        { "name": "batchAccruedManagementFee", "type": "uint256", "internalType": "uint256" },
        { "name": "newWeightedRecordedBatchManagementFee", "type": "uint256", "internalType": "uint256" },
        { "name": "oldWeightedRecordedBatchManagementFee", "type": "uint256", "internalType": "uint256" },
      ],
    }, { "name": "_batchAddress", "type": "address", "internalType": "address" }],
    "outputs": [],
    "stateMutability": "nonpayable",
  },
  {
    "type": "function",
    "name": "receiveColl",
    "inputs": [{ "name": "_amount", "type": "uint256", "internalType": "uint256" }],
    "outputs": [],
    "stateMutability": "nonpayable",
  },
  {
    "type": "function",
    "name": "sendColl",
    "inputs": [{ "name": "_account", "type": "address", "internalType": "address" }, {
      "name": "_amount",
      "type": "uint256",
      "internalType": "uint256",
    }],
    "outputs": [],
    "stateMutability": "nonpayable",
  },
  {
    "type": "function",
    "name": "sendCollToDefaultPool",
    "inputs": [{ "name": "_amount", "type": "uint256", "internalType": "uint256" }],
    "outputs": [],
    "stateMutability": "nonpayable",
  },
  { "type": "function", "name": "setShutdownFlag", "inputs": [], "outputs": [], "stateMutability": "nonpayable" },
  {
    "type": "function",
    "name": "shutdownTime",
    "inputs": [],
    "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
    "stateMutability": "view",
  },
  {
    "type": "function",
    "name": "stabilityPool",
    "inputs": [],
    "outputs": [{ "name": "", "type": "address", "internalType": "contract IBoldRewardsReceiver" }],
    "stateMutability": "view",
  },
  {
    "type": "function",
    "name": "troveManagerAddress",
    "inputs": [],
    "outputs": [{ "name": "", "type": "address", "internalType": "address" }],
    "stateMutability": "view",
  },
  {
    "type": "event",
    "name": "ActivePoolBoldDebtUpdated",
    "inputs": [{ "name": "_recordedDebtSum", "type": "uint256", "indexed": false, "internalType": "uint256" }],
    "anonymous": false,
  },
  {
    "type": "event",
    "name": "ActivePoolCollBalanceUpdated",
    "inputs": [{ "name": "_collBalance", "type": "uint256", "indexed": false, "internalType": "uint256" }],
    "anonymous": false,
  },
  {
    "type": "event",
    "name": "BorrowerOperationsAddressChanged",
    "inputs": [{
      "name": "_newBorrowerOperationsAddress",
      "type": "address",
      "indexed": false,
      "internalType": "address",
    }],
    "anonymous": false,
  },
  {
    "type": "event",
    "name": "CollTokenAddressChanged",
    "inputs": [{ "name": "_newCollTokenAddress", "type": "address", "indexed": false, "internalType": "address" }],
    "anonymous": false,
  },
  {
    "type": "event",
    "name": "DefaultPoolAddressChanged",
    "inputs": [{ "name": "_newDefaultPoolAddress", "type": "address", "indexed": false, "internalType": "address" }],
    "anonymous": false,
  },
  {
    "type": "event",
    "name": "EtherSent",
    "inputs": [{ "name": "_to", "type": "address", "indexed": false, "internalType": "address" }, {
      "name": "_amount",
      "type": "uint256",
      "indexed": false,
      "internalType": "uint256",
    }],
    "anonymous": false,
  },
  {
    "type": "event",
    "name": "StabilityPoolAddressChanged",
    "inputs": [{ "name": "_newStabilityPoolAddress", "type": "address", "indexed": false, "internalType": "address" }],
    "anonymous": false,
  },
  {
    "type": "event",
    "name": "TroveManagerAddressChanged",
    "inputs": [{ "name": "_newTroveManagerAddress", "type": "address", "indexed": false, "internalType": "address" }],
    "anonymous": false,
  },
] as const;

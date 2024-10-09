import type { Token } from "./types";

import tokenBold from "./token-icons/bold.svg";
import tokenEth from "./token-icons/eth.svg";
import tokenLqty from "./token-icons/lqty.svg";
import tokenLusd from "./token-icons/lusd.svg";
import tokenReth from "./token-icons/reth.svg";
import tokenSteth from "./token-icons/wsteth.svg";

export type CollateralSymbol = "ETH" | "RETH" | "STETH"| "WEETH" | "EZETH";

export function isCollateralSymbol(symbol: string): symbol is CollateralSymbol {
  return symbol === "ETH" || symbol === "RETH" || symbol === "STETH" || symbol === "WEETH"|| symbol === "EZETH";
}

export type CollateralToken = Token & {
  collateralRatio: number;
  symbol: CollateralSymbol;
};

export const LUSD: Token = {
  icon: tokenLusd,
  name: "LUSD",
  symbol: "LUSD" as const,
} as const;

export const BOLD: Token = {
  icon: tokenBold,
  name: "BOLD",
  symbol: "BOLD" as const,
} as const;

export const LQTY: Token = {
  icon: tokenLqty,
  name: "LQTY",
  symbol: "LQTY" as const,
} as const;

export const ETH: CollateralToken = {
  collateralRatio: 1.1,
  icon: tokenEth,
  name: "ETH",
  symbol: "ETH" as const,
} as const;

export const RETH: CollateralToken = {
  collateralRatio: 1.2,
  icon: tokenReth,
  name: "rETH",
  symbol: "RETH" as const,
} as const;

export const STETH: CollateralToken = {
  collateralRatio: 1.2,
  icon: tokenSteth,
  name: "stETH",
  symbol: "STETH" as const,
} as const;

export const WEETH: CollateralToken = {
  collateralRatio: 1.2,
  icon: tokenEth,
  name: "weETH",
  symbol: "WEETH" as const,
} as const;

export const EZETH: CollateralToken = {
  collateralRatio: 1.2,
  icon: tokenEth,
  name: "ezETH",
  symbol: "EZETH" as const,
} as const;

export const COLLATERALS: CollateralToken[] = [
  ETH,
  RETH,
  STETH,
  WEETH,
  EZETH
];

export const TOKENS_BY_SYMBOL = {
  BOLD,
  ETH,
  LQTY,
  RETH,
  STETH,
  WEETH,
  EZETH,
  LUSD,
} as const;

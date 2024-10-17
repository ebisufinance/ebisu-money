"use client";

import content from "@/src/content";
import { useCollateralContracts } from "@/src/contracts";
import { useCollIndexFromSymbol } from "@/src/liquity-utils";
import { usePrice } from "@/src/services/Prices";
import { useStabilityPool } from "@/src/subgraph-hooks";
import { css } from "@/styled-system/css";
import { HFlex, TokenIcon, TOKENS_BY_SYMBOL } from "@liquity2/uikit";
import * as dn from "dnum";
import { Amount } from "../Amount/Amount";

export function ProtocolStats() {
  const prices = [
    ["LQTY", usePrice("LQTY")],
    ["BOLD", usePrice("BOLD")],
    ["WEETH", usePrice("WEETH")],
  ] as const;

  const collSymbols = useCollateralContracts().map((coll) => coll.symbol);
  let totalTVL: dn.Dnum = dn.from(0, 18);
  collSymbols.map((symbol) => {
    const collIndex = useCollIndexFromSymbol(symbol);
    const earnPool = useStabilityPool(collIndex ?? undefined);
    totalTVL = dn.add(earnPool.data?.totalDeposited || 0, totalTVL);
  });

  return (
    <div
      className={css({
        display: "flex",
        justifyContent: "space-between",
        width: "100%",
        padding: "12px 0 20px",
        fontSize: 12,
        borderTop: "1px solid token(colors.tableBorder)",
      })}
    >
      <div>{content.home.statsBar.label}</div>
      <HFlex gap={32}>
        <HFlex gap={8}>
          <span>TVL</span>{" "}
          <span>
            <Amount
              format="compact"
              prefix="$"
              value={totalTVL}
            />
          </span>
        </HFlex>
        {prices.map(([symbol, price]) => {
          return (
            <HFlex key={symbol} gap={16}>
              <TokenIcon size={16} symbol={symbol} />
              <HFlex gap={8}>
                <span>{TOKENS_BY_SYMBOL[symbol].name}</span>
                <span>
                  $
                  {price
                    && dn.format(price, {
                      digits: 2,
                      trailingZeros: true,
                    })}
                </span>
              </HFlex>
            </HFlex>
          );
        })}
      </HFlex>
    </div>
  );
}

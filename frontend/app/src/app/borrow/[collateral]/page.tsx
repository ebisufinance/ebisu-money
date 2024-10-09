export function generateStaticParams() {
  return [
    { collateral: "eth" },
    { collateral: "reth" },
    { collateral: "steth" },
    { collateral: "weeth" },
    { collateral: "ezeth" },
  ];
}

export default function BorrowCollateralPage() {
  // see layout in parent folder
  return null;
}

export function generateStaticParams() {
  return [
    { collateral: "eth" },
    { collateral: "reth" },
    { collateral: "steth" },
    { collateral: "weeth" },
  ];
}

export default function BorrowCollateralPage() {
  // see layout in parent folder
  return null;
}

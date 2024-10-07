import type { FlowDeclaration } from "@/src/services/TransactionFlow";

import { Amount } from "@/src/comps/Amount/Amount";
import { TransactionDetailsRow } from "@/src/screens/TransactionsScreen/TransactionsScreen";
import { usePrice } from "@/src/services/Prices";
import { vAddress, vCollIndex, vDnum } from "@/src/valibot-utils";
import * as dn from "dnum";
import * as v from "valibot";

const FlowIdSchema = v.literal("earnWithdraw");

const RequestSchema = v.object({
  flowId: FlowIdSchema,
  backLink: v.union([
    v.null(),
    v.tuple([
      v.string(), // path
      v.string(), // label
    ]),
  ]),
  successLink: v.tuple([
    v.string(), // path
    v.string(), // label
  ]),
  successMessage: v.string(),

  collIndex: vCollIndex(),
  depositor: vAddress(),
  ebusdAmount: vDnum(),
  claim: v.boolean(),
});

export type Request = v.InferOutput<typeof RequestSchema>;

type Step = "withdrawFromStabilityPool";

const stepNames: Record<Step, string> = {
  withdrawFromStabilityPool: "Withdraw",
};

export const earnWithdraw: FlowDeclaration<Request, Step> = {
  title: "Review & Send Transaction",
  subtitle: "Please review your borrow position before confirming",

  Summary() {
    // const { symbol } = useCollateral(flow.request.collIndex);
    return null;
  },

  Details({ flow }) {
    const { request } = flow;
    const ebusdPrice = usePrice("EBUSD");
    return (
      <>
        <TransactionDetailsRow
          label="You withdraw"
          value={[
            <Amount value={request.ebusdAmount} suffix=" EBUSD" />,
            <Amount
              value={ebusdPrice && dn.mul(request.ebusdAmount, ebusdPrice)}
              prefix="$"
            />,
          ]}
        />
      </>
    );
  },

  async getSteps() {
    return ["withdrawFromStabilityPool"];
  },

  getStepName(stepId) {
    return stepNames[stepId];
  },

  parseRequest(request) {
    return v.parse(RequestSchema, request);
  },

  async writeContractParams(_stepId, { contracts, request }) {
    const collateral = contracts.collaterals[request.collIndex];
    return {
      ...collateral.contracts.StabilityPool,
      functionName: "withdrawFromSP",
      args: [request.ebusdAmount[0], request.claim],
    };
  },
};

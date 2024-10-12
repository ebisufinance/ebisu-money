import type { ComponentType, SVGProps } from "react";

import content from "@/src/content";
import { css } from "@/styled-system/css";
import { AnchorTextButton, IconExternal } from "@liquity2/uikit";
import { a, useInView, useTransition } from "@react-spring/web";

const INFO_ITEMS: Array<[
  ComponentType<SVGProps<SVGSVGElement>>,
  string,
]> = [
  [BoldIcon, `${content.stablecoinName} is always redeemable for $1 worth of protocol collateral, minus a fee.`],
  [RedemptionIcon, "Redemptions are processed against the lowest interest rate positions first."],
  [InterestIcon, "Reduce your chance of redemption by raising your position’s interest rate."],
];

export function RedemptionInfo() {
  const [ref, inView] = useInView({ once: true });

  const iconsTrail = useTransition(
    INFO_ITEMS.map((item) => [...item, inView] as const),
    {
      keys: ([_, text, inView]) => `${text}-${inView}`,
      from: {
        opacity: 0,
        transform: `
          scale3d(0.2, 0.2, 1)
          rotate3d(0, 0, 1, -180deg)
        `,
      },
      enter: {
        opacity: 1,
        transform: `
          scale3d(1, 1, 1)
          rotate3d(0, 0, 1, 0deg)
        `,
      },
      trail: 100,
      delay: 50,
      config: {
        mass: 1,
        tension: 800,
        friction: 60,
      },
    },
  );

  return (
    <section
      className={css({
        display: "flex",
        flexDirection: "column",
        gap: 32,
        padding: 16,
        color: "content",
        background: "surface",
        border: "2px solid token(colors.border)",
        borderRadius: 8,
      })}
    >
      <header
        className={css({
          display: "flex",
          flexDirection: "column",
          fontSize: 16,
        })}
      >
        <h1
          className={css({
            fontWeight: 600,
          })}
        >
          Redemption is not liquidation
        </h1>
        <p
          className={css({
            fontSize: 15,
            color: "contentAlt",
          })}
        >
          Your collateral and debt are reduced by the same amount, without penalty.
        </p>
      </header>

      <ul
        ref={ref}
        className={css({
          display: "grid",
          gridTemplateColumns: "repeat(3, 1fr)",
          gap: 24,
          fontSize: 14,
          "& li": {
            display: "flex",
            flexDirection: "column",
            gap: 16,
          },
        })}
      >
        {iconsTrail((props, [Icon, text], _, index) => {
          return (
            <li key={index}>
              <div
                className={css({
                  display: "flex",
                })}
              >
                <a.div
                  className={css({
                    display: "flex",
                    transformOrigin: "center",
                  })}
                  style={props}
                >
                  <Icon />
                </a.div>
              </div>
              <div>{text}</div>
            </li>
          );
        })}
      </ul>

      <div>
        <AnchorTextButton
          href="https://www.liquity.org/"
          rel="noopener noreferrer"
          target="_blank"
          label={
            <span
              className={css({
                display: "flex",
                alignItems: "center",
                gap: 8,
                color: "accent",
              })}
            >
              <span>
                Learn more about redemptions
              </span>
              <IconExternal size={16} />
            </span>
          }
        >
        </AnchorTextButton>
      </div>
    </section>
  );
}

function BoldIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
      <circle cx="12" cy="12" r="12" fill="#ed3899" />
      <path
        d="M20.2 12.36c-.92.33-1.6 1.09-2.1 1.9-.83 1.36-1.13 2.9-1.13 2.9v-4.8l-3.42 3.42c1.29 0 2.33 1.05 2.33 2.34 0 .75-.37 1.47-.98 1.91-1.23.87-3.05.33-4.16-.48-1.85-1.36-2.48-3.97-1.43-6.04.43-.84 1.1-1.54 1.92-2v3.85c.62-1.86 2.2-3.34 4.25-4.05.42-.15.86-.26 1.32-.33.3-.05.61-.08.92-.08h3.6l2.02-2.03h-2.54l2.65-2.66c-1.85-3.28-5.36-5.5-9.38-5.5-.25 0-.49.01-.73.03 0 0-6.85-3.32-13.3 4 .04-.01 2.09-.64 4.58-.01 0 0 1.3-1.84 4.15-2.6-3.25 1.86-5.44 5.37-5.44 9.39 0 2.84 1.14 5.61 3.13 7.62 3.1 3.13 9 4.64 12.25.88 1.24-1.44 2.8-4.37 5.19-3.98 0 0-3.67-3.68-3.67-3.68zm-.73-7.96c.77-.08 1.41.57 1.34 1.34-.06.57-.52 1.03-1.09 1.09-.77.08-1.41-.57-1.34-1.34.06-.57.52-1.03 1.09-1.09zm-11.55 1.5h6.66l-.51.1c-2.94.57-5.32 2.75-6.15 5.63v-5.73z"
        fill="white"
        transform="scale(0.6) translate(8,8)"
      />
    </svg>
  );
}

function RedemptionIcon() {
  return (
    <svg width="28" height="24" fill="none">
      <path
        fill="#ed3899"
        d="M16 0A12 12 0 0 0 4 12H0l5.334 5.333L10.667 12h-4a9.327 9.327 0 0 1 9.334-9.333A9.327 9.327 0 0 1 25.334 12a9.326 9.326 0 0 1-14.747 7.6l-1.893 1.92A12.002 12.002 0 0 0 27.87 10.24 12 12 0 0 0 16 0Z"
      />
      <circle cx="16" cy="12" r="3" fill="black" />
    </svg>
  );
}

function InterestIcon() {
  return (
    <svg width="20" height="24" fill="none">
      <path
        fill="#ed3899"
        d="M10 0 0 4.364v6.545C0 16.964 4.267 22.625 10 24c5.733-1.375 10-7.036 10-13.09V4.363L10 0Z"
      />
      <circle cx="6" cy="9" r="2" fill="white" />
      <circle cx="14" cy="15" r="2" fill="white" />
      <path fill="white" d="m14.447 6.037 1.414 1.414-10.41 10.41-1.414-1.414z" />
    </svg>
  );
}

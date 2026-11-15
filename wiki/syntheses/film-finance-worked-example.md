---
title: "Film Finance Worked Example and Model"
type: synthesis
status: current
updated: 2026-11-15
as_of: 2026-11-15
source_count: 3
publish: true
description: "Follow a hypothetical film from gross funding and weekly production cash through distribution, senior repayment, equity recoupment and downside analysis."
tags:
  - mediahedge
  - film-finance
---

# Film Finance Worked Example and Model

This hypothetical USD example extends [[wiki/concepts/full-financing|Full Financing]] from closing through investor distributions. It uses one production and one set of assumptions so the finance plan, cash schedule and waterfall reconcile.

## Download and Use the Model

[Download the Excel worked model](https://raw.githubusercontent.com/jongos/mh-wiki/main/assets/downloads/film-finance-worked-model.xlsx). Open it in Excel and edit the blue input cells on **Assumptions**. Select **1** for Base or **2** for Downside. Results, the 24-week production cash schedule and recoupment calculations update from the same inputs.

The model contains four sheets: Results, Assumptions, Production Cash and Recoupment. Amounts and commercial terms are teaching assumptions. It models aggregate post-delivery collections and a cash multiple; it does not calculate dated investor IRR, tax benefits, guild residuals or added borrowing costs from a delay. Add those schedules for a transaction.

## Fund Production Once

| Source | Gross Funding | Fees | Interest Reserve | Net Production Cash |
| --- | ---: | ---: | ---: | ---: |
| Equity | $400,000 | $0 | $0 | $400,000 |
| Presale loan | $450,000 | $30,000 | $30,000 | $390,000 |
| Incentive loan | $250,000 | $20,000 | $20,000 | $210,000 |
| **Total** | **$1,100,000** | **$50,000** | **$50,000** | **$1,000,000** |

The $1 million production uses comprise $900,000 of production and delivery costs and $100,000 of contingency, all assumed spent. Fees and reserves account for the remaining $100,000 of gross uses. The funded interest reserves pay all interest assumed in this example; do not deduct that interest again from collections.

Equity arrives in week 1, the presale loan in week 9 and the incentive loan in week 17. Spending totals $250,000 in weeks 1–8, $450,000 in weeks 9–16 and $300,000 in weeks 17–24, spread evenly within each phase. Funds arrive before that week’s spending. Closing cash stays nonnegative and ends at zero.

## Collect and Apply the Cash

Assume conforming delivery, accepted contracts and collectible proceeds. Presales pay $500,000 and the incentive pays $300,000. These receipts repay financing; they are not a second source of production cash. New sales cover different rights from those presold.

| Cash Bridge | Base | Downside |
| --- | ---: | ---: |
| New sales receipts after buyer/platform shares | $800,000 | $400,000 |
| Distribution fee at assumed 25% | ($200,000) | ($100,000) |
| Approved distribution expenses | ($100,000) | ($100,000) |
| Net new sales receipts | $500,000 | $200,000 |
| Presale receipts | $500,000 | $500,000 |
| Incentive receipts | $300,000 | $300,000 |
| Total producer receipts | $1,300,000 | $1,000,000 |
| Collection fee at assumed 1% | ($13,000) | ($10,000) |
| Senior principal repaid | ($700,000) | ($700,000) |
| **Cash available for equity** | **$587,000** | **$290,000** |

This agreement pools receipts for senior repayment. Actual deals must implement their asset-specific priorities. The distributor’s expenses recover only to the extent receipts after its fee permit; the model displays any unrecovered balance.

## Apply the Equity Waterfall

The assumed terms return investor capital first, then a flat 10% preference on the original $400,000 contribution, followed by a 50/50 split of remaining profit between investor and producer pools.

| Allocation | Base | Downside |
| --- | ---: | ---: |
| Equity capital returned | $400,000 | $290,000 |
| Unreturned equity capital | $0 | $110,000 |
| Preference paid | $40,000 | $0 |
| Investor share of remaining profit | $73,500 | $0 |
| **Total investor distribution** | **$513,500** | **$290,000** |
| Equity cash multiple | 1.28375x | 0.725x |
| Producer profit participation | $73,500 | $0 |

The base allocation reconciles: $13,000 collection fee + $700,000 principal + $513,500 investor distribution + $73,500 producer participation = $1,300,000. The preference is a flat premium, not a 10% annual return. Producer fees already included in production costs are separate from this profit participation.

## Analysis and Inference

The downside also delays the $210,000 incentive loan draw from week 17 to week 21. Production cash falls to negative $60,000 at the end of week 20. A balanced total budget therefore still needs $60,000 of temporary funding or a documented change in spending. The model flags that need without assuming a bridge exists. Any bridge cost further reduces economics.

Read [[wiki/concepts/equity-financing-and-recoupment|Equity Recoupment]] and [[wiki/concepts/distribution-economics|Distribution Economics]] alongside the workbook. Verify the negotiated deduction order, cash dates and investor terms before adapting it.

Links checked: 2026-11-15.

## Continue Exploring

[[MediaHedge Knowledgebase|Home]] · [[wiki/syntheses/producer-financing-route|Producer’s Guide]] · [[wiki/syntheses/financier-diligence-route|Financier’s Guide]] · [[wiki/syntheses/credit-lifecycle|Credit Lifecycle]] · [[wiki/syntheses/site-navigator|Site Navigator]]

<!--
## Source Basis

[[wiki/sources/why-a-production-must-be-fully-financed]] · [[wiki/sources/cama-account-control-and-collection-waterfalls]] · [[wiki/sources/where-the-financiers-return-comes-from]]
-->

---
title: Financing-Partner Return Economics
type: concept
status: needs-review
updated: 2026-10-07
as_of: 2026-09-30
source_count: 8
publish: true
description: Evaluate film-finance returns through actual dated cash flows, fees, duration, prepayment, extensions, defaults, recoveries, expenses and capital utilization.
tags:
  - mediahedge
  - returns
  - xirr
  - economics
---

# Financing-Partner Return Economics

The financier's realized return is the result of actual dated cash flows, not the stated coupon alone. Analysis must incorporate advances, purchase price, fees, principal and interest collections, duration, prepayment, extension, default, nonaccrual, recovery cost, servicing expense and idle-capital or funding effects.

> [!warning] Policy Review Pending
> The qualitative framework was reconciled with current owner-approved underwriting guidance on September 30, 2026. Transaction-specific mandates, numerical assumptions and delegated exception authority still require verification; this page does not certify a financing.

![[assets/diagrams/return-economics-bridge.svg|Conceptual bridge from contractual coupon and fees to realized XIRR and cash multiple]]

*Conceptual view: the bridge identifies economic drivers and does not present forecast or historical MediaHedge returns.*

## Components

1. **Contractual interest:** first establish whether the agreed rate is fixed for the loan or annual. A fixed charge does not accrue again merely because another year passes; apply the actual balance, duration, day-count and payment terms.
2. **Upfront economics:** OID, commitment, closing and structuring fees attributed consistently to net invested capital.
3. **Duration and timing:** draw dates, amortization, prepayment and maturity determine capital velocity.
4. **Stress economics:** extension fees, default interest, nonaccrual, loss and recovery timing change nominal and realized results.
5. **Net portfolio realization:** expected loss, servicing, legal expense, idle cash, leverage and funding cost determine investor-level return.

## Core Metrics

| Metric | Question answered | Limitation |
| --- | --- | --- |
| Principal-weighted coupon | What contractual rate applies to funded exposure? | Does not show timing, loss or cost |
| XIRR | What annualized return follows the actual cash dates? | Can overemphasize early small receipts and assumption-sensitive forecasts |
| Cash multiple | How much cash returned per dollar invested? | Ignores time |
| Expected-loss-adjusted return | What remains after credit, delay, servicing and recovery burden? | Depends on model quality and consistent definitions |

## Calculation Discipline

Build the dated ledger from the financier's perspective: advances, purchase amounts and expenses are negative; principal, interest and fees received are positive. Separate accrued but unpaid interest from cash yield and apply nonaccrual when collectibility is doubtful. Weight portfolio coupon by funded balance and time. Reconcile borrower-level cash through the controlled account, waterfall and investor ledger.

## Governance of Economics

Forward-flow documents should allocate purchase price, coupon, fees, servicing compensation, extension/default economics, expense reimbursement, prepayment and recoveries. Report gross borrower yield, MediaHedge compensation, financier gross return and financier net return separately.

## Gap-Pricing Context

Gap exposure can affect transaction pricing because its value depends on future market realization rather than an existing payment obligation. Pricing is recommended from the complete collateral mix, timing, protections and risk analysis rather than a fixed gap uplift. Current pricing parameters are internal and transaction-specific; they are not reproduced in this public guide and should not be treated as a forecast of financing-partner return. Transaction mix and realized loan-tape evidence require separate verification.

## Limits and Failure Modes

A simple average of loan rates is not a portfolio yield. Upfront fees can inflate annualized return on short assets. Extension or default pricing can increase nominal claims while delay reduces XIRR. Capitalized interest is exposure, not cash. Default interest can be due but uncollectible. Gross yield omits credit loss, legal and servicing cost, funding expense and unused-capital drag.

## Connections

Return measurement depends on the dated evidence produced by [[wiki/concepts/cash-control-and-waterfalls|Cash Control and Waterfalls]] and [[wiki/concepts/monitoring-and-servicing|Monitoring and Servicing]]. [[wiki/concepts/defaults-workouts-and-recoveries|Workouts]] determine stressed cash timing and cost, while [[wiki/concepts/portfolio-construction|Portfolio Construction]] aggregates realized performance and expected loss across risk cohorts.

## Reading the Research Benchmarks

The [2022 revised report](https://filmhedge.com/report-2022-private-credit-insights), pages 23–25, separates reported transaction ROI from a simple annualized illustration. The [2023 revised report](https://filmhedge.com/report-2023-private-credit-insights), pages 26 and 36–38, distinguishes company-reported MPL observations from net fund IRRs and public-market comparisons with different dates. Neither comparison establishes current pricing or a common-period performance ranking; the 2023 opening outperformance assertion conflicts with its qualified addendum.

The [2026 technical study](https://filmhedge.com/report-2026-divergent-correlation) principally measures time to observed payoff. Public theatrical gross and payoff timing are not a dated ledger of lender cash returns. Read the [[wiki/syntheses/filmhedge-research-library|Research Library]] for the edition history and limitations before using any chart as an investment benchmark.

Research links checked: 2026-10-07. Other review dates retain their stated scope.

## Continue Exploring

[[MediaHedge Knowledgebase|Home]] · [[wiki/syntheses/financier-diligence-route|Financier’s Guide]] · [[wiki/syntheses/credit-lifecycle|Credit Lifecycle]] · [[wiki/syntheses/site-navigator|Site Navigator]]

<!--
## Source Basis

- Primary: [[wiki/sources/where-the-financiers-return-comes-from]].
- Related: [[wiki/sources/cama-account-control-and-collection-waterfalls]], [[wiki/sources/defaults-workouts-and-recoveries]], [[wiki/sources/portfolio-construction-and-concentration-risk]] and [[wiki/sources/sales-estimates-and-gap-as-collateral-crash-course]].
-->

<!-- Current qualitative authority: live MediaHedge Brain Underwriting/MH Underwriting.md and Underwriting/Risk and Obligor Scores.md (owner-approved reference, September 25, 2026), and Operations/Lifecycle of a Media Loan.md (owner-approved narrative, September 27, 2026), checked September 30, 2026. This is a scoped reconciliation, not a new raw evidence source or a transaction approval. -->

<!-- Research source basis: [[wiki/sources/filmhedge-private-credit-insights-2022-v2]], [[wiki/sources/filmhedge-private-credit-insights-2023-v2]], [[wiki/sources/filmhedge-divergent-correlation-2026]]. Dated research, not current policy. -->

---
title: Financing-Partner Return Economics
type: concept
status: needs-review
updated: 2026-08-09
as_of: unknown
source_count: 5
publish: true
tags:
  - mediahedge
  - returns
  - xirr
  - economics
---

# Financing-Partner Return Economics

The financier's realized return is the result of actual dated cash flows, not the stated coupon alone. Analysis must incorporate advances, purchase price, fees, principal and interest collections, duration, prepayment, extension, default, nonaccrual, recovery cost, servicing expense and idle-capital or funding effects.

![[assets/diagrams/return-economics-bridge.svg|Conceptual bridge from contractual coupon and fees to realized XIRR and cash multiple]]

*Conceptual view: the bridge identifies economic drivers and does not present forecast or historical MediaHedge returns.*

## Components

1. **Contractual coupon:** accrual on the defined balance under the actual day-count, payment and compounding terms.
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

## Sourced Gap-Pricing Context

The undated gap-collateral brief states that gap inclusion generally contributes approximately three to five percentage points to blended pricing. This is an internal pricing statement, not a current-policy certification or a forecast of financing-partner return. Current pricing authority, transaction mix and realized loan-tape evidence require separate verification.

## Limits and Failure Modes

A simple average of loan rates is not a portfolio yield. Upfront fees can inflate annualized return on short assets. Extension or default pricing can increase nominal claims while delay reduces XIRR. Capitalized interest is exposure, not cash. Default interest can be due but uncollectible. Gross yield omits credit loss, legal and servicing cost, funding expense and unused-capital drag.

## Connections

Return measurement depends on the dated evidence produced by [[wiki/concepts/cash-control-and-waterfalls|Cash Control and Waterfalls]] and [[wiki/concepts/monitoring-and-servicing|Monitoring and Servicing]]. [[wiki/concepts/defaults-workouts-and-recoveries|Workouts]] determine stressed cash timing and cost, while [[wiki/concepts/portfolio-construction|Portfolio Construction]] aggregates realized performance and expected loss across risk cohorts.

## Continue Exploring

[[MediaHedge Knowledgebase|Home]] · [[wiki/syntheses/financier-diligence-route|Financier’s Guide]] · [[wiki/syntheses/credit-lifecycle|Credit Lifecycle]] · [[wiki/syntheses/site-navigator|Site Navigator]]

<!--
## Source Basis

- Primary: [[wiki/sources/where-the-financiers-return-comes-from]].
- Related: [[wiki/sources/cama-account-control-and-collection-waterfalls]], [[wiki/sources/defaults-workouts-and-recoveries]], [[wiki/sources/portfolio-construction-and-concentration-risk]] and [[wiki/sources/sales-estimates-and-gap-as-collateral-crash-course]].
-->

---
title: Financier Return Economics
type: concept
status: current
updated: 2026-08-08
source_count: 4
tags:
  - mediahedge
  - returns
  - xirr
  - economics
---

# Financier Return Economics

## Definition

The financier's realized return is the result of actual dated cash flows, not the stated coupon alone. Analysis must incorporate advances, purchase price, fees, principal and interest collections, duration, prepayment, extension, default, nonaccrual, recovery cost, servicing expense and idle-capital or funding effects.

## Components

1. **Contractual coupon:** accrual on the defined balance under the actual day-count, payment and compounding terms.
2. **Upfront economics:** OID, commitment, closing and structuring fees attributed consistently to net invested capital.
3. **Duration and timing:** draw dates, amortization, prepayment and maturity determine capital velocity.
4. **Stress economics:** extension fees, default interest, nonaccrual, loss and recovery timing change nominal and realized results.
5. **Net portfolio realization:** expected loss, servicing, legal expense, idle cash, leverage and funding cost determine investor-level return.

## Core metrics

| Metric | Question answered | Limitation |
| --- | --- | --- |
| Principal-weighted coupon | What contractual rate applies to funded exposure? | Does not show timing, loss or cost |
| XIRR | What annualized return follows the actual cash dates? | Can overemphasize early small receipts and assumption-sensitive forecasts |
| Cash multiple | How much cash returned per dollar invested? | Ignores time |
| Expected-loss-adjusted return | What remains after credit, delay, servicing and recovery burden? | Depends on model quality and consistent definitions |

## Calculation discipline

Build the dated ledger from the financier's perspective: advances, purchase amounts and expenses are negative; principal, interest and fees received are positive. Separate accrued but unpaid interest from cash yield and apply nonaccrual when collectibility is doubtful. Weight portfolio coupon by funded balance and time. Reconcile borrower-level cash through the controlled account, waterfall and investor ledger.

## Governance of economics

Forward-flow documents should allocate purchase price, coupon, fees, servicing compensation, extension/default economics, expense reimbursement, prepayment and recoveries. Report gross borrower yield, MediaHedge compensation, financier gross return and financier net return separately.

## Limits and failure modes

A simple average of loan rates is not a portfolio yield. Upfront fees can inflate annualized return on short assets. Extension or default pricing can increase nominal claims while delay reduces XIRR. Capitalized interest is exposure, not cash. Default interest can be due but uncollectible. Gross yield omits credit loss, legal and servicing cost, funding expense and unused-capital drag.

## Connections

Return measurement depends on the dated evidence produced by [[wiki/concepts/cash-control-and-waterfalls|Cash Control and Waterfalls]] and [[wiki/concepts/monitoring-and-servicing|Monitoring and Servicing]]. [[wiki/concepts/defaults-workouts-and-recoveries|Workouts]] determine stressed cash timing and cost, while [[wiki/concepts/portfolio-construction|Portfolio Construction]] aggregates realized performance and expected loss across risk cohorts.

## Source basis

- Primary: [[wiki/sources/where-the-financiers-return-comes-from]] and [[raw/sources/MediaHedge_Where_the_Financiers_Return_Comes_From_Financier_Brief.docx]].
- Related: [[wiki/sources/cama-account-control-and-collection-waterfalls]], [[wiki/sources/defaults-workouts-and-recoveries]] and [[wiki/sources/portfolio-construction-and-concentration-risk]].

---
title: Policy and Control Guide
type: synthesis
status: needs-review
updated: 2026-08-29
as_of: unknown
source_count: 11
publish: true
description: Review the control framework governing MediaHedge collateral, sizing, commitment, closing, servicing, exceptions and transaction-level approval.
tags:
  - mediahedge
  - synthesis
  - policy
  - controls
---

# Policy and Control Guide

> [!warning] Evidence Limitation
> This public guide explains the role of MediaHedge's controls without publishing current numeric underwriting limits or pricing parameters. Approved internal policy and transaction documents govern any specific financing.

## Sizing and Exposure Controls

| Control | Public Decision Framework | Purpose |
| --- | --- | --- |
| [[wiki/concepts/tax-credit-collateral\|Tax-credit advance]] | Apply the current asset-specific rule to verified eligible value | Cushions audit, timing, transfer and monetization risk |
| [[wiki/concepts/gap-collateral\|Gap advance]] | Apply the current asset-specific rule to a supported low case | Limits exposure to market-dependent unsold-rights value |
| [[wiki/concepts/gap-collateral\|Gap concentration]] | Apply current concentration-review and approval requirements | Prevents uncertain or correlated value from dominating repayment |
| Aggregate leverage | Apply current approved ceilings to eligible, legally reachable value | Caps total exposure relative to supportable collateral |
| Budget exposure | Apply current approved ceilings without substituting for full financing | Limits lender exposure relative to production uses |
| Term and liquidity | Align maturity, reserves and extension capacity with stressed collection timing | Protects against timing mismatch and liquidity shortfalls |
| [[wiki/concepts/loan-sizing\|Commitment]] | Lowest amount permitted by all applicable constraints | Ensures the tightest structural ceiling controls |

## Non-Quantitative Gates

| Gate | Required finding | Primary evidence | If not satisfied |
| --- | --- | --- | --- |
| [[wiki/concepts/full-financing\|Full financing]] | Verified, timely sources and committed equity cover all uses through delivery, financing costs, reserves and contingency | Executed commitments, funded equity, approved budget, cash-flow schedule, closing statement | Do not close; restructure sources/uses or reduce exposure |
| Eligibility | Collateral is owned, enforceable, supported, non-duplicative and collectible on the modeled timeline | Contracts, schedules, opinions, obligor diligence and valuation evidence | Exclude or haircut; do not cure with price |
| [[wiki/concepts/pre-sales-collateral\|Contracted pre-sale]] | The minimum guarantee is final, authorized, deliverable, collectible and assignable for the eligible net amount | Executed agreement, delivery terms, obligor diligence, accepted assignment and deduction schedule | Exclude conditional or unsupported value; resolve contract and control gaps |
| [[wiki/concepts/gap-collateral\|Gap evidence]] | Unsold rights are owned and available, and the supported low case survives concentration and timing stress | Rights schedule, chain of title, sales-agent authority, territory support, comparable sales and stress model | Exclude unsupported value or reduce the gap component |
| [[wiki/concepts/security-package\|Security and priority]] | Correct grant, perfection, assignment, acknowledgment and control method applies to each asset | Searches, releases, filings, control agreements, recordation and counsel analysis | Hold funding or condition use of proceeds |
| [[wiki/concepts/cash-control-and-waterfalls\|Cash control]] | Every payer and currency has a controlled destination, priority and reconciliation process | Payment directions, CAMA, control agreement, bank onboarding and test reconciliation | Remediate before relying on proceeds |
| [[wiki/concepts/protection-stack\|Completion, surety and insurance]] | Each instrument covers the intended risk, parties and amount, and its conditions align with the approved budget, contract and delivery specification | Policies, endorsements, final guaranties or bonds, underlying contracts and premium evidence | Correct the instrument or remove the credited protection |
| [[wiki/concepts/monitoring-and-servicing\|Monitoring]] | Baseline, data, triggers, authority and continuity are operational at closing | Servicing plan, calendar, data dictionary, consent matrix and custody plan | Do not treat reporting promises as controls |

## Failure-Mode Control Matrix

| Failure mode | Preventive control | Detection signal | Response path |
| --- | --- | --- | --- |
| Budget or schedule overrun | Full financing, contingency, overage allocation, draw control | Cost-to-complete or schedule variance | Pause draw, cure plan, reserve, guarantor action, protective-advance test |
| Delivery dispute | Objective delivery requirements, cure and notice rights | Rejection, missed milestone or aging receivable | Cure, expert/arbitration, preserve contract and claims |
| Tax-credit reduction or delay | Eligible-spend model, haircut, filing covenants | Spend migration, audit finding, missed filing or long-stop variance | Reforecast, reserve, specialist/counsel action, alternate liquidity |
| Obligor nonpayment | Credit diligence, assignment, payment control, setoff analysis | Invoice aging, downgrade, dispute or missed payment | Demand, claim, cure, litigation or settlement |
| Cash diversion | Source mapping, payment direction, controlled account and waterfall | Bank-to-ledger mismatch or unauthorized change | Block account, suspend junior payments, reserve and enforce |
| Collateral shortfall | Conservative sizing and dynamic borrowing base | Coverage or concentration breach | Paydown, additional collateral, reserve, extension, sale or enforcement |
| Servicer failure | Custody, audit, data portability and backup servicing | Service-level breach, missing records or reconciliation failure | Cure, replace servicer, transition data and authority |

## Controls That Cannot Substitute for One Another

- Higher coupon cannot cure ineligible collateral.
- Aggregate LTV cannot cure correlated or legally unreachable value.
- A [[wiki/concepts/cash-control-and-waterfalls|CAMA]] cannot substitute for Article 9 account control.
- A [[wiki/concepts/security-package|UCC filing]] cannot substitute for asset-specific attachment, control, recordation or counterparty rights.
- [[wiki/concepts/production-insurance|Insurance]] cannot substitute for [[wiki/concepts/full-financing|Full Financing]] or a [[wiki/concepts/completion-protection|completion guaranty]].
- A completion guaranty cannot substitute for obligor, [[wiki/concepts/tax-credit-collateral|tax-credit]] or commercial-value underwriting.
- [[wiki/concepts/surety-credit-protection|Surety protection]] cannot substitute for completion, collateral eligibility or compliance with the bonded obligation and claim process.
- More reports cannot substitute for [[wiki/concepts/monitoring-and-servicing|verified evidence, triggers and decision authority]].

## Evidence and Limitations

These controls explain the framework, but they do not certify current thresholds, definitions or delegated exception authority. Review [[wiki/evidence-and-limitations|Evidence and Limitations]] and current approved policy before applying them to a financing decision.

## Continue Exploring

[[MediaHedge Knowledgebase|Home]] · [[wiki/syntheses/financier-diligence-route|Financier’s Guide]] · [[wiki/concepts/loan-sizing|Loan Sizing]] · [[wiki/syntheses/site-navigator|Site Navigator]]

<!--
## Source Basis

Primary: [[wiki/sources/how-mediahedge-sizes-a-loan]], [[wiki/sources/tax-credit-receivables-as-collateral]], [[wiki/sources/why-a-production-must-be-fully-financed]], [[wiki/sources/mediahedge-protection-stack]], [[wiki/sources/mediahedge-security-package]], [[wiki/sources/cama-account-control-and-collection-waterfalls]], [[wiki/sources/monitoring-and-servicing-after-closing]], [[wiki/sources/completion-bonds-crash-course]], [[wiki/sources/surety-bonds-crash-course]], [[wiki/sources/pre-sales-as-collateral-crash-course]] and [[wiki/sources/sales-estimates-and-gap-as-collateral-crash-course]]. Gaps are maintained in [[wiki/operations/research-backlog]].
-->

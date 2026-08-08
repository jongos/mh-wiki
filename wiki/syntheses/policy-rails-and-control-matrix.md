---
title: Policy Rails and Control Matrix
type: synthesis
status: needs-review
updated: 2026-08-08
as_of: unknown
source_count: 7
tags:
  - mediahedge
  - synthesis
  - policy
  - controls
---

# Policy Rails and Control Matrix

## Status

The values below are source-backed statements of current MediaHedge film policy in the ingested briefs. The corpus does not provide a policy version, approval date or effective date. Verify current authority before applying them to a transaction.

## Quantitative rails

| Rail | Stated treatment | Function | Source |
| --- | --- | --- | --- |
| Tax-credit advance | No more than 85% of verified eligible tax-credit value | Cushion for audit, timing, transfer and monetization risk | [[wiki/sources/tax-credit-receivables-as-collateral]] |
| Gap advance | No more than 50% of supported low value | Limits exposure to market-dependent unsold-rights value | [[wiki/sources/how-mediahedge-sizes-a-loan]] |
| Gap concentration | Generally no more than 30% of actual final gross loan | Prevents gap risk from dominating repayment | [[wiki/sources/how-mediahedge-sizes-a-loan]] |
| Aggregate LTV | No more than 60% | Caps total exposure relative to eligible value | [[wiki/sources/how-mediahedge-sizes-a-loan]] |
| Gross loan-to-budget | No more than 80% | Limits lender exposure relative to production budget | [[wiki/sources/how-mediahedge-sizes-a-loan]] |
| Term | Generally no longer than 15 months | Aligns maturity with realistic collection timing and liquidity | [[wiki/sources/how-mediahedge-sizes-a-loan]] |
| Commitment | Lowest amount permitted by all applicable constraints | Ensures the tightest structural ceiling controls | [[wiki/sources/how-mediahedge-sizes-a-loan]] |

## Non-quantitative gates

| Gate | Required finding | Primary evidence | If not satisfied |
| --- | --- | --- | --- |
| Full financing | Verified, timely sources and committed equity cover all uses through delivery, financing costs, reserves and contingency | Executed commitments, funded equity, approved budget, cash-flow schedule, closing statement | Do not close; restructure sources/uses or reduce exposure |
| Eligibility | Collateral is owned, enforceable, supported, non-duplicative and collectible on the modeled timeline | Contracts, schedules, opinions, obligor diligence and valuation evidence | Exclude or haircut; do not cure with price |
| Security and priority | Correct grant, perfection, assignment, acknowledgment and control method applies to each asset | Searches, releases, filings, control agreements, recordation and counsel analysis | Hold funding or condition use of proceeds |
| Cash control | Every payer and currency has a controlled destination, priority and reconciliation process | Payment directions, CAMA, control agreement, bank onboarding and test reconciliation | Remediate before relying on proceeds |
| Insurance/completion | Coverage, endorsements, limits, exclusions and completion obligations align with the approved budget and delivery specification | Policies, endorsements, bond/guaranty and premium evidence | Correct coverage or reduce credited protection |
| Monitoring | Baseline, data, triggers, authority and continuity are operational at closing | Servicing plan, calendar, data dictionary, consent matrix and custody plan | Do not treat reporting promises as controls |

## Failure-mode control matrix

| Failure mode | Preventive control | Detection signal | Response path |
| --- | --- | --- | --- |
| Budget or schedule overrun | Full financing, contingency, overage allocation, draw control | Cost-to-complete or schedule variance | Pause draw, cure plan, reserve, guarantor action, protective-advance test |
| Delivery dispute | Objective delivery requirements, cure and notice rights | Rejection, missed milestone or aging receivable | Cure, expert/arbitration, preserve contract and claims |
| Tax-credit reduction or delay | Eligible-spend model, haircut, filing covenants | Spend migration, audit finding, missed filing or long-stop variance | Reforecast, reserve, specialist/counsel action, alternate liquidity |
| Obligor nonpayment | Credit diligence, assignment, payment control, setoff analysis | Invoice aging, downgrade, dispute or missed payment | Demand, claim, cure, litigation or settlement |
| Cash diversion | Source mapping, payment direction, controlled account and waterfall | Bank-to-ledger mismatch or unauthorized change | Block account, suspend junior payments, reserve and enforce |
| Collateral shortfall | Conservative sizing and dynamic borrowing base | Coverage or concentration breach | Paydown, additional collateral, reserve, extension, sale or enforcement |
| Servicer failure | Custody, audit, data portability and backup servicing | Service-level breach, missing records or reconciliation failure | Cure, replace servicer, transition data and authority |

## Controls that cannot substitute for one another

- Higher coupon cannot cure ineligible collateral.
- Aggregate LTV cannot cure correlated or legally unreachable value.
- A CAMA cannot substitute for Article 9 account control.
- A UCC filing cannot substitute for asset-specific attachment, control, recordation or counterparty rights.
- Insurance cannot substitute for full financing or a completion guaranty.
- A completion guaranty cannot substitute for obligor, tax-credit or commercial-value underwriting.
- More reports cannot substitute for verified evidence, triggers and decision authority.

## Source basis and gaps

Primary sources are [[wiki/sources/how-mediahedge-sizes-a-loan]], [[wiki/sources/tax-credit-receivables-as-collateral]], [[wiki/sources/why-a-production-must-be-fully-financed]], [[wiki/sources/mediahedge-protection-stack]], [[wiki/sources/mediahedge-security-package]], [[wiki/sources/cama-account-control-and-collection-waterfalls]] and [[wiki/sources/monitoring-and-servicing-after-closing]]. Definition and authority gaps are tracked in [[wiki/operations/research-backlog]].

---
title: Protection Stack
type: concept
status: current
updated: 2026-08-09
source_count: 8
publish: true
tags:
  - mediahedge
  - credit
  - protection
---

# Protection Stack

## Definition

The MediaHedge protection stack is a layered credit architecture in which each control addresses a distinct failure mode. It avoids relying on one guaranty, one collateral class, one filing or a high coupon as blanket protection.

## Layers

1. **Eligibility and verification:** only documented, enforceable and independently supported value enters the borrowing base.
2. **Sizing and structural subordination:** advance rates, LTV, concentration, budget limits, reserves and tenor create downside cushion.
3. **Priority and cash control:** grants, perfection, assignments, notices, accounts and waterfalls make collateral reachable and proceeds capturable.
4. **Completion and risk transfer:** full financing, completion protection and production insurance address specified delivery and insured-event risks.
5. **Surveillance and enforcement:** reporting, covenants, triggers, cure rights, step-in powers and remedies preserve options after closing.

## Failure-mode mapping

| Risk | Primary protections |
| --- | --- |
| Failure to finish or deliver | [[wiki/concepts/full-financing|Full Financing]], contingency, completion guaranty and takeover rights |
| Collateral impairment | [[wiki/concepts/loan-sizing|Eligibility and sizing]], assignments, liens, reserves and obligor analysis |
| Cash diversion | Payment directions, [[wiki/concepts/cash-control-and-waterfalls|controlled accounts and waterfall]] |
| Casualty or liability | [[wiki/concepts/production-insurance|Risk-specific insurance]] |
| Deterioration or default | [[wiki/concepts/monitoring-and-servicing|Monitoring]], triggers, cure and [[wiki/concepts/defaults-workouts-and-recoveries|workout governance]] |
| Operational or agency failure | Custody, audit, data portability, reserved matters and replacement servicing |

## Integration rule

The value of the stack depends on consistency across underwriting conclusions, loan documents, interparty arrangements, assignments, completion terms, insurance endorsements and actual bank/account operations. Duplicate documents do not create independent recovery if they rely on the same underlying value or event.

## Limits and common errors

- A completion guaranty does not insure distributor solvency, incentive realization or market performance.
- Production insurance pays only for covered loss under policy terms.
- A lien cannot create value that the borrower does not own.
- Cash control cannot compensate for a collateral shortfall.
- Pricing cannot cure ineligible collateral or a broken enforcement path.
- Correlated sources must be assessed at both transaction and portfolio levels.

## Continue the diligence

[[MediaHedge Knowledgebase|Home]] · [[wiki/syntheses/financier-diligence-route|Financier’s Guide]] · [[wiki/syntheses/credit-lifecycle|Credit Lifecycle]]

<!--
## Source basis

- Primary: [[wiki/sources/mediahedge-protection-stack]].
- Integrated from the related source pages listed in [[wiki/operations/internal-catalog#Source summaries]].
-->

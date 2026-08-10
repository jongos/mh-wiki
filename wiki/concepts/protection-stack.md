---
title: Protection Stack
type: concept
status: current
updated: 2026-08-09
source_count: 10
publish: true
tags:
  - mediahedge
  - credit
  - protection
---

# Protection Stack

The MediaHedge protection stack is a layered credit architecture in which each control addresses a distinct failure mode. It avoids relying on one guaranty, one collateral class, one filing or a high coupon as blanket protection.

![[assets/diagrams/protection-stack.svg|Five-layer MediaHedge protection stack with the distinct risks addressed by each layer]]

*Conceptual view: the layers reinforce one another, but no layer substitutes for a missing eligibility, control or enforcement requirement.*

## Layers

1. **Eligibility and verification:** only documented, enforceable and independently supported value enters the borrowing base.
2. **Sizing and structural subordination:** advance rates, LTV, concentration, budget limits, reserves and tenor create downside cushion.
3. **Priority and cash control:** the [[wiki/concepts/security-package|Security Package]] and [[wiki/concepts/cash-control-and-waterfalls|Cash Control]] make collateral reachable and proceeds capturable through grants, perfection, assignments, notices, accounts and waterfalls.
4. **Completion and risk transfer:** [[wiki/concepts/full-financing|Full Financing]], [[wiki/concepts/completion-protection|Completion Protection]] and [[wiki/concepts/production-insurance|Production Insurance]] address specified delivery and insured-event risks.
5. **Surveillance and enforcement:** reporting, covenants, triggers, cure rights, step-in powers and remedies preserve options after closing.

## Failure-Mode Mapping

| Risk | Primary protections |
| --- | --- |
| Failure to finish or deliver | [[wiki/concepts/full-financing\|Full Financing]], contingency, [[wiki/concepts/completion-protection\|Completion Protection]] and takeover rights |
| Collateral impairment | [[wiki/concepts/loan-sizing\|Eligibility and sizing]], assignments, liens, reserves and obligor analysis |
| Cash diversion | Payment directions, [[wiki/concepts/cash-control-and-waterfalls\|controlled accounts and waterfall]] |
| Casualty or liability | [[wiki/concepts/production-insurance\|Risk-specific insurance]] |
| Specifically bonded payment default | Obligor underwriting and [[wiki/concepts/surety-credit-protection\|Surety or Credit Protection]], if available |
| Deterioration or default | [[wiki/concepts/monitoring-and-servicing\|Monitoring]], triggers, cure and [[wiki/concepts/defaults-workouts-and-recoveries\|workout governance]] |
| Operational or agency failure | Custody, audit, data portability, reserved matters and replacement servicing |

## Integration Rule

> [!note] Important Distinction
> The value of the stack depends on consistency across underwriting conclusions, loan documents, interparty arrangements, assignments, completion terms, insurance endorsements and actual bank/account operations. Duplicate documents do not create independent recovery if they rely on the same underlying value or event.

## Limits and Common Errors

- [[wiki/concepts/completion-protection|Completion protection]] does not insure distributor solvency, incentive realization or market performance.
- [[wiki/concepts/surety-credit-protection|Surety protection]] covers only the specifically bonded obligation and remains subject to claim compliance and its stated limit.
- Production insurance pays only for covered loss under policy terms.
- A lien cannot create value that the borrower does not own.
- Cash control cannot compensate for a collateral shortfall.
- Pricing cannot cure ineligible collateral or a broken enforcement path.
- Correlated sources must be assessed at both transaction and portfolio levels.

## Continue Exploring

[[MediaHedge Knowledgebase|Home]] · [[wiki/syntheses/financier-diligence-route|Financier’s Guide]] · [[wiki/syntheses/credit-lifecycle|Credit Lifecycle]]

<!--
## Source Basis

- Primary: [[wiki/sources/mediahedge-protection-stack]].
- Integrated from related sources including [[wiki/sources/completion-bonds-crash-course]] and [[wiki/sources/surety-bonds-crash-course]], with the broader source set listed in [[wiki/operations/internal-catalog#Source summaries]].
-->

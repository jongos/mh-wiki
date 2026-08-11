---
title: Monitoring and Servicing
type: concept
status: current
updated: 2026-08-09
source_count: 8
publish: true
tags:
  - mediahedge
  - servicing
  - monitoring
---

# Monitoring and Servicing

Servicing is active credit management from first draw through final payoff. It maintains a current view of cost to complete, eligible collateral, cash conversion, covenant status and recovery timing, then links material variance to a defined decision right.

![[assets/diagrams/monitoring-loop.svg|Monitoring loop from the approved baseline through evidence, comparison, diagnosis and decision]]

*Conceptual view: monitoring becomes a control only when verified evidence is assigned to an owner and connected to a decision.*

## Why the Risk Changes

After closing, budget and schedule performance can change, contracts can be amended, obligors can weaken, incentive compliance can fail and collections can slip. Collateral also changes state: production spend becomes an incentive claim, [[wiki/concepts/gap-collateral|unsold rights]] become licenses, delivery makes [[wiki/concepts/pre-sales-collateral|receivables]] due and cash reduces exposure. A static closing model cannot capture those transitions.

## Architecture

1. **Production surveillance:** cost reports, schedules, [[wiki/concepts/completion-protection|completion-guarantor reporting]], contingency and draw controls.
2. **Collateral surveillance:** contracts, obligors, incentive status, rights, valuation, eligibility and concentration.
3. **Cash servicing:** invoices, controlled accounts, waterfalls, remittances and subledger reconciliation.
4. **Covenant and exception control:** breaches, waivers, amendments and expirations logged, aged and escalated.
5. **Investor reporting:** standardized exposure, accrual, maturity, variance, exception and recovery data.

## Baseline-to-Action Loop

At closing, establish the approved budget, schedule, borrowing base, source-to-account map, covenant calendar and expected cash curve. Compare actual evidence at the prescribed cadence. Each exception should show severity, owner, cure date and effect on value, timing and return. Triggers determine whether to pause draws, increase reserves, seek consent, notify a guarantor or obligor, reforecast maturity or begin a workout.

## Investor Control and Continuity

The financing documents should define data fields, frequency, service levels, approval thresholds and reserved matters. Material collateral releases, extensions, principal compromises, enforcement, related-party payments and cash-control changes generally require the agreed investor consent. Complete custody, audit trails, data portability, cyber controls and backup servicing preserve operations after a servicer transition.

## Limits and Failure Modes

Volume is not control. Stale or unaudited reports, percentage-complete measures disconnected from cash, aging that ignores delivery disputes, accrued interest that masks deteriorating XIRR and informal waivers all weaken monitoring. Every unresolved exception needs verified evidence, a responsible owner and an explicit decision consequence.

## Connections

Servicing keeps [[wiki/concepts/full-financing|Full Financing]], [[wiki/concepts/loan-sizing|the borrowing base]] and [[wiki/concepts/cash-control-and-waterfalls|cash control]] current after closing. Material exceptions move into [[wiki/concepts/defaults-workouts-and-recoveries|Defaults, Workouts and Recoveries]] under the authority matrix in [[wiki/concepts/forward-flow-governance|Forward-Flow Governance]].

## Continue Exploring

[[MediaHedge Knowledgebase|Home]] · [[wiki/syntheses/financier-diligence-route|Financier’s Guide]] · [[wiki/syntheses/credit-lifecycle|Credit Lifecycle]] · [[wiki/syntheses/site-navigator|Site Navigator]]

<!--
## Source Basis

- Primary: [[wiki/sources/monitoring-and-servicing-after-closing]].
- Related: [[wiki/sources/cama-account-control-and-collection-waterfalls]], [[wiki/sources/defaults-workouts-and-recoveries]], [[wiki/sources/forward-flow-partnerships-and-financier-governance]], [[wiki/sources/where-the-financiers-return-comes-from]], [[wiki/sources/completion-bonds-crash-course]], [[wiki/sources/pre-sales-as-collateral-crash-course]] and [[wiki/sources/sales-estimates-and-gap-as-collateral-crash-course]].
-->

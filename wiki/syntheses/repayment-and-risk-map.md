---
title: Repayment and Risk Map
type: synthesis
status: current
updated: 2026-08-09
source_count: 12
publish: true
tags:
  - mediahedge
  - synthesis
  - collateral
  - repayment
---

# Repayment and Risk Map

What are the principal repayment and protection paths in the model, how do they differ, and where do they share dependencies?

![[assets/diagrams/repayment-source-map.svg|Conceptual map of repayment and protection sources and their shared dependencies]]

*Conceptual view: these sources do not provide equal protection, and differently labeled assets may still depend on the same economic event.*

## Comparative Map

| Value or protection source | Primary value driver | Principal conditions and risks | Primary controls | What it does not prove |
| --- | --- | --- | --- | --- |
| [[wiki/concepts/pre-sales-collateral\|Contracted pre-sale or platform receivable]] | Enforceable payment obligation | Conforming delivery, acceptance, obligor credit, defenses, setoff, deductions, timing and assignment limits | Contract diligence, NOA/acknowledgment, delivery controls, account routing and aging | That every gross contract amount is eligible or collectible |
| Tax incentive | Qualifying local production activity under a program | Claimant and cost eligibility, audits, filing, assignment restrictions, setoff, recapture, transfer discount and delay | Specialist model, ≤85% advance cap, cost surveillance, counsel, lockbox/control and filing covenants | That an estimate is an issued unconditional receivable |
| [[wiki/concepts/gap-collateral\|Unsold-rights or gap value]] | Future market sale or license value | Completion, delivery, market demand, sales execution, correlation and liquidity | Supported low case, ≤50% advance, generally ≤30% of final gross loan, portfolio limits | That appraisal or sales estimates equal cash |
| Production insurance | Covered physical, personnel, liability or professional event | Policy period, exclusions, warranties, deductibles, sublimits, notice and claims proof | Coverage map, policies and endorsements, premium continuity and claims protocol | Completion, obligor solvency, incentive realization or loan repayment |
| [[wiki/concepts/completion-protection\|Completion guaranty]] | Ability to complete and deliver within covered terms | Fully financed bonded budget, exclusions, guarantor elections, takeover mechanics and claim deadlines | Budget alignment, contingency, guarantor reporting, notice and takeover/claim rights | Distributor payment, tax-credit amount or commercial performance |
| [[wiki/concepts/surety-credit-protection\|Surety or credit protection]] | Specifically bonded payment or performance obligation | Exact obligation, trigger, acceptance, notice, proof, waiting period, penal sum and issuer capacity | Final authenticated instrument, named obligees, aligned contract and claim calendar | Blanket loan repayment, completion, tax-credit validity or market performance |
| Security and controlled cash | Legal and operational access to assets and proceeds | Ownership, attachment, priority, bank control, anti-assignment, competing claims and reconciliation | Asset-specific perfection, assignments, control agreement, CAMA, waterfall and reconciliation | That collateral value exists or is sufficient |

## Shared Dependency: Completion and Delivery

Distributor MGs often become payable only after conforming delivery. Tax incentives require qualifying spend and filings that depend on production execution. Unsold rights are generally more marketable after a completed project exists. [[wiki/concepts/completion-protection|Completion coverage]] itself usually assumes a fully financed approved budget. This makes [[wiki/concepts/full-financing|Full Financing]] the first shared protection rather than a production-management detail.

## Shared Dependency: The Path of Cash

Even sound payment obligations do not protect a lender if proceeds are diverted, commingled, netted or distributed outside the senior priority. [[wiki/concepts/cash-control-and-waterfalls|Cash Control and Waterfalls]] therefore connects the value source to realized repayment through payer mapping, acknowledged instructions, independent administration, bank control and reconciliation.

## Shared Dependency: State Changes After Closing

Collateral changes form over time: production spend becomes an incentive claim, delivery makes contract payments due, new licenses can convert unsold rights into receivables, and collections reduce exposure. [[wiki/concepts/monitoring-and-servicing|Monitoring and Servicing]] must update eligibility, timing, concentration and expected return as those transitions occur.

## Portfolio Implication

Different labels do not guarantee diversification. Several repayment sources can depend on the same delivery event, jurisdiction, obligor, completion guarantor, account bank or sales market. [[wiki/concepts/portfolio-construction|Portfolio Construction]] therefore measures common failure drivers and stressed loss contribution, not merely the count of productions or collateral categories.

## Analysis and Inference

Taken together, the material suggests a useful hierarchy: first preserve the project and legal claim, then preserve the cash path, then measure timing and net realization. No single layer is sufficient, and apparently distinct assets should receive diversification credit only after their shared dependencies are mapped.

## Continue Exploring

[[MediaHedge Knowledgebase|Home]] · [[wiki/syntheses/financier-diligence-route|Financier’s Guide]] · [[wiki/evidence-and-limitations|Evidence and Limitations]]

<!--
## Source Basis

[[wiki/sources/why-a-production-must-be-fully-financed]], [[wiki/sources/how-mediahedge-sizes-a-loan]], [[wiki/sources/tax-credit-receivables-as-collateral]], [[wiki/sources/film-production-insurance-stack]], [[wiki/sources/mediahedge-protection-stack]], [[wiki/sources/mediahedge-security-package]], [[wiki/sources/cama-account-control-and-collection-waterfalls]], [[wiki/sources/portfolio-construction-and-concentration-risk]], [[wiki/sources/completion-bonds-crash-course]], [[wiki/sources/surety-bonds-crash-course]], [[wiki/sources/pre-sales-as-collateral-crash-course]] and [[wiki/sources/sales-estimates-and-gap-as-collateral-crash-course]].
-->

---
title: Loan Sizing
type: concept
status: needs-review
updated: 2026-11-18
as_of: 2026-09-30
source_count: 7
publish: true
description: Learn how eligible collateral value, advance rates, concentration limits, leverage, budget exposure, tenor and liquidity constraints determine loan size.
tags:
  - mediahedge
  - underwriting
  - sizing
  - policy
---

# Loan Sizing

Size a production loan against evidenced repayment sources and the cash needed to complete and deliver the production. Underwriting establishes eligible net value, collateral-specific advances and reserves, then applies approved transaction limits, funding mandates and timing stress. Advance rates, leverage, equity, fees and tenor are transaction assumptions subject to approval, not universal ratios inferred from legacy examples.

> [!tip] Decision Point
> The proposed amount must satisfy all applicable approved limits and completion needs. A concentration-review trigger calls for analysis and an authorized decision; it is not automatically a hard cap or a loan approval.

![[assets/diagrams/loan-sizing-waterfall.svg|Conceptual sizing sequence from collateral evidence through approved limits and human credit review]]

*Conceptual diagram: eligibility, advances, concentration review and approved limits determine the commitment.*

## Sequence

1. **Eligibility:** verify ownership, enforceability, assignment, obligor quality, conditions, deductions, timing and absence of overlap.
2. **Asset-level advance:** apply a haircut appropriate to the asset's certainty and volatility.
3. **Concentration:** assess common failure drivers and distinguish mandatory mandate limits from triggers requiring explicit human review.
4. **Transaction requirements:** apply approved leverage, loan-to-budget and equity requirements; identify whether collateral LTV uses face or discounted value and avoid double deductions.
5. **Term and liquidity:** align maturity with stressed collection timing, required reserves and extension risk.
6. **Full-financing reconciliation:** confirm through [[wiki/concepts/full-financing|Full Financing]] that the sized facility, equity and other sources still fund every use through delivery.

## Policy Application

| Test | Public Decision Framework |
| --- | --- |
| Tax-credit advance | Apply the current asset-specific rule to verified eligible value after program, timing and realization adjustments |
| Gap advance | Apply the current asset-specific rule to a supported low case after rights, market and collection adjustments |
| Gap concentration | Test uncertain and correlated exposure against current concentration-review and approval requirements |
| Aggregate leverage | Apply approved transaction and mandate requirements on a clearly stated collateral valuation base |
| Budget exposure | Compare total exposure with the approved production budget without treating the ratio as a substitute for full financing |
| Term and liquidity | Align maturity, reserves and extension capacity with stressed collection timing |

## Approval and Production Cash

Model base, downside and stress cases before recommending structure and pricing. Assess transaction risk and the payment counterparty separately. The authorized credit decision sets the structure and price, with any required capital-provider consent. In MediaHedge’s framework, Risk Score and Obligor Score inform that decision; MH Score and Tier classify the approved blended rate afterward.

The [[wiki/concepts/full-financing#Worked Finance Plan|Worked Finance Plan]] shows gross and net reconciliation with a timing stress. Gross commitment is not cash available to production. Deduct prepaid interest, fees, reserves and other closing deductions, then reconcile net cash and its timing to remaining uses. A smaller loan does not cure a production funding shortfall unless other verified sources fill it.

## Required Output

A finance expert must reproduce the commitment from the collateral schedule and identify:

- eligible net value by asset;
- permitted exposure by sizing test;
- the binding constraint and remaining cushion;
- the effect of stress on value, timing and principal recovery;
- pricing, transaction risk, counterparty risk and approval status, recorded separately;
- every exception and its approval authority.

## Collateral States Matter

An executed [[wiki/concepts/pre-sales-collateral|pre-sale]] establishes a contractual payment claim; delivery, acceptance and other terms determine when payment becomes due. [[wiki/concepts/gap-collateral|Gap collateral]] begins as market-dependent unsold-rights value and may later convert into receivables as licenses are signed. The two states should not receive the same eligibility assumptions, advance treatment or concentration credit.

## Failure Modes

Aggregate LTV does not protect capital if the value is ineligible, correlated, unreachable or maturing after the loan. Gross loan-to-budget is not a substitute for [[wiki/concepts/full-financing|sources-and-uses sufficiency]]. Fees and capitalized interest can increase exposure after closing. Where a particular mandate imposes a cap calculated against a final loan that itself includes gap, solve that circularity explicitly. Do not turn a concentration-review trigger into such a cap. High pricing cannot cure a failed structural gate.

## What the Credit Research Does Not Change

The [Divergent Correlation study](https://filmhedge.com/report-2026-divergent-correlation), pages 13 and 16–17, illustrates why an observed coefficient cannot become an advance rule.

![[assets/research/study-vintage-adjustment.png|Payoff-hazard estimates before and after origination-vintage adjustment, with wide intervals for grade and blended structure and a noncausal LTV association]]

*Source: FilmHedge + MediaHedge, Divergent Correlation, page 13; analysis September 1, 2026. The modeled cohort has 30 loans and 22 payoff events. Hazard ratios above one mean faster observed payoff, not lower default risk or higher return. Intervals are 95% credible intervals; grade and log LTV effects are per sample standard deviation.*

The grade association becomes approximately neutral after adjustment and the blended estimate changes direction. The higher-LTV association may reflect selection or collateral mix; it does not establish a causal benefit from leverage. Approved sizing remains transaction-specific. See the [[wiki/syntheses/filmhedge-research-library|Research Library]] for cohort and measurement limits.

Research links checked: 2026-10-07.

## Provider Directory

[[wiki/syntheses/film-tv-lenders|Film and TV Finance Lenders]] — public contacts and project-fit guidance.

## Continue Exploring

[[MediaHedge Knowledgebase|Home]] · [[wiki/syntheses/financier-diligence-route|Financier’s Guide]] · [[wiki/syntheses/credit-lifecycle|Credit Lifecycle]] · [[wiki/syntheses/site-navigator|Site Navigator]]

<!--
## Source Basis

- Primary: [[wiki/sources/how-mediahedge-sizes-a-loan]].
- Related: [[wiki/sources/tax-credit-receivables-as-collateral]], [[wiki/sources/why-a-production-must-be-fully-financed]], [[wiki/sources/mediahedge-protection-stack]], [[wiki/sources/pre-sales-as-collateral-crash-course]] and [[wiki/sources/sales-estimates-and-gap-as-collateral-crash-course]].
-->

<!-- Current qualitative authority: live MediaHedge Brain Underwriting/MH Underwriting.md and Underwriting/Risk and Obligor Scores.md (owner-approved reference, September 25, 2026), and Operations/Lifecycle of a Media Loan.md (owner-approved narrative, September 27, 2026), checked September 30, 2026. This is a scoped reconciliation, not a new raw evidence source or a transaction approval. -->

<!-- Research source basis: [[wiki/sources/filmhedge-divergent-correlation-2026]]. Dated research, not current policy. -->

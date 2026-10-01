---
title: Loan Sizing
type: concept
status: needs-review
updated: 2026-09-30
as_of: 2026-09-30
source_count: 6
publish: true
description: Learn how eligible collateral value, advance rates, concentration limits, leverage, budget exposure, tenor and liquidity constraints determine loan size.
tags:
  - mediahedge
  - underwriting
  - sizing
  - policy
---

# Loan Sizing

MediaHedge sizes each loan against evidenced repayment sources and the cash needed to complete and deliver the production. Underwriting establishes eligible net value, collateral-specific advances and reserves, then applies approved transaction limits, funding mandates and timing stress. Advance rates, leverage, equity, fees and tenor are transaction assumptions subject to approval, not universal ratios inferred from legacy examples.

> [!warning] Policy Review Pending
> The qualitative framework was reconciled with current owner-approved underwriting guidance on September 30, 2026. Transaction-specific mandates, numerical assumptions and delegated exception authority still require verification; this page does not certify a financing.

> [!tip] Decision Point
> The proposed amount must satisfy all applicable approved limits and completion needs. A concentration-review trigger calls for analysis and an authorized decision; it is not automatically a hard cap or a loan approval.

![[assets/diagrams/loan-sizing-waterfall.svg|Conceptual sizing sequence from collateral evidence through approved limits and human credit review]]

*Conceptual view: the diagram separates concentration review from approved limits. It shows no transaction data or numerical policy limits.*

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

> [!warning] Evidence Limitation
> The reader website summarizes the controls qualitatively. The intentionally public GitHub repository and its history also contain legacy internal briefs and numerical examples; those are historical evidence, not a statement of current approved policy. Current approved policy and executed transaction documents govern each financing.

## Approval and Production Cash

Model base, downside and stress cases before recommending structure and pricing. Risk Score and the legal-entity- and territory-specific Obligor Score inform the review. Management or an authorized underwriter approves the structure and blended rate, with required capital-provider consent; MH Score and Tier classify that approved rate afterward. A spreadsheet result or counterparty lookup is not approval.

Gross commitment is not cash available to production. Deduct prepaid interest, fees, reserves and other closing deductions, then reconcile net cash and its timing to remaining uses. A smaller loan does not cure a production funding shortfall unless other verified sources fill it.

## Required Output

A finance expert should be able to reproduce the commitment from the collateral schedule and identify:

- eligible net value by asset;
- permitted exposure by sizing test;
- the binding constraint and remaining cushion;
- the effect of stress on value, timing and principal recovery;
- pricing, [[wiki/glossary#M-R|Risk Score, Obligor Score and MH Score]], and approval status as distinct concepts: risk inputs inform human review, while MH Score classifies the approved blended rate;
- every exception and its approval authority.

## Collateral States Matter

An executed [[wiki/concepts/pre-sales-collateral|pre-sale]] can produce a contractual receivable after delivery and acceptance. [[wiki/concepts/gap-collateral|Gap collateral]] begins as market-dependent unsold-rights value and may later convert into receivables as licenses are signed. The two states should not receive the same eligibility assumptions, advance treatment or concentration credit.

## Limits and Failure Modes

Aggregate LTV does not protect capital if the value is ineligible, correlated, unreachable or maturing after the loan. Gross loan-to-budget is not a substitute for [[wiki/concepts/full-financing|sources-and-uses sufficiency]]. Fees and capitalized interest can increase exposure after closing. Where a particular mandate imposes a cap calculated against a final loan that itself includes gap, solve that circularity explicitly. Do not turn a concentration-review trigger into such a cap. High pricing cannot cure a failed structural gate.

## Continue Exploring

[[MediaHedge Knowledgebase|Home]] · [[wiki/syntheses/financier-diligence-route|Financier’s Guide]] · [[wiki/syntheses/credit-lifecycle|Credit Lifecycle]] · [[wiki/syntheses/site-navigator|Site Navigator]]

<!--
## Source Basis

- Primary: [[wiki/sources/how-mediahedge-sizes-a-loan]].
- Related: [[wiki/sources/tax-credit-receivables-as-collateral]], [[wiki/sources/why-a-production-must-be-fully-financed]], [[wiki/sources/mediahedge-protection-stack]], [[wiki/sources/pre-sales-as-collateral-crash-course]] and [[wiki/sources/sales-estimates-and-gap-as-collateral-crash-course]].
-->

<!-- Current qualitative authority: live MediaHedge Brain Underwriting/MH Underwriting.md and Underwriting/Risk and Obligor Scores.md (owner-approved reference, September 25, 2026), and Operations/Lifecycle of a Media Loan.md (owner-approved narrative, September 27, 2026), checked September 30, 2026. This is a scoped reconciliation, not a new raw evidence source or a transaction approval. -->

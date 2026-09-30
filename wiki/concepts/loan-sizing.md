---
title: Loan Sizing
type: concept
status: needs-review
updated: 2026-09-30
as_of: unknown
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

MediaHedge's sizing method is a constraint system. Underwriting first converts headline collateral into eligible net value, then applies asset-specific advance rates, concentration limits, aggregate leverage, budget exposure, tenor and liquidity tests.

> [!tip] Decision Point
> The approved commitment is the lowest amount permitted by every applicable test.

![[assets/diagrams/loan-sizing-waterfall.svg|Conceptual waterfall from headline collateral value to the lowest permitted loan commitment]]

*Conceptual view: the waterfall shows the order of the tests, not transaction data or currently approved policy limits.*

## Sequence

1. **Eligibility:** verify ownership, enforceability, assignment, obligor quality, conditions, deductions, timing and absence of overlap.
2. **Asset-level advance:** apply a haircut appropriate to the asset's certainty and volatility.
3. **Concentration:** limit any single risk component or common failure driver.
4. **Aggregate ceilings:** apply the overall LTV and gross loan-to-budget caps.
5. **Term and liquidity:** align maturity with stressed collection timing, required reserves and extension risk.
6. **Full-financing reconciliation:** confirm through [[wiki/concepts/full-financing|Full Financing]] that the sized facility, equity and other sources still fund every use through delivery.

## Policy Application

| Test | Public Decision Framework |
| --- | --- |
| Tax-credit advance | Apply the current asset-specific rule to verified eligible value after program, timing and realization adjustments |
| Gap advance | Apply the current asset-specific rule to a supported low case after rights, market and collection adjustments |
| Gap concentration | Test uncertain and correlated exposure against current concentration-review and approval requirements |
| Aggregate leverage | Apply current approved ceilings only after collateral eligibility and legal reachability are established |
| Budget exposure | Compare total exposure with the approved production budget without treating the ratio as a substitute for full financing |
| Term and liquidity | Align maturity, reserves and extension capacity with stressed collection timing |

> [!warning] Evidence Limitation
> The reader website summarizes the controls qualitatively. The intentionally public GitHub repository and its history also contain legacy internal briefs and numerical examples; those are historical evidence, not a statement of current approved policy. Current approved policy and executed transaction documents govern each financing.

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

Aggregate LTV does not protect capital if the value is ineligible, correlated, unreachable or maturing after the loan. Gross loan-to-budget is not a substitute for [[wiki/concepts/full-financing|sources-and-uses sufficiency]]. Fees and capitalized interest can increase exposure after closing. A gap cap calculated against a final loan that itself contains gap creates circularity and must be solved and audited explicitly. High pricing cannot cure a failed structural gate.

## Continue Exploring

[[MediaHedge Knowledgebase|Home]] · [[wiki/syntheses/financier-diligence-route|Financier’s Guide]] · [[wiki/syntheses/credit-lifecycle|Credit Lifecycle]] · [[wiki/syntheses/site-navigator|Site Navigator]]

<!--
## Source Basis

- Primary: [[wiki/sources/how-mediahedge-sizes-a-loan]].
- Related: [[wiki/sources/tax-credit-receivables-as-collateral]], [[wiki/sources/why-a-production-must-be-fully-financed]], [[wiki/sources/mediahedge-protection-stack]], [[wiki/sources/pre-sales-as-collateral-crash-course]] and [[wiki/sources/sales-estimates-and-gap-as-collateral-crash-course]].
-->

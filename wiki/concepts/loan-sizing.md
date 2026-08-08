---
title: Loan Sizing
type: concept
status: needs-review
updated: 2026-08-08
as_of: unknown
source_count: 4
tags:
  - mediahedge
  - underwriting
  - sizing
  - policy
---

# Loan Sizing

## Definition

MediaHedge's sizing method is a constraint system. Underwriting first converts headline collateral into eligible net value, then applies asset-specific advance rates, concentration limits, aggregate leverage, budget exposure, tenor and liquidity tests. The approved commitment is the lowest amount permitted by every applicable test.

## Sequence

1. **Eligibility:** verify ownership, enforceability, assignment, obligor quality, conditions, deductions, timing and absence of overlap.
2. **Asset-level advance:** apply a haircut appropriate to the asset's certainty and volatility.
3. **Concentration:** limit any single risk component or common failure driver.
4. **Aggregate ceilings:** apply the overall LTV and gross loan-to-budget caps.
5. **Term and liquidity:** align maturity with stressed collection timing, required reserves and extension risk.
6. **Full-financing reconciliation:** confirm that the sized facility, equity and other sources still fund every use through delivery.

## Current rails stated in the briefs

| Test | Stated MediaHedge treatment |
| --- | --- |
| Tax-credit advance | `<=85%` of verified eligible value |
| Gap advance | `<=50%` of supported low value |
| Gap concentration | Generally `<=30%` of actual final gross loan |
| Aggregate LTV | `<=60%` |
| Gross loan-to-budget | `<=80%` |
| Term | Generally `<=15 months` |

The source corpus does not state an effective date or policy version. Confirm current authority and denominator definitions before applying the rails. See [[wiki/syntheses/policy-rails-and-control-matrix]].

## Required output

A finance expert should be able to reproduce the commitment from the collateral schedule and identify:

- eligible net value by asset;
- permitted exposure by sizing test;
- the binding constraint and remaining cushion;
- the effect of stress on value, timing and principal recovery;
- pricing, risk score and approval status as separate outputs;
- every exception and its approval authority.

## Limits and failure modes

Aggregate LTV does not protect capital if the value is ineligible, correlated, unreachable or maturing after the loan. Gross loan-to-budget is not a substitute for [[wiki/concepts/full-financing|sources-and-uses sufficiency]]. Fees and capitalized interest can increase exposure after closing. A gap cap calculated against a final loan that itself contains gap creates circularity and must be solved and audited explicitly. High pricing cannot cure a failed structural gate.

## Continue the diligence

[[MediaHedge Knowledgebase|Home]] · [[wiki/syntheses/financier-diligence-route|Financier Diligence Guide]] · [[wiki/syntheses/credit-lifecycle|Credit Lifecycle]]

## Source basis

- Primary: [[wiki/sources/how-mediahedge-sizes-a-loan]] and [[raw/sources/MediaHedge_How_MediaHedge_Sizes_a_Loan_Financier_Brief.docx]].
- Related: [[wiki/sources/tax-credit-receivables-as-collateral]], [[wiki/sources/why-a-production-must-be-fully-financed]] and [[wiki/sources/mediahedge-protection-stack]].

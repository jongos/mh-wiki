---
title: How MediaHedge Sizes a Loan
type: source
status: needs-review
updated: 2026-08-08
as_of: unknown
ingested: 2026-08-08
source_file: "[[raw/sources/MediaHedge_How_MediaHedge_Sizes_a_Loan_Financier_Brief.docx]]"
source_hash: FD5D0D32236D413B95FA54510FE738050989BE99D04E845763A733D4655DD83F
source_count: 1
publish: false
tags:
  - mediahedge
  - source
  - sizing
  - policy
---

# How MediaHedge Sizes a Loan

## Scope

Financier brief setting out MediaHedge's constraint-based loan-sizing method and current film-policy rails. The source does not identify its policy effective date or version.

## Key claims

- Contract face values and estimates must be converted into eligible net collateral before they enter the borrowing base.
- Unlike collateral classes receive different advance treatment.
- The smallest ceiling across asset advance, concentration, aggregate leverage, budget, term and liquidity controls determines the commitment.
- The stated rails include aggregate LTV `<=60%`, gross loan-to-budget `<=80%`, term generally `<=15 months`, tax-credit advance `<=85%`, gap advance `<=50%` of supported low value and gap generally `<=30%` of final gross loan.
- Pricing, score, exposure and approval are distinct outputs; yield cannot cure ineligibility.

## Controls and decision points

- remove overlap, unsupported amounts, conditions, offsets and timing mismatches;
- show each sizing test, binding constraint and remaining cushion;
- solve circular gap calculations explicitly;
- reconcile the sized loan to full financing, contingency, reserves, fees and interest;
- document exceptions separately and stress value and timing.

## Limits

The thresholds are MediaHedge controls rather than universal constants. LTV is ineffective when value is correlated or legally unreachable. Fees and capitalized interest can raise post-close exposure. Gross loan-to-budget does not replace the full-financing test.

## Related pages

- [[wiki/concepts/loan-sizing|Loan Sizing]]
- [[wiki/concepts/pre-sales-collateral|Pre-Sales Collateral]]
- [[wiki/concepts/gap-collateral|Gap Collateral]]
- [[wiki/concepts/full-financing|Full Financing]]
- [[wiki/concepts/tax-credit-collateral|Tax-Credit Collateral]]
- [[wiki/syntheses/policy-rails-and-control-matrix|Policy Rails and Control Matrix]]

## Provenance

- Raw source: [[raw/sources/MediaHedge_How_MediaHedge_Sizes_a_Loan_Financier_Brief.docx]]
- Hash: `FD5D0D32236D413B95FA54510FE738050989BE99D04E845763A733D4655DD83F`

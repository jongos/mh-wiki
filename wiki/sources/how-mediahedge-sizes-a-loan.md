---
title: How MediaHedge Sizes a Loan
type: source
status: needs-review
updated: 2026-09-30
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

Financier brief setting out MediaHedge's constraint-based loan-sizing method and historically stated film-policy rails. The source does not identify its policy effective date or version.

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

The source describes these as MediaHedge controls; that historical claim is superseded for current interpretation by the reconciliation below. LTV is ineffective when value is correlated or legally unreachable. Fees and capitalized interest can raise post-close exposure. Gross loan-to-budget does not replace the full-financing test.

## Current Interpretation - September 30, 2026

This summary preserves what the immutable legacy brief states. Its numerical limits or pricing examples are historical source claims, not current universal MediaHedge policy. Owner-approved underwriting guidance dated September 25, 2026 and the lifecycle narrative dated September 27 establish transaction-specific assumptions and mandates, explicit gap concentration review rather than automatic decline, and human approval. The current interpretation is documented in [[wiki/operations/underwriting-refresh-2026-09-30|September Underwriting Reconciliation]].

Reader-safe use: explain collateral evidence, timing, control and qualified transaction review. Do not promote the legacy figures or fixed pricing uplift into reader guidance. The source's effective date remains unknown; its original hash and contents remain unchanged.

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

---
title: Cash Control and Waterfalls
type: concept
status: current
updated: 2026-08-08
source_count: 4
tags:
  - mediahedge
  - collections
  - cama
  - account-control
---

# Cash Control and Waterfalls

## Definition

Cash control is the system that turns a payment obligation into captured and prioritized loan repayment. It combines payer-level directions, independent collection administration, legally effective account control, a contractual waterfall and operational reconciliation.

## Components are distinct

| Component | Primary function |
| --- | --- |
| Notice of assignment / payment direction | Tells each obligor where to pay and may establish notice and cure mechanics |
| CAMA | Appoints the collection account manager and governs receipt allocation and distribution |
| Deposit-account control agreement | Establishes the secured-party relationship with the bank for control/perfection purposes |
| Waterfall | Defines permitted deductions and payment priority |
| Reconciliation | Matches contracts, invoices, bank cash, allocations, distributions and the loan subledger |

No one component substitutes for the others.

## Operating architecture

1. Build a source-to-account matrix by obligor, contract, territory, currency and expected date.
2. Obtain acknowledged directions and restrict unilateral account or instruction changes.
3. Align collection-manager and bank duties with the loan and interparty documents.
4. Model deductions, reserves, payment frequency, senior priority, shortfalls and junior blockers.
5. Distinguish invoiced, received, cleared, allocated and distributed amounts in reconciliation.
6. Escalate mismatches, aging, chargebacks, unauthorized changes and broadly defined deductions.

## Financier rights

The financing partner should be expressly protected in the waterfall and control documents or through a clear agent/collateral-agent structure. Reserved matters commonly include account changes, payment instructions, waterfall amendments, manager replacement, extraordinary deductions, collateral releases and junior distributions during stress.

## Limits and failure modes

Obligors may retain setoff, withholding or deduction rights. Manager exculpation, bank liens, FX, sanctions screening, chargebacks, cyber events and dormant-account rules can delay cash. A CAMA does not automatically create Article 9 control, and legal control without correct payer onboarding does not ensure that money enters the account. Broad senior deductions or third-party claims can leak value before debt service.

## Connections

Cash control operationalizes the [[wiki/concepts/security-package|Security Package]], supplies evidence to [[wiki/concepts/monitoring-and-servicing|Servicing]], and preserves recoveries during [[wiki/concepts/defaults-workouts-and-recoveries|Workout]]. It also provides the dated ledger needed for [[wiki/concepts/financier-return-economics|Return Economics]].

## Continue the diligence

[[MediaHedge Knowledgebase|Home]] · [[wiki/syntheses/financier-diligence-route|Financier Diligence Guide]] · [[wiki/syntheses/credit-lifecycle|Credit Lifecycle]]

## Source basis

- Primary: [[wiki/sources/cama-account-control-and-collection-waterfalls]] and [[raw/sources/MediaHedge_CAMA_Account_Control_and_Collection_Waterfalls_Financier_Brief.docx]].
- Related: [[wiki/sources/mediahedge-security-package]], [[wiki/sources/monitoring-and-servicing-after-closing]] and [[wiki/sources/where-the-financiers-return-comes-from]].

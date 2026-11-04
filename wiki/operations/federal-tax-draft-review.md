---
title: Federal Tax Draft Review Record
type: operations
status: needs-review
updated: 2026-11-04
as_of: 2026-11-04
source_count: 5
publish: false
tags:
  - mediahedge
  - federal-tax
  - draft
---

# Federal Tax Draft Review Record

The initial handoff was draft-only. Jon’s subsequent instruction to ship, review the whole wiki with Mojo, re-index and publish authorizes the reader release. Earlier no-publication statements below describe completed draft stages, not the current authorization. No proprietary Brain content is imported or ingested.

## Pages and Evidence

- [[wiki/operations/drafts/section-168k-film-tv-deductions|Section 168(k) Draft]]: three archived statutory/IRS sources.
- [[wiki/operations/drafts/proposed-federal-film-tv-credit|Federal Credit Proposal Draft]]: two introduced bill snapshots and dated live status checks.
- Sources: [[wiki/sources/irc-section-168-official]], [[wiki/sources/irc-section-181-official]], [[wiki/sources/irs-notice-2026-11]], [[wiki/sources/hr10582-introduced]], [[wiki/sources/s5552-introduced]].

## Congress.gov Observations

Browser review on November 4, 2026: [House overview](https://www.congress.gov/bill/119th-congress/house-bill/10582) showed Introduced, one text, zero amendments, latest action September 24 referral to Ways and Means. [Senate overview](https://www.congress.gov/bill/119th-congress/senate-bill/5552) showed Introduced, one text, zero amendments, latest action September 24 read twice/referral to Finance. The web retrieval tool could not open these pages; actual Chrome page state supplied status verification. This record is an observation, not a downloaded Congress.gov snapshot, and adds no independent raw source count.

## House and Senate Comparison

Compared complete operative text from SECTION 1 onward after stripping HTML tags and normalizing whitespace. Differences: Senate omits the article “a” before qualified opportunity zone in proposed (e)(2)(C)(i)(I) and (f)(2)(C)(i)(I); “Election To transfer” capitalizes To; Senate effective-date parenthesis omits “by” in “as added by subsection (a)”. Rates, thresholds and reviewed mechanisms match. Texts are not byte- or word-identical.

Shared drafting issues: special-route independent-producer references point to (d)(4)(B), while definition is (d)(3)(B); compensation-services definition refers to (A)(i); post-production rural-zone wording includes a dangling “and began”; disaster wording includes “on the of the date”. No correction or favorable interpretation is assumed.

## Review Limits and Release Checklist

- Code pages state currency through October 7, 2026. Check subsequent legislative amendments before reader release or transaction use.
- Notice 2026-11 reliance is conditional. Confirm any later proposed/final regulations and relevant election procedures before filing guidance is published.
- Verify §6418 and general-business-credit mechanics separately before expanding transfer/credit-utilization detail; current draft does not promise refundability or proceeds.
- Professional review needed for ownership, series/episode scope, tax utilization, recapture and federal/state interaction; no return advice is given.
- Confirm bill amendments/status and effective dates again before any future publication. Preserve snapshots additively.
- No public home, navigation, changelog, CSS or JavaScript changed. Source files are public-government evidence; publish:false is not a confidentiality mechanism for a future GitHub push.

## Validation

Local wiki-lint completed November 4, 2026: 90 Markdown files, 74 wiki pages, 1,354 wikilinks, 28 raw sources; zero warnings and one environment error: this current checkout is not registered as an Obsidian vault. No content, linkage, frontmatter or source-hash errors remain. The Obsidian registry and lint rules were not changed to bypass this check.

Local HTML previews generated successfully with PowerShell ConvertFrom-Markdown in ignored .tmp_federal_review. Browser policy blocked file:// navigation; no workaround was attempted, and rendered visual QA remains unverified. Basic generated HTML structure was checked separately. No packages installed.

Git diff --check passed. All new pages have publish:false; existing published notes, CSS/JS and navigation were unchanged. Drafts remain uncommitted for review by choice; no archive sync was performed. No push, publication, deployment, external sharing or Brain ingestion occurred, consistent with the handoff. Keep publish:false until a separate publication decision.

Independent-review repair: the Section 168(k) title is quoted as a YAML scalar. All eight new Markdown frontmatters passed the already-installed js-yaml 4.3.2 parser, including boolean publish:false validation. Repeated content lint returned only the same Obsidian-registration environment error, with zero warnings; git diff --check passed. No additional dependency was installed.

## Mojo Prose Review

Applied the mojo-language skill on November 4, 2026 to both drafts. Removed repeated caveats and commentary about the writing; tightened eligibility, cash-flow and example explanations. Preserved the enacted-versus-introduced distinction, dated status, substantive qualifications and calculations. Removed the overly narrow subsection (c) attribution for the bill's indirect-payment guidance; the bill-level reference remains.

Pre-edit copies remain in ignored `.tmp_federal_mojo/20261104-063056/`. Compared both drafts against those copies: frontmatter, external URLs, wikilinks and numeric-value sets are unchanged. Semantic review covered ownership, eligibility, timing, transition elections, basis interactions, credit routes and hypothetical examples. This is a prose review, not a fresh legal-status verification. Existing HTML previews predate this edit and are not visual validation of the revised text.

Validation: content lint reports the same sole Obsidian-registration environment error, with zero warnings; git diff --check passed. This prose task expressly prohibits commits as well as publication, push, deployment, external sharing and Brain ingestion. All drafts and pre-edit copies remain intact.

## Reader Release Review — November 4, 2026

Both Congress.gov overview pages were rechecked in Chrome: Introduced, one text and no amendments, latest actions September 24, 2026. Official Code links now identify Public Law 119-121 (October 9, 2026) currency. Original snapshots remain immutable. Notice section 6 reliance wording now specifies taxable years beginning before proposed-regulation publication and all eligible property from the first reliance year. Later rules and taxpayer-specific elections must be checked before filing.

The prose review uses the mojo-language skill. It preserves decision-critical distinctions, all raw source bytes, scoped historical verification dates, quotations and transaction-specific qualifications. Source/provenance pages and historical registers were retained where already concise. This is not a new underwriting reconciliation or validation of historical report claims.

## Whole-Wiki Mojo Review Inventory

Reviewed all 74 existing wiki pages: 39 edited and 35 reviewed unchanged. Added two public tax pages. The root home was also edited; it is separate from the wiki-page count. Edits include prose, navigation, source connections and release records. Review-unchanged means the wording was already useful or the dated evidence/maintenance record needed preservation.

| Existing Page | Review Outcome | Reason |
| --- | --- | --- |
| [[wiki/concepts/cash-control-and-waterfalls]] | Edited | Tightened prose while preserving factual scope and qualifications. |
| [[wiki/concepts/completion-protection]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/concepts/defaults-workouts-and-recoveries]] | Edited | Tightened prose while preserving factual scope and qualifications. |
| [[wiki/concepts/financier-return-economics]] | Edited | Tightened prose while preserving factual scope and qualifications. |
| [[wiki/concepts/forward-flow-governance]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/concepts/full-financing]] | Edited | Added relevant federal reading links; existing source basis retained. |
| [[wiki/concepts/gap-collateral]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/concepts/incentive-monetization]] | Edited | Added relevant federal reading links; existing source basis retained. |
| [[wiki/concepts/loan-sizing]] | Edited | Removed redundant date commentary; scoped review dates retained. |
| [[wiki/concepts/monitoring-and-servicing]] | Edited | Removed redundant date commentary; scoped review dates retained. |
| [[wiki/concepts/portfolio-construction]] | Edited | Removed redundant date commentary; scoped review dates retained. |
| [[wiki/concepts/pre-sales-collateral]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/concepts/production-insurance]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/concepts/protection-stack]] | Edited | Tightened prose while preserving factual scope and qualifications. |
| [[wiki/concepts/security-package]] | Edited | Tightened prose while preserving factual scope and qualifications. |
| [[wiki/concepts/surety-credit-protection]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/concepts/tax-credit-collateral]] | Edited | Added relevant federal reading links; existing source basis retained. |
| [[wiki/entities/california-film-incentives]] | Edited | Removed redundant date commentary; scoped review dates retained. |
| [[wiki/entities/georgia-film-incentives]] | Edited | Removed redundant date commentary; scoped review dates retained. |
| [[wiki/entities/illinois-film-incentives]] | Edited | Removed redundant date commentary; scoped review dates retained. |
| [[wiki/entities/louisiana-film-incentives]] | Edited | Removed redundant date commentary; scoped review dates retained. |
| [[wiki/entities/massachusetts-film-incentives]] | Edited | Removed redundant date commentary; scoped review dates retained. |
| [[wiki/entities/mediahedge]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/entities/new-jersey-film-incentives]] | Edited | Removed redundant date commentary; scoped review dates retained. |
| [[wiki/entities/new-mexico-film-incentives]] | Edited | Removed redundant date commentary; scoped review dates retained. |
| [[wiki/entities/new-york-film-incentives]] | Edited | Removed redundant date commentary; scoped review dates retained. |
| [[wiki/evidence-and-limitations]] | Edited | Added the five official federal sources and their scoped review limits. |
| [[wiki/glossary]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/operations/contradictions]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/operations/drafts/proposed-federal-film-tv-credit]] | Edited | Retained original draft and linked its public successor. |
| [[wiki/operations/drafts/section-168k-film-tv-deductions]] | Edited | Retained original draft and linked its public successor. |
| [[wiki/operations/federal-tax-draft-review]] | Edited | Recorded release authority, legal refresh and whole-wiki review method. |
| [[wiki/operations/internal-catalog]] | Edited | Cataloged public successors and retained review history. |
| [[wiki/operations/research-backlog]] | Edited | Preserved historical review queue and recorded ongoing federal follow-up. |
| [[wiki/operations/underwriting-refresh-2026-09-30]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/overview]] | Edited | Tightened prose while preserving factual scope and qualifications. |
| [[wiki/sources/cama-account-control-and-collection-waterfalls]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/sources/completion-bonds-crash-course]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/sources/defaults-workouts-and-recoveries]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/sources/film-production-insurance-stack]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/sources/filmhedge-divergent-correlation-2026]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/sources/filmhedge-private-credit-insights-2022-v2]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/sources/filmhedge-private-credit-insights-2023-v2]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/sources/filmhedge-private-credit-insights-2026]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/sources/filmhedge-us-tax-incentives-2026]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/sources/forward-flow-partnerships-and-financier-governance]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/sources/how-mediahedge-sizes-a-loan]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/sources/hr10582-introduced]] | Edited | Linked public explanation while retaining source bytes, hash and historical currency. |
| [[wiki/sources/irc-section-168-official]] | Edited | Linked public explanation while retaining source bytes, hash and historical currency. |
| [[wiki/sources/irc-section-181-official]] | Edited | Linked public explanation while retaining source bytes, hash and historical currency. |
| [[wiki/sources/irs-notice-2026-11]] | Edited | Linked public explanation while retaining source bytes, hash and historical currency. |
| [[wiki/sources/media-finance-capital-and-risk-landscape]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/sources/mediahedge-knowledgebase-introduction]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/sources/mediahedge-protection-stack]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/sources/mediahedge-security-package]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/sources/monitoring-and-servicing-after-closing]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/sources/portfolio-construction-and-concentration-risk]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/sources/pre-sales-as-collateral-crash-course]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/sources/s5552-introduced]] | Edited | Linked public explanation while retaining source bytes, hash and historical currency. |
| [[wiki/sources/sales-estimates-and-gap-as-collateral-crash-course]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/sources/surety-bonds-crash-course]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/sources/tax-credit-receivables-as-collateral]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/sources/where-the-financiers-return-comes-from]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/sources/why-a-production-must-be-fully-financed]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/syntheses/credit-lifecycle]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/syntheses/filmhedge-research-library]] | Edited | Removed redundant date commentary; scoped review dates retained. |
| [[wiki/syntheses/financier-diligence-route]] | Edited | Tightened prose while preserving factual scope and qualifications. |
| [[wiki/syntheses/media-finance-lending-landscape]] | Edited | Tightened prose while preserving factual scope and qualifications. |
| [[wiki/syntheses/policy-rails-and-control-matrix]] | Reviewed unchanged | Preserved concise wording, provenance and historical review scope. |
| [[wiki/syntheses/repayment-and-risk-map]] | Edited | Removed redundant date commentary; scoped review dates retained. |
| [[wiki/syntheses/site-navigator]] | Edited | Added both federal tax pages to public navigation. |
| [[wiki/syntheses/us-film-tax-incentives]] | Edited | Added relevant federal reading links; existing source basis retained. |
| [[wiki/welcome]] | Edited | Tightened prose while preserving factual scope and qualifications. |
| [[wiki/what-changed]] | Edited | Recorded reader-facing release scope. |

Validation and live deployment results are recorded in the release log after the respective checks complete.

Official Code comparison: normalized full-page text for Sections 168 and 181 at the Public Law 119-121 URLs matches the preserved snapshots except the currency banners (119-120/October 7 to 119-121/October 9). No operative-text change was found. The live observations add no independent raw source count.

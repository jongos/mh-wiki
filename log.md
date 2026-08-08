---
title: MediaHedge Wiki Activity Log
type: operations
status: current
updated: 2026-08-08
source_count: 12
tags:
  - mediahedge
  - log
---

# MediaHedge Wiki Activity Log

Append-only record. New entries go at the end and use the heading pattern defined in [[AGENTS]].

## [2026-08-08] ingest | Initial MediaHedge financier brief corpus

- Sources read: twelve MediaHedge financier briefs covering full financing, loan sizing, collateral, protection, security, cash control, insurance, servicing, workouts, portfolio risk, forward-flow governance and lender economics.
- Raw layer: created canonical snapshots in `raw/sources/` and recorded SHA-256 identifiers in [[raw/manifest]]. Original root copies were left untouched.
- Wiki layer: created source summaries, twelve concept pages, three cross-source syntheses, the MediaHedge entity page, glossary and operating registers.
- Schema layer: created [[AGENTS]] with ingestion, query, contradiction, provenance and lint rules.
- Key decision: quantitative thresholds are labeled as current MediaHedge policy from the source corpus, not as universal film-finance rules.
- Open issues: policy effective dates, governing jurisdictions and empirical portfolio performance require authoritative follow-up; see [[wiki/operations/research-backlog]].
- Lint: passed with 43 Markdown files, 32 wiki pages and 12 raw sources; 0 broken-link, metadata, index, orphan or manifest warnings/errors.

## [2026-08-08] maintenance | Troubleshooting and workflow hardening

- Sources read: no new raw sources; all twelve canonical snapshots remained unchanged and hash-matched.
- Pages updated: corrected the policy-rail description in [[index]], recorded `as_of: unknown` on undated policy pages, added missing synthesis links to two source pages, and added adjacent-concept links to four concept pages.
- Tooling updated: added `tools\wiki-lint.cmd` for Windows execution-policy compatibility and extended the linter to enforce source-to-raw, source-to-concept, source-to-synthesis, source-count, concept-provenance, adjacent-concept and undated-policy metadata rules.
- Schema updated: the ingest workflow now excludes inbox administration files such as `raw/inbox/README.md`.
- Workspace maintenance: initialized Git on `main`, ignored duplicate root Word originals while retaining canonical snapshots, and removed the failed-render temporary workspace after approved elevated cleanup.
- Key decision: undated limits remain source-backed internal policy statements with `needs-review` status, not representations of currently effective policy.
- Open issues: policy authority, effective dates, jurisdictional validation and empirical performance remain tracked in [[wiki/operations/research-backlog]].
- Lint: passed with 43 Markdown files, 32 wiki pages and 12 raw sources; 0 errors and 0 warnings under the strengthened checks.

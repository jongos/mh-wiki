---
title: MediaHedge Wiki Activity Log
type: operations
status: current
updated: 2026-08-08
source_count: 12
publish: false
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

## [2026-08-08] ingest | Welcome to the MediaHedge Knowledgebase

- Source ingested: `MediaHedge_Knowledgebase_Introduction.docx`, SHA-256 `D700584CFDDA0D328A532F603CFCA3F0D68CE8AA4B181254A6EA04E76DFDA840`.
- Source classification: derived orientation artifact, `authority: non-evidentiary`; it summarizes the existing twelve-source corpus and does not increase evidence source counts.
- Raw layer: copied the exact root deliverable to `raw/sources/` without modification and registered it in [[raw/manifest]].
- Wiki layer: created [[wiki/welcome|Welcome to the MediaHedge Knowledgebase]] and [[wiki/sources/mediahedge-knowledgebase-introduction|the derived source page]]; reshaped [[index]] into the primary welcoming home page while preserving the complete content catalog.
- Schema and tooling: added derived-artifact lineage rules to [[AGENTS]] and mechanical enforcement to `tools\wiki-lint.ps1`.
- Document features: editorial cover, reader-focused tour, role-based navigation, protection-stack summary, evidence guide and 18 live `obsidian://` links into the `MH Wiki` vault.
- Document QA: passed 35 structural preset, numbering, page-setup, table-geometry, hyperlink and provenance checks plus a clean accessibility audit. LibreOffice was unavailable and Microsoft Word's PDF exporter stalled, so page-image visual QA could not be completed.
- Open issues: underlying policy effective dates and authority remain unchanged in [[wiki/operations/research-backlog]].
- Lint: passed with 45 Markdown files, 34 wiki pages and 13 raw files; 0 errors and 0 warnings.

## [2026-08-08] maintenance | Financier-first navigation and home-note resilience

- Sources read: the compiled overview, all twelve concept pages, the MediaHedge entity page, three existing syntheses and the twelve evidentiary source-summary pages; no raw snapshots were changed.
- Reader lens: reorganized the entry experience around the questions a financing partner is likely to ask—financeability, repayment, sizing, control, protection, monitoring, recovery, portfolio construction and realized return.
- Page created: [[wiki/syntheses/financier-diligence-route|Financier Diligence Guide]], including five-minute, twenty-minute and full-review paths; eight diligence gates; expected outputs; pause points; and explicit evidence boundaries.
- Navigation updated: added a financier quick start and decision-question map to [[MediaHedge Knowledgebase]], linked the guide from the welcome and overview pages, and added consistent home/guide/lifecycle navigation to all twelve concept pages.
- Compatibility: retained the descriptive Obsidian home note and restored `index.md` as an embedded compatibility alias so links in earlier exports, including the Word welcome guide, continue to resolve.
- Schema, templates and tooling: documented the primary home-note convention in [[AGENTS]], updated concept and synthesis templates, and changed the linter to validate the named home note and financier navigation.
- Key decision: the new guide is a synthesis and navigation layer over the twelve-source corpus; it adds no independent evidence and does not change policy status or source counts.
- Open issues: policy freshness, transaction-specific legal authority, operating thresholds and realized performance evidence remain in [[wiki/operations/research-backlog]].
- Lint: passed with 47 Markdown files, 35 wiki pages and 13 raw sources; 0 errors and 0 warnings.

## [2026-08-09] maintenance | Public-reader architecture and Publish curation

- Sources read: the live home page, public overview, glossary, entity and synthesis pages, all twelve concepts, private source summaries, recent maintenance history and Obsidian Publish guidance; no new evidence was added.
- Manual edits preserved: retained the user's simplified README description and `Getting Started` heading, then added publishing guidance below the existing content.
- Public layer: rewrote [[MediaHedge Knowledgebase]] as a concise reader hub; simplified public titles and language; created [[wiki/evidence-and-limitations|Evidence and Limitations]]; and retained decision-centered navigation across the financing lifecycle.
- Private layer: marked the legacy welcome page, thirteen source-summary pages, operations registers, raw manifest, templates, README, schema, compatibility index and activity log `publish: false`; the 20 public wiki pages and public home are marked `publish: true`.
- Provenance: kept private source links inside non-rendered maintenance comments on public concept and synthesis pages, preserving traceability without displaying raw filenames, hashes or internal registers to readers.
- Catalog and styling: created [[wiki/operations/internal-catalog|Internal Wiki Catalog]] for complete private navigation and added `publish.css` to hide page properties and provide a clean MediaHedge reading style.
- Tooling: extended the linter to enforce public/private flags, full private catalog coverage, public-home coverage, home backlinks, and the absence of visible private links or maintenance terminology on published pages.
- Key decision: the public site is a curated view of the maintained wiki, not a separate source of truth; raw snapshots remained immutable and private.
- Open issues: current policy authority, transaction-specific legal and tax conclusions, operational thresholds and realized performance evidence remain unchanged in [[wiki/operations/research-backlog]].
- Lint: passed with 49 Markdown files, 37 wiki pages and 13 raw sources; 0 errors and 0 warnings. Publish-scope audit found 21 public files, 0 visible private links and 0 visible maintenance-term findings.

## [2026-08-09] lint | Obsidian wikilink syntax and target integrity

- Scope: scanned all 49 Markdown files and interpreted active Obsidian wikilinks as paired `[[target]]`, `[[target|alias]]`, `[[target#heading]]` or block-reference syntax; examples inside inline or fenced code are not treated as live links.
- Manual edits preserved: retained the wording in the home-page and financier-guide tables while repairing their split alias syntax with the table-safe `\|` separator.
- Repairs: consolidated 18 duplicate path/display link pairs into valid aliased links and redirected the legacy welcome page's stale `Source summaries` heading link to [[wiki/operations/internal-catalog#Source summaries]].
- Tooling: extended `tools\wiki-lint.ps1` to reject unmatched, nested, empty and multiline delimiters; empty aliases or anchors; missing or ambiguous files; and missing heading or block references, with file-and-line diagnostics.
- Verification: a temporary malformed-link fixture was correctly rejected, then removed; the clean vault passed with 527 active wikilinks, including 8 heading or block links, 0 errors and 0 warnings.
- Evidence integrity: all 13 immutable raw snapshots remained unchanged and matched the SHA-256 values in [[raw/manifest]].

## [2026-08-09] maintenance | Public home-page banner

- Asset added: copied the supplied 2,318-by-539-pixel MediaHedge JPEG unchanged into `assets/mediahedge-banner.jpg`; the external design original was not modified.
- Page updated: added the banner above the welcome heading in `MediaHedge Knowledgebase.md` using an Obsidian image embed with a 1,000-pixel display-width hint.
- Publish styling: updated `publish.css` so embedded images retain their aspect ratio and scale down to the available page width on smaller screens.
- Evidence impact: presentation-only change; no source snapshot, claim, policy status or source count changed.
- Lint: passed with 528 active wikilinks, 0 errors and 0 warnings; the embedded image target resolves inside the vault.

## [2026-08-09] lint | Markdown-table wikilink aliases

- Root cause: Obsidian alias links use `|`, but an unescaped alias separator inside a Markdown table is parsed as a column boundary; this can display a fragment such as `[[wiki/concepts/full-financing` even though the target file exists.
- Scope: scanned every Markdown table in the vault for active wikilinks containing an unescaped alias separator.
- Repairs: changed 31 aliases across 24 table rows to the table-safe `\|` form in `wiki/syntheses/credit-lifecycle.md`, `wiki/concepts/protection-stack.md` and `raw/manifest.md`; no source snapshot was modified.
- Tooling: added a permanent linter rule that reports the affected file, line and link whenever an unescaped alias separator appears inside a table.
- Verification: a temporary broken-table fixture was correctly rejected and removed; the complete vault then passed with 528 active wikilinks, 0 errors and 0 warnings.

## [2026-08-09] lint | Rendering-oriented repository audit

- Scope: reviewed all 49 Markdown files, 528 active Obsidian links, 15 Markdown tables, the public image asset, frontmatter, headings, code fences, maintenance comments, public/private navigation, filename conventions, Publish styling and all 13 source hashes.
- Confirmed defect: the public glossary used a path-only link that would display the technical filename `cash-control-and-waterfalls`; it now displays the reader-facing label `Cash Control and Waterfalls`.
- Rendering checks added: table discovery with or without outer pipes, table header and row column counts, valid alignment rows, context-correct alias escaping, duplicate heading anchors, balanced code fences and HTML comments, exact path casing and readable public link labels.
- Data-quality checks added: strict UTF-8 decoding, common mojibake and replacement-character detection, NUL detection, lowercase kebab-case wiki filenames, duplicate or malformed frontmatter fields, one-H1-per-page and heading-level continuity.
- Adversarial verification: temporary fixtures for malformed leading- and optional-pipe tables, duplicate headings, unclosed comments, an unclosed code fence and an unlabeled public vault path all failed with file-and-line diagnostics; the fixtures were then removed.
- Repository review: the duplicate Word files in the vault root are byte-identical to their canonical `raw/sources/` snapshots and remain intentionally untouched as documented in `README.md`; no raw source snapshot changed.
- Final result: the normal command launcher and explicit linter both passed with 0 errors and 0 warnings.

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

## [2026-08-09] maintenance | Human-reader visual system

- Scope: reviewed all 21 published Markdown files, 191 visible H1-H3 headings, 15 Markdown tables, the home-page banner and the Obsidian Publish stylesheet from a non-technical financier's perspective.
- Reading hierarchy: standardized visible H1-H3 headings in Title Case, removed shallow definition/question/status headings where the opening paragraph already served that purpose, restored clear introductory copy before the first section and standardized the 20 public wiki-page footers as `Continue Exploring`.
- Visual guidance: added seven purposeful decision, distinction and evidence-limitation callouts without changing their underlying claims or wording.
- Publish styling: expanded `publish.css` into a responsive MediaHedge design system with branded color and typography, a readable content width, a flexible banner, clearer headings and links, scannable tables, navigation-card treatment, dark-mode support, keyboard focus states, mobile layouts and reduced-motion support.
- Templates and schema: updated the concept, entity, synthesis and source-summary templates plus `AGENTS.md` so future pages follow the same reader-presentation conventions.
- Tooling: extended `tools\wiki-lint.ps1` to enforce Title Case, introductory copy, heading spacing, standardized continuation navigation, approved callout semantics and the required responsive, dark-mode, table and accessibility features in `publish.css`.
- Adversarial verification: temporary fixtures for lowercase and malformed headings, missing introductions and navigation, unsupported callouts, non-Title-Case callout titles and unbalanced CSS were all correctly rejected and then removed.
- Evidence integrity: no financial claim, policy rail, source count, publication status or immutable raw source was changed; existing manual prose and the banner asset were preserved.
- Deferred: a final live visual check should be performed after uploading the revised notes and `publish.css` to Obsidian Publish; page-level tables of contents were intentionally omitted to keep short pages uncluttered.
- Lint: passed with 49 Markdown files, 37 wiki pages, 528 active wikilinks, 15 Markdown tables and 13 raw sources; 0 errors and 0 warnings.

## [2026-08-09] maintenance | Investor-facing visual and authority layer

- Scope: reviewed the 21-file public reader experience as an investor-communications and editorial-design system; existing financial explanations, policy status, source counts and manual prose were preserved.
- Original visuals: created nine rights-safe SVG diagrams covering the credit journey, repayment sources, loan sizing, cash control, the protection stack, monitoring, workouts, portfolio concentration and return economics; the credit-journey diagram is used on both the home page and lifecycle page for ten published embeds.
- Page integration: added conceptual-status captions and descriptive display aliases to the home page, two synthesis pages and seven concept pages without removing any existing public prose.
- External context: added six HTTPS links, checked 2026-08-09, to the Uniform Law Commission, U.S. Copyright Office, California Film Commission, Georgia film-incentive program and SEC Investor.gov; the links are presented as current public orientation rather than MediaHedge policy, transaction advice or additional raw evidence.
- Rights decision: did not use celebrity photographs, film stills, posters, studio logos or quotations because no rights-cleared asset was needed to explain the credit model and their use could imply endorsement.
- Publish styling: expanded the theme with full-width editorial image framing, descriptive captions, three-card starting routes, secondary external-context treatment, print protection, explicit page backgrounds, desktop scaling and horizontally scrollable mobile diagrams.
- Visual QA: rendered a representative home page and every SVG in a browser; checked desktop, 390-pixel mobile and dark mode; confirmed zero document-level horizontal overflow, readable diagram scrolling, clean preview-console output and minimum measured text/link contrast of 4.84:1 in light mode and 8.68:1 in dark mode.
- SVG QA: verified all nine XML documents, intrinsic dimensions, view boxes, titles, descriptions, ARIA references, text bounds, internal references and identifier uniqueness; no scripts, external image dependencies, unresolved references or clipped text remained.
- Tooling: extended `tools\wiki-lint.ps1` to validate external-link security, labels and check dates; diagram alternative text and captions; SVG XML, accessibility, intrinsic sizing, safety, references and catalog use; and the responsive CSS features required by the new design.
- Adversarial verification: temporary fixtures produced the expected failures for insecure and unlabeled links, missing check dates, missing diagram descriptions and captions, malformed dimensions, missing accessibility metadata, unsafe SVG content, duplicate identifiers, unresolved references and missing mobile styling; all fixtures and the temporary preview were removed afterward.
- Evidence integrity: no immutable raw source, claim, policy rail, publication flag or `source_count` changed; external links remain contextual and do not increase evidence counts.
- Lint: passed with 49 Markdown files, 37 wiki pages, 538 active wikilinks, 15 Markdown tables, six external links, ten published diagram embeds, nine SVG diagrams and 13 raw sources; 0 errors and 0 warnings.

## [2026-08-09] maintenance | Obsidian Publish vault-root repair

- Diagnosis: the active Obsidian configuration was one directory above the canonical wiki, so Publish treated `MD-wiki` as the vault and deployed files under an incorrect `MH Wiki/` prefix while the notes, wikilinks, assets and `publish.css` were authored relative to `MH Wiki` itself.
- Live evidence: the Publish cache exposed 28 stale prefixed paths, including private source, operations, template and maintenance files; it contained none of the nine SVG diagrams and did not expose a root `publish.css`.
- Configuration repair: added durable Obsidian and existing-site identity settings under the canonical root `.obsidian/`, kept local workspace and plugin state out of version control and disabled Obsidian Sync for this Dropbox-backed vault.
- Recurrence prevention: moved the parent vault's 122-byte `publish.json` to the recoverable backup `publish.parent-vault-disabled.json` and added a linter failure for a missing root Publish configuration, a missing root stylesheet, malformed site identity or a parent directory connected to the same site.
- Documentation: updated the human and agent instructions to require opening and publishing `MH Wiki` itself and to remove stale remote paths beginning with `MH Wiki/` during the next Publish reconciliation.
- Evidence integrity: no public claim, reader page, source count, raw manifest or immutable raw source changed.
- Verification: the enhanced linter passed with 49 Markdown files, 37 wiki pages, 538 active wikilinks, 10 published diagram embeds, nine SVG diagrams, 13 raw sources, 0 errors and 0 warnings.

## [2026-08-09] maintenance | Live Publish verification and vault registration

- Live URL: inspected `https://publish.obsidian.md/mediahdge/`, which redirected to the incorrectly prefixed `MH Wiki/MediaHedge Knowledgebase` path.
- Confirmed symptoms: the public file explorer exposed private folders and maintenance notes, the page displayed both the Publish site title and note H1, and the browser loaded Obsidian's application stylesheet without the custom root `publish.css`.
- Asset status: the MediaHedge banner and credit-journey SVG loaded successfully, confirming that the new media itself was not the cause of the failure.
- Application diagnosis: Obsidian's global registry contained only the parent `MD-wiki` directory, so opening a path inside `MH Wiki` continued to select the parent even after the child configuration was repaired.
- System repair: backed up Obsidian's vault registry, registered `MH Wiki` as its own vault, marked it active, opened it by exact vault ID and confirmed creation of the child vault workspace; the parent remains available but has no Publish site connection.
- Recurrence prevention: extended the linter to require that the canonical wiki root is present in Obsidian's global registered-vault list on Windows.
- Remaining deployment action: reconcile Publish changes from the now-open `MH Wiki` vault so stale remote paths are deleted and the root stylesheet, public notes and assets are uploaded without the `MH Wiki/` prefix.
- Evidence integrity: no reader-facing claim, raw manifest or immutable raw source changed.
- Verification: the parent Publish configuration remained absent after the correctly registered child vault opened; JSON, PowerShell syntax and the complete wiki lint passed with 0 errors and 0 warnings.

## [2026-08-09] maintenance | Live deployment inventory diagnosis

- Live symptom: the root Publish URL displayed only the site welcome placeholder, while the site header still linked to the obsolete prefixed homepage path.
- Exact inventory: the server exposed 22 files instead of the intended 32. It had all 20 public topic pages and the banner, but lacked `MediaHedge Knowledgebase.md`, root `publish.css` and all nine SVG diagrams; private `raw/README.md` was published unexpectedly.
- Root result: the missing homepage explains the blank landing page, the missing stylesheet explains the default appearance and generated filename heading, and the missing diagrams leave nine public page embeds unresolved.
- Tooling: added `tools/publish-audit.ps1` and its Windows launcher to derive the intended public set from frontmatter and asset embeds, read the live Publish inventory and fail with exact missing and unexpected paths.
- Publication policy: clarified that `publish: false` is a MediaHedge selection rule, not an automatic Obsidian security control; a manually selected private file can still be published.
- Vault process repair: found a stale parent-vault process repeatedly recreating its Publish configuration, closed all Obsidian processes, marked only the canonical child vault active, disabled the recreated parent configuration and relaunched by the child's exact vault ID; the parent configuration then remained absent.
- Real-DOM stylesheet repair: inspected Obsidian Publish's rendered wrappers and expanded `publish.css` to hide its generated filename header and apply introductory, card, caption, external-context and continuation treatments through the actual `.el-*` containers.
- Visual verification: rendered a temporary Publish-DOM fixture with the production stylesheet; CSSOM loaded 47 rules, the filename header and frontmatter were hidden, cards formed a three-column grid, captions and context panels styled correctly and no document overflow remained. The fixture and server were removed afterward.
- Remaining deployment action: upload the 11 reported files, remove `raw/README.md`, reset the homepage to root `MediaHedge Knowledgebase` and hide the file explorer, then rerun the live audit.

## [2026-08-09] maintenance | Retroactive version and recovery archive

- Existing history: confirmed an intact, additive 13-commit chain from the initial 2026-08-08 architecture through the live Publish deployment audit; no prior generation needed to be reconstructed or approximated.
- Retroactive milestones: added annotated recovery tags for the initial architecture, financier navigation, rendering integrity, human-reader design, investor visuals and live Publish audit generations.
- Human index: added `VERSION-HISTORY.md` with the recovery locations, every pre-archive generation, milestone mapping and safe file or full-vault restoration instructions.
- Dynamic index: added `tools/wiki-history.ps1` and its Windows launcher so the current commit-and-tag table is generated directly from Git rather than relying on a manually remembered list.
- Archive tooling: added `tools/wiki-archive.ps1` and its launcher to update an independent bare mirror, verify Git object integrity, compare source and mirror heads and optionally create and verify timestamped immutable full-history bundles.
- Operating rules: required additive history, preservation of manual edits, descriptive commits, milestone tags, independent mirror updates and separate-folder restore tests for future wiki work.
- Independent copies: created and Git-verified the OneDrive bare mirror at `MediaHedge-Wiki-Archive.git` plus immutable full-history bundle `MediaHedge-Wiki-20260809-162444.bundle`; source and mirror both resolved to recovery baseline `282c6d8`.
- Restore verification: cloned the mirror into a temporary folder, checked out the original `cfd2a54` generation with its 43 Markdown files, returned to current `282c6d8` and passed the complete wiki lint with 0 errors and 0 warnings.
- Bundle verification: cloned the immutable bundle separately, confirmed its HEAD exactly matched `282c6d8` and confirmed both restored working trees were clean; all temporary test folders were safely removed.

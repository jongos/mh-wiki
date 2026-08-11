---
title: MediaHedge Wiki Activity Log
type: operations
status: current
updated: 2026-08-10
source_count: 17
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

## [2026-08-09] lint | Recovery system redundant diagnostics

- Scope: independently audited the working Git repository, every annotated milestone tag, the OneDrive bare mirror, every full-history bundle, Obsidian vault registration, Publish vault boundaries, the complete wiki lint and all 13 immutable raw-source hashes.
- Repository integrity: full strict Git object verification passed; every milestone tag is annotated and reachable from `main`; source and mirror branch refs, tag refs, main commit and main tree matched exactly.
- Bundle integrity: verified each existing bundle with Git, added an independent SHA-256 sidecar for each, confirmed each bundle's `HEAD` and `main` agree and confirmed every bundled head remains an ancestor of current `main`.
- Restore verification: restored the mirror into an isolated temporary folder, matched its tracked index object-for-object, restored every milestone tag to its expected commit, linted the restored current generation, restored the newest bundle independently and confirmed clean working trees.
- Failure-path verification: proved the archive tool rejects a dirty working tree before creating a backup; separately proved its successful path using a disposable clean repository and disposable bare mirror.
- Tooling: added `tools\wiki-diagnostics.cmd` and `tools\wiki-diagnostics.ps1`; hardened `tools\wiki-archive.ps1` to compare all branch and tag refs and to create and verify bundle checksums; documented both workflows in `README.md`, `VERSION-HISTORY.md` and `AGENTS.md`.
- Live defect found and repaired: Obsidian had recreated the parent `MD-wiki` Publish connection while that vault was open. After Obsidian was closed normally, preserved the configuration under a timestamped disabled filename and set the global registry to parent closed and canonical `MH Wiki` open.
- Evidence integrity: no wiki claim, publication scope, source count, raw manifest entry or immutable raw source changed.

## [2026-08-09] maintenance | GitHub README reader experience

- Scope: redesigned `README.md` as the public GitHub front door for potential financing partners, first-time readers and maintainers.
- Editorial structure: opened with the central film-finance credit question, added role-based reading routes, summarized the connected credit system and organized the major topics around financeability, repayment, exposure, control, protection, downside, governance and return.
- Visual presentation: reused the rights-cleared MediaHedge banner and original conceptual credit-journey SVG; no third-party image, film still, celebrity image, quotation or endorsement was introduced.
- Navigation: replaced Obsidian-only wikilinks in the README with GitHub-native relative Markdown links, added a complete repository map and retained a compact collapsible maintenance section for technical readers.
- Evidence boundaries: preserved the existing educational, policy-status, transaction-document and professional-advice limitations; no new company, policy, performance or market claim was introduced.
- Verification: all 28 local README links resolved, the complete wiki lint passed with 0 errors and 0 warnings and Git formatting checks passed.
- Lint: passed with 50 Markdown files, 37 wiki pages, 538 active wikilinks, 10 diagram embeds, nine SVG diagrams and 13 raw sources; 0 errors and 0 warnings.

## [2026-08-09] maintenance | Vault directory cleanup

- Scope: inventoried tracked, untracked and ignored files; searched for temporary files, editor locks, caches, backups, empty directories, obsolete outputs and unreferenced tooling.
- Duplicate verification: confirmed all 13 Word files at the vault root were byte-identical SHA-256 matches of their canonical snapshots under `raw/sources/` before removal.
- Files removed: deleted the 13 redundant root Word copies and the obsolete one-time `tools/build-knowledgebase-introduction.py` generator, which was unreferenced and would recreate a stale root duplicate rather than safely versioning the immutable derived artifact.
- Documentation: removed the obsolete root-copy ignore rules, documented canonical snapshot placement in `README.md` and removed the stale root-deliverable reference from [[wiki/sources/mediahedge-knowledgebase-introduction]].
- Files retained: preserved Obsidian's ignored appearance and workspace state because the running app actively uses them; retained every canonical source, source-summary page, template, diagram, compatibility page, maintenance tool and recovery artifact because each has a current role.
- Evidence integrity: no canonical file in `raw/sources/`, raw manifest entry, wiki claim, source count or publication setting changed.

## [2026-08-09] maintenance | Public GitHub repository publication

- Authorization: the user explicitly approved publishing the complete repository, including raw Word sources, private maintenance pages and full prior Git history, to a public GitHub repository.
- Remote: connected `origin` to `https://github.com/jongos/mh-wiki.git` while retaining the independent OneDrive bare mirror and checksum-protected bundles as separate recovery copies.
- Initial publication: pushed `main` directly because the target repository was empty, then pushed all nine annotated `wiki-v*` milestone tags; no draft pull request was needed to establish the initial default branch.
- Preflight: confirmed a clean working tree, passed the complete wiki lint and full strict Git object verification, and found zero common credential or private-key patterns across all 17 pre-publication commits.
- Remote verification: GitHub reports the repository as public with default branch `main`; remote `main` exactly matched local commit `266cbd3`, and all nine remote tag refs exactly matched their local annotated tag objects.
- Evidence integrity: publication and maintenance logging did not alter any wiki claim, source count, raw manifest entry or immutable raw source.

## [2026-08-09] maintenance | Persistent GitHub publication workflow

- Persistent instruction: recorded `origin` and `https://github.com/jongos/mh-wiki.git` in `AGENTS.md` as the canonical public GitHub destination for every completed Codex-authored change to tracked wiki files.
- Completion rule: future operations must be logged, linted, committed, mirrored and verified on `origin/main`; authentication or network failures must be reported as an explicit incomplete-publication gap.
- Guarded tooling: added `tools\github-sync.cmd` and `tools\github-sync.ps1` to reject a dirty tree, non-`main` branch, mismatched remote, common credential pattern, lint failure, archive failure or local/remote ref mismatch before reporting success.
- Safety: preserved additive history and prohibited force-pushes, public tag deletion and credential publication; the OneDrive mirror and checksum bundles remain independent recovery copies rather than being replaced by GitHub.
- Documentation: added the public GitHub remote to `README.md` and `VERSION-HISTORY.md` so both human and agent workflows retain the destination.
- Evidence integrity: no wiki claim, publication scope, source count, raw manifest entry or immutable raw source changed.

## [2026-08-09] ingest | Collateral and protection crash courses

- Sources read: `MediaHedge_Completion_Bond_Crash_Course_MHCB-20260808-7F3C (1).docx`, `MediaHedge_Surety_Bond_Crash_Course_MHSB-20260808-C4E7 (1).docx`, `MediaHedge_PreSales_Collateral_Crash_Course_MHPS-20260808-A91D.docx` and `MediaHedge_Sales_Estimates_Gap_Collateral_Crash_Course_MHGE-20260808-D72B.docx`.
- Duplicate and integrity check: all four SHA-256 values were absent from the existing manifest; canonical copies were added under `raw/sources/` and rehashed byte-for-byte after copying.
- Document review: inspected every paragraph, list, table, header, footer, relationship, note/comment, tracked-change marker and embedded-media part. Each source contains 33 top-level content blocks, one comparison table, two page-specific headers/footers and no embedded media, external relationships, comments or tracked changes.
- Visual-review limitation: LibreOffice was unavailable and Word's hidden read-only exporter did not complete while an existing Office session was active. The originals were untouched, the hidden task-created processes were closed and the document skill's complete structural fallback was used; temporary review artifacts were removed.
- Source layer: created four private provenance pages for completion bonds, surety bonds, pre-sales collateral and sales-estimate/gap collateral, each linked to its immutable snapshot and recorded hash.
- Reader layer: created [[wiki/concepts/completion-protection]], [[wiki/concepts/surety-credit-protection]], [[wiki/concepts/pre-sales-collateral]] and [[wiki/concepts/gap-collateral]] with decision-focused explanations, comparison tables, evidence limits and existing rights-cleared conceptual diagrams.
- Integration: updated the public home, GitHub README, overview, glossary, MediaHedge entity, credit lifecycle, financier guide, repayment map, policy guide and related underwriting, protection, security, cash-control, servicing, portfolio and return pages; updated the private catalog, source pages, research backlog and contradictions register.
- Key distinctions: preserved completion, production-insurance and surety functions as separate; preserved executed pre-sales as conditional contracted receivables and gap as market-dependent unsold-rights value; did not treat repeated internal rails as independent proof of current policy.
- Freshness: marked the gap policy and pricing statements `needs-review` because the briefs provide no policy version, approving authority or effective date. The source-stated three-to-five-point pricing context is not represented as a forecast of realized return.
- Contradictions and gaps: no direct contradiction was found. Added verification needs for current gap pricing, completion and surety forms, pre-sale eligibility and sales-estimate review standards.
- Lint: passed with 58 Markdown files, 45 wiki pages, 745 active wikilinks, 23 Markdown tables, 14 published diagram embeds, nine SVG diagrams and 17 raw sources; 0 errors and 0 warnings.

## [2026-08-09] maintenance | Semantic knowledge-map and credibility pass

- Scope: reviewed all 24 published wiki pages as one knowledge graph, checked high-value concept mentions against their outbound links, inspected contextual overlap and compared the reader routes, glossary, control matrix and repayment map for navigation gaps.
- Knowledge mapping: added 39 unique published-page relationships, bringing the public graph to 25 home-and-page nodes and 288 unique directed edges; every public page is reachable from the home note, and every durable concept retains direct Home, Financier's Guide and Credit Lifecycle navigation.
- Reader improvements: repaired the underlinked tax-credit path, connected the glossary and policy matrix to their durable concept pages, and added targeted links among full financing, collateral states, protection, security, cash control, monitoring, portfolio construction and realized economics.
- Overlap review: found no exact repeated long sentence across published pages. Retained the overview, financier route, lifecycle, repayment map and policy guide as distinct reader lenses rather than merging decision, chronological, repayment and control views.
- External context: supplemented Completion Protection, Surety and Credit Protection, Pre-Sales Collateral and Gap Collateral with official Screen Australia, NAIC and U.S. Treasury context checked on 2026-08-09.
- Evidence boundary: external examples are labeled as general or jurisdiction-specific context and do not validate MediaHedge policy, issuer eligibility, collateral value, pricing, coverage or transaction terms; no source count, raw manifest entry or immutable source changed.
- Open issues: the existing current-policy, transaction-form, legal, jurisdictional and realized-performance verification items remain in the research backlog; no new contradiction was identified.
- Verification: complete wiki lint passed with 58 Markdown files, 45 wiki pages, 823 active wikilinks, 23 tables, 14 external links, 14 published diagram embeds, nine SVG diagrams and 17 raw sources; 0 errors and 0 warnings.

## [2026-08-10] maintenance | Custom domain and Publish inventory repair

- Cloudflare: verified the apex `mediafinance.guide` CNAME targets `publish-main.obsidian.md`, remains proxied, and uses Full SSL/TLS mode; added the matching proxied `www` CNAME and an active path-preserving 301 redirect from `www.mediafinance.guide/*` to `mediafinance.guide/*` with query strings preserved.
- Obsidian Publish: enabled Obsidian's local command interface, retained the existing custom-domain redirect from `publish.obsidian.md/mediahdge`, and changed the site homepage from the obsolete nested `MH Wiki/MediaHedge Knowledgebase.md` path to the canonical root `MediaHedge Knowledgebase.md` note.
- Remote cleanup: compared Obsidian's authoritative 70-file inventory with the local publication policy, then unpublished exactly 34 obsolete paths: the duplicated `MH Wiki/` tree and two private raw-layer README files. No local wiki file, raw source or Git history was deleted.
- Prevention: added `publish: false` to `raw/README.md` and `raw/inbox/README.md`, eliminating both from Obsidian's change queue and preventing accidental republication; added the canonical live-domain link to the repository README.
- Verification: Obsidian reports 36 published files and no pending Publish changes; the live Publish audit reports 36 expected, 36 remote, 0 missing and 0 unexpected/private paths. Final DNS, HTTPS, redirect, wiki lint, archive, GitHub and live-link checks follow this logged operation.

## [2026-08-10] ingest | Media finance capital and risk landscape

- Source read: `MediaHedge_Media_Finance_Lending_Landscape_Financier_Brief.docx`; SHA-256 `2CF1FA25FCF4531DA92035D64475BC2560C2771C674044DBE3CCE3295CD3D7B3` was absent from the manifest before ingest and matched the new immutable snapshot byte for byte after copying.
- Document review: inspected all 126 body paragraphs, 12 tables, header, footer, 34 external hyperlink relationships and package metadata; the source contains no embedded media, comments, tracked insertions or tracked deletions.
- Visual-review limitation: the bundled renderer could not run because LibreOffice is not installed, Word's background exporter stalled on the generated file and Windows-app automation was unavailable. The original remained untouched, task-created Word processes were closed and the complete structural fallback was used.
- Source layer: added [[wiki/sources/media-finance-capital-and-risk-landscape]] and registered the raw snapshot with its explicit August 10, 2026 market-map cutoff.
- Reader layer: added [[wiki/syntheses/media-finance-lending-landscape]] as a dated, role-based guide to banks, specialty project lenders, institutional private credit, production insurers, completion guarantors and targeted credit or surety providers.
- Integration: added the landscape to the public home, GitHub README, overview, financier guide, credit lifecycle, glossary, evidence guide and legacy welcome; strengthened completion, production-insurance, surety, protection-stack and security pages around legal-entity and risk-carrier identification.
- Current-source review: checked representative bank, lender, insurer and completion-platform claims against current official provider pages; checked the Fifth Third/Comerica and Allianz/Arch transactions against official releases and treated the Film Finances/Media Guarantors combination as dated trade-reported context.
- Contradictions and gaps: no direct conflict with the prior sixteen-brief corpus was found. Added scope controls for service brand versus legal counterparty and legacy versus combined platforms, plus research needs for current mandates, vehicles, capacity, authority, claims responsibility and conflicts.
- Publication: deployed exactly 12 reader-facing files through the canonical `MH Wiki` vault. Obsidian then reported no pending Publish changes; the live inventory audit found 37 expected and 37 remote files with 0 missing and 0 unexpected or private paths, and the new custom-domain route returned HTTP 200.
- Verification: complete wiki lint passed with 60 Markdown files, 47 wiki pages, 886 active wikilinks, 27 Markdown tables, 44 external Markdown links, 14 published diagram embeds, nine SVG diagrams and 18 raw sources; 0 errors and 0 warnings.

## [2026-08-10] maintenance | Incremental reader-design and table-readability pass

- Scope reviewed: inspected the live home page and [[wiki/syntheses/media-finance-lending-landscape]] at desktop and narrow-screen widths, compared the rendered Obsidian Publish DOM with `publish.css` and reviewed table, heading, callout, navigation and sidebar behavior.
- Table readability: reduced cell typography to a legible compact scale, tightened padding and line height, enabled tabular numerals, restored natural word wrapping and assigned controlled minimum widths by column count. Two-column tables remain fluid; denser comparisons scroll horizontally only when the viewport requires it.
- Reading canvas: set the Obsidian Publish page-width variable at the platform's actual container scope and hid the illegible interactive graph at constrained desktop widths, preserving the graph on wider screens while giving standard four-column comparisons room to fit.
- Visual polish: balanced heading wraps, clarified the active navigation item, added visible keyboard focus in the file navigation and styled table captions and scrollbars consistently with the existing MediaHedge palette.
- Publish safety repair: diagnostics found that the parent `MD-wiki` vault had reconnected to the same Publish site and created 37 prefixed duplicate paths. Preserved its identity as a timestamped disabled backup, unpublished exactly the verified `MH Wiki/` duplicate set from the parent context and reloaded that vault without force-closing Obsidian or deleting local files.
- Evidence integrity: no wiki claim, source count, raw manifest entry, immutable source, public note content or core navigation meaning changed.
- Verification: final wiki lint passed with 60 Markdown files, 47 wiki pages, 889 wikilinks, 27 tables, 44 external links, 14 published diagram embeds, nine SVGs and 18 raw sources; 0 errors and 0 warnings. Obsidian reported zero pending Publish changes, and the live audit found 37 expected and 37 remote files with 0 missing and 0 unexpected or private paths.

## [2026-08-11] maintenance | Standalone Site Navigator

- Scope: created [[wiki/syntheses/site-navigator]] as a dedicated visual-navigation page while preserving the existing responsive sidebar behavior on every other published page.
- Knowledge graph: linked the navigator to all 26 existing public knowledge pages so Obsidian's native local graph presents the public wiki as a connected, reader-selectable map rather than an isolated page neighborhood.
- Reader fallback: included a collapsed, categorized directory for narrow screens and readers who prefer text navigation; described graph edges as conceptual and navigational rather than risk, priority or economic weights.
- Presentation: added page-scoped desktop styling that restores and enlarges the native Obsidian Publish graph only when the `Site Navigator` page is open; no global table, sidebar or reading-width behavior changed.
- Navigation: added the Site Navigator to the public welcome page and private internal catalog.
- Publish safety: the redundant check detected that the parent `MD-wiki` vault had recreated the same Publish identity; preserved that configuration as `publish.json.disabled-20260811-site-navigator` before deployment so prefixed duplicate paths could not return.
- Evidence integrity: no company, policy, transaction, legal, market, performance or source claim changed; no raw source, source count or immutable snapshot changed.
- Verification: complete lint passed with 61 Markdown files, 48 wiki pages, 921 active wikilinks, 27 tables, 44 external links, 14 published diagram embeds, nine SVGs and 18 raw sources; 0 errors and 0 warnings. Obsidian published the new page, welcome-page link and stylesheet; the live audit found 38 expected and 38 remote files with 0 missing and 0 unexpected paths. Rendered checks confirmed a 420-pixel interactive graph panel at a 1280-pixel viewport and the linked-directory fallback with the graph hidden at 1000 pixels.

---
publish: false
---

# MediaHedge Knowledge Wiki

This vault is a persistent, source-grounded knowledge base for MediaHedge's media credit model.

## Getting Started

1. Open [[MediaHedge Knowledgebase]] for the welcoming home page and complete content map.
2. If you are evaluating the model as a financier, follow [[wiki/syntheses/financier-diligence-route|the Financier Diligence Guide]].
3. Read [[wiki/welcome|Welcome to the MediaHedge Knowledgebase]] for a friendly guided tour.
4. Read [[wiki/overview]] for the executive-level synthesis.
5. Use [[wiki/syntheses/credit-lifecycle]] to follow a loan from screening through recovery.
6. Use [[wiki/syntheses/policy-rails-and-control-matrix]] for source-stated quantitative guardrails and their verification status.
7. Read [[AGENTS]] before asking an LLM to ingest, update, query or lint the wiki.

## Architecture

- `raw/` contains immutable source snapshots and the source manifest.
- `wiki/` contains LLM-maintained knowledge pages: sources, concepts, entities, syntheses and operating registers.
- `templates/` contains page templates.
- `tools/` contains local health-check utilities.
- `AGENTS.md` defines the rules an LLM must follow.
- `MediaHedge Knowledgebase.md` is the public welcome and reader navigation hub; `index.md` preserves older links.
- `wiki/operations/internal-catalog.md` is the complete private content catalog.
- `log.md` is the append-only activity history.

The original Word briefs present in the vault root at initial setup were left untouched. Canonical ingestion snapshots are stored in `raw/sources/` and identified by SHA-256 in [[raw/manifest]].

The vault is initialized as a Git repository on `main`. Markdown, tools and canonical raw snapshots are trackable; the duplicate pre-architecture Word files at the vault root are intentionally ignored.

## Obsidian Publish

- Open `MH Wiki` itself as the Obsidian vault. Do not open its parent `MD-wiki` folder: the notes, links, assets and `publish.css` are all vault-relative to `MH Wiki`.
- The tracked `.obsidian/publish.json` connects this correctly rooted vault to the existing Publish site; local window and plugin state remain ignored.
- Reader-facing notes use `publish: true`; private evidence and maintenance notes use `publish: false`.
- Set `MediaHedge Knowledgebase.md` as the Publish homepage.
- Publish the root `publish.css`, all `publish: true` notes and their files under `assets/`.
- In **Publish changes**, remove the stale remote paths beginning with `MH Wiki/`. Those paths came from publishing the parent folder and include private maintenance material. The replacement files must appear without an `MH Wiki/` prefix.
- Keep the Publish file explorer hidden or hide the internal folder tree; the home page provides the intended navigation.
- Treat `publish: false` as the wiki's publication policy, not an automatic Obsidian security control: Obsidian will still publish a private file if it is manually selected. Review **Add linked** results and keep private Markdown and root Word originals unselected.
- A complete deployment contains 32 files: 21 public Markdown notes, `publish.css`, the banner and nine SVG diagrams. Run `tools\publish-audit.cmd` after publishing to compare the live inventory with that intended set.

## Normal workflows

- **Ingest:** place a source in `raw/inbox/`, then ask the LLM to ingest it.
- **Query:** ask against the wiki; answers should identify the pages and raw sources supporting material claims.
- **File an answer:** tell the LLM to save a useful analysis into the appropriate concept or synthesis page.
- **Lint:** ask the LLM to health-check the wiki, or run `tools\wiki-lint.cmd` on Windows. The launcher applies the local PowerShell execution-policy bypass required on this machine.

This wiki is a credit-analysis aid, not legal, tax, accounting or investment advice. Transaction documents, current program rules and qualified professional review control.

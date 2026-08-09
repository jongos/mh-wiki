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

- Reader-facing notes use `publish: true`; private evidence and maintenance notes use `publish: false`.
- Set `MediaHedge Knowledgebase.md` as the Publish homepage.
- Publish `publish.css` with the reader-facing notes.
- Keep the Publish file explorer hidden or hide the internal folder tree; the home page provides the intended navigation.
- Review the selection before using **Add linked**. Private Markdown is excluded by property, while root Word originals should remain unselected.

## Normal workflows

- **Ingest:** place a source in `raw/inbox/`, then ask the LLM to ingest it.
- **Query:** ask against the wiki; answers should identify the pages and raw sources supporting material claims.
- **File an answer:** tell the LLM to save a useful analysis into the appropriate concept or synthesis page.
- **Lint:** ask the LLM to health-check the wiki, or run `tools\wiki-lint.cmd` on Windows. The launcher applies the local PowerShell execution-policy bypass required on this machine.

This wiki is a credit-analysis aid, not legal, tax, accounting or investment advice. Transaction documents, current program rules and qualified professional review control.

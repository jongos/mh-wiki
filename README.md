# MediaHedge Knowledge Wiki

This vault is a persistent, source-grounded knowledge base for MediaHedge's film-finance credit model. It follows the LLM-maintained wiki pattern described in [Karpathy's LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f): immutable raw sources feed an interlinked Markdown wiki governed by an explicit operating schema.

## Start here

1. Open [[index]] for the welcoming home page and complete content map.
2. Read [[wiki/welcome|Welcome to the MediaHedge Knowledgebase]] for a friendly guided tour.
3. Read [[wiki/overview]] for the executive-level synthesis.
4. Use [[wiki/syntheses/credit-lifecycle]] to follow a loan from screening through recovery.
5. Use [[wiki/syntheses/policy-rails-and-control-matrix]] for source-stated quantitative guardrails and their verification status.
6. Read [[AGENTS]] before asking an LLM to ingest, update, query or lint the wiki.

## Architecture

- `raw/` contains immutable source snapshots and the source manifest.
- `wiki/` contains LLM-maintained knowledge pages: sources, concepts, entities, syntheses and operating registers.
- `templates/` contains page templates.
- `tools/` contains local health-check utilities.
- `AGENTS.md` defines the rules an LLM must follow.
- `index.md` is the content-oriented catalog.
- `log.md` is the append-only activity history.

The original Word briefs present in the vault root at initial setup were left untouched. Canonical ingestion snapshots are stored in `raw/sources/` and identified by SHA-256 in [[raw/manifest]].

The vault is initialized as a Git repository on `main`. Markdown, tools and canonical raw snapshots are trackable; the duplicate pre-architecture Word files at the vault root are intentionally ignored.

## Normal workflows

- **Ingest:** place a source in `raw/inbox/`, then ask the LLM to ingest it.
- **Query:** ask against the wiki; answers should identify the pages and raw sources supporting material claims.
- **File an answer:** tell the LLM to save a useful analysis into the appropriate concept or synthesis page.
- **Lint:** ask the LLM to health-check the wiki, or run `tools\wiki-lint.cmd` on Windows. The launcher applies the local PowerShell execution-policy bypass required on this machine.

This wiki is a credit-analysis aid, not legal, tax, accounting or investment advice. Transaction documents, current program rules and qualified professional review control.

---
publish: false
---

# MediaHedge Wiki Version History and Recovery

This is the human recovery index for the MediaHedge wiki. Git is the authoritative version store. The separate mirror and immutable bundle copies make recovery possible even if the working vault or its `.git` directory is damaged.

## Recovery Locations

| Copy | Location | Purpose |
| --- | --- | --- |
| Working repository | Local working vault (cloned repository root) | Current editable vault and complete Git history. |
| Bare mirror | Off-repository bare mirror | Independent Git database containing every branch, tag and commit. |
| Immutable bundles | Off-repository bundle directory | Timestamped, single-file full-history backups with separate SHA-256 checksum records for major milestones. |
| Public GitHub remote | `https://github.com/jongos/mh-wiki` | Canonical off-device collaboration remote; `origin/main` must match every completed Codex-authored wiki operation. |

The archive update reports the resolved mirror location locally. The archive tools resolve the current Windows Documents folder and accept explicit archive and bundle paths; keep machine-specific recovery notes outside this public repository. Historical commits retain the old paths because recovery history is additive.

## Retroactive Generation Index

| Generation | Commit | Date | Recoverable State |
| --- | --- | --- | --- |
| `wiki-v0.1-initial` | `cfd2a54` | 2026-08-08 | Initial source-grounded MediaHedge LLM wiki architecture. |
| Introduction | `ea39115` | 2026-08-08 | Welcoming knowledgebase introduction added. |
| `wiki-v0.2-financier-navigation` | `f44cdb4` | 2026-08-08 | Financier-first navigation and decision route. |
| Public curation | `b16e348` | 2026-08-09 | Non-technical public reader layer separated from private maintenance. |
| Link validation | `d3a96f1` | 2026-08-09 | Complete Obsidian wikilink validation. |
| Banner | `459ce31` | 2026-08-09 | MediaHedge banner integrated into the home page. |
| Table-link repair | `0c0f9a9` | 2026-08-09 | Markdown-table wikilink aliases repaired. |
| `wiki-v0.3-rendering-integrity` | `627a19e` | 2026-08-09 | Rendering-oriented validation and repository hardening. |
| `wiki-v0.4-human-design` | `9e1d51c` | 2026-08-09 | Human-reader hierarchy and visual design system. |
| `wiki-v0.5-investor-visuals` | `c0c60c5` | 2026-08-09 | Original investor-facing diagrams and authority links. |
| Vault-root repair | `42d29b3` | 2026-08-09 | Correct Obsidian Publish vault boundary established. |
| Vault registration | `0429aba` | 2026-08-09 | Canonical `MH Wiki` vault registered in Obsidian. |
| `wiki-v0.6-publish-audit` | `f67b4b7` | 2026-08-09 | Live Publish deployment audit and real-DOM style repairs. |
| `wiki-v1.0-recovery-baseline` | `282c6d8` | 2026-08-09 | Independent mirror, immutable-bundle tooling and recovery index established. |

Run `tools\wiki-history.cmd` for the live commit-and-tag index. It reads Git directly, so it always includes generations created after this narrative table.

## Current Content Milestone

`wiki-v1.19-us-tax-incentives` adds the U.S. incentive guide, cash-monetization explanation and eight state profiles, with one preserved report source and current primary-authority review. The preceding `wiki-v1.18-underwriting-context` milestone preserves the qualitative underwriting refresh and its evidence boundaries.

`wiki-v1.20-search-discovery` completes the 38-page sitemap through the narrowly routed Cloudflare discovery Worker and adds full-corpus deployment verification, crawler-response regressions and transport checks. Its operation log records the verified Google Search Console submission separately from Google's eventual indexing decisions. Worker rollback and deployment boundaries are documented in README.md.

`wiki-v1.21-research-library` integrates all five FilmHedge reports and the illustrated Medium tax guide across relevant reader topics. It adds one research-library page, fourteen original report visuals and four immutable report editions with source provenance and scoped evidence limits. The live release contains 39 public notes and 65 public files verified against local hashes.

## Safe Recovery

Prefer restoring into a separate folder first. This preserves the current vault and any manual edits while the recovered generation is inspected.

### Restore the Current Archive Into a Separate Folder

```powershell
git clone "<absolute-path-to-off-repository-mirror>" "<new-separate-restore-folder>"
```

### Inspect an Older Generation

From the separate restored folder:

```powershell
git switch --detach wiki-v0.3-rendering-integrity
```

### Recover One Deleted File Without Replacing the Vault

From the working repository, first confirm the working tree and chosen generation. Then restore only the named file:

```powershell
git status --short
git restore --source wiki-v0.5-investor-visuals -- "path\to\file.md"
```

Review the restored file and commit it as a new recovery change. Do not use `git reset --hard` or rewrite history for routine recovery.

## Maintenance Rules

- Existing or uncommitted changes belong to the user. Preserve and commit them deliberately before broad wiki updates.
- Completed operations are linted and committed; recovery history is additive rather than rewritten.
- Run `tools\wiki-archive.cmd` after a completed commit to update the mirror.
- Run `tools\wiki-archive.cmd -CreateBundle` at major milestones to create an immutable full-history bundle.
- Run `tools\wiki-diagnostics.cmd` for a read-only integrity audit, or add `-DeepRestore` to restore the mirror, every milestone tag and the newest bundle into isolated temporary folders.
- Verify the mirror, every branch and tag, each bundle and each `.sha256` checksum before relying on them; the archive and diagnostics tools perform these checks independently.

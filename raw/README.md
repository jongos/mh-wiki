---
publish: false
---

# Raw Source Layer

This directory is the immutable evidence layer for the MediaHedge wiki.

- `sources/` contains canonical source snapshots. Do not edit files in place.
- `inbox/` is the drop location for new, not-yet-ingested material.
- `manifest.md` records source identity, hash and ingestion status.

If a source changes, preserve the old version and add the new one with a version or date suffix. Update the manifest, source-summary page, affected concepts, index and log. Never treat the compiled Markdown wiki as a replacement for the raw evidence.

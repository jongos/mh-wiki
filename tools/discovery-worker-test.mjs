import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import worker, { buildSitemap } from "./discovery-worker.mjs";
const config = JSON.parse(readFileSync(new URL("./discovery-worker.wrangler.jsonc", import.meta.url), "utf8"));
assert.equal(config.workers_dev, false);
assert.equal(config.preview_urls, false);
assert.deepEqual(config.routes.map(route => route.pattern).sort(), ["mediafinance.guide/robots.txt", "mediafinance.guide/sitemap.xml"]);
assert.ok(config.routes.every(route => route.zone_name === "mediafinance.guide"));
const publicPage = { frontmatter: { publish: true, updated: "2026-10-06" } };
const inventory = {
  "MediaHedge Knowledgebase.md": publicPage,
  "wiki/entities/california-film-incentives.md": publicPage,
  "wiki/operations/internal-catalog.md": publicPage,
  "wiki/sources/private-source.md": publicPage,
  "raw/secret.md": publicPage,
  "wiki/concepts/hidden.md": { frontmatter: { publish: false } },
  "wiki/concepts/string-flag.md": { frontmatter: { publish: "true" } },
  "wiki/concepts/../secret.md": publicPage,
  "wiki/concepts/bad<path.md": publicPage,
  "wiki/concepts/bad-date.md": { frontmatter: { publish: true, updated: "2026-02-30" } }
};
const xml = buildSitemap(inventory);
assert.equal((xml.match(/<loc>/g) || []).length, 3);
assert.equal((xml.match(/<lastmod>/g) || []).length, 2);
assert.ok(xml.includes("https://mediafinance.guide/MediaHedge+Knowledgebase"));
assert.ok(!/secret|operations|sources|hidden|string-flag|bad&lt;/.test(xml));
assert.throws(() => buildSitemap({}));
assert.throws(() => buildSitemap([]));
const originalFetch = globalThis.fetch;
try {
  globalThis.fetch = async (url, options) => {
    assert.equal(options.redirect, "manual");
    assert.equal(options.cf.cacheTtl, 60);
    assert.ok(url.startsWith("https://publish-01.obsidian.md/cache/"));
    return new Response(JSON.stringify(inventory));
  };
  const get = await worker.fetch(new Request("https://mediafinance.guide/sitemap.xml?refresh=1"));
  assert.equal(get.status, 200);
  assert.equal(await get.text(), xml);
  assert.equal(get.headers.get("X-Content-Type-Options"), "nosniff");
  assert.match(get.headers.get("Content-Type"), /^application\/xml/);
  const head = await worker.fetch(new Request("https://mediafinance.guide/sitemap.xml", { method: "HEAD" }));
  assert.equal(head.status, 200);
  assert.equal(await head.text(), "");
  const robots = await worker.fetch(new Request("https://mediafinance.guide/robots.txt"));
  assert.match(await robots.text(), /Sitemap: https:\/\/mediafinance.guide\/sitemap.xml/);
  assert.equal((await worker.fetch(new Request("https://mediafinance.guide/sitemap.xml", { method: "POST" }))).status, 405);
  assert.equal((await worker.fetch(new Request("https://mediafinance.guide/wiki/example"))).status, 404);
  assert.equal((await worker.fetch(new Request("http://mediafinance.guide/sitemap.xml"))).headers.get("Location"), "https://mediafinance.guide/sitemap.xml");
  globalThis.fetch = async () => new Response(null, { status: 302, headers: { Location: "https://example.invalid/" } });
  assert.equal((await worker.fetch(new Request("https://mediafinance.guide/sitemap.xml"))).status, 503);
  globalThis.fetch = async () => { throw new Error("upstream failure"); };
  const unavailable = await worker.fetch(new Request("https://mediafinance.guide/sitemap.xml"));
  assert.equal(unavailable.status, 503);
  assert.equal(unavailable.headers.get("Cache-Control"), "no-store");
} finally { globalThis.fetch = originalFetch; }
console.log("Discovery worker: public-only selection, safe URLs/dates, GET/HEAD, redirects, MIME/security headers and upstream failure handling passed.");

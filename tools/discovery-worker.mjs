// Public discovery routes only; no account credentials or private data bindings.
const origin = "https://mediafinance.guide";
const indexUrl = "https://publish-01.obsidian.md/cache/ab225bc87f274ad75f0e37d5bcd53bff";
const allowedPath = /^(?:MediaHedge Knowledgebase|wiki\/(?:overview|glossary|evidence-and-limitations|what-changed)|wiki\/(?:concepts|entities|syntheses)\/[a-z0-9]+(?:-[a-z0-9]+)*)\.md$/;
const xmlEscape = (value) => value.replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll('"', "&quot;").replaceAll("'", "&apos;");

export function buildSitemap(index) {
  if (!index || typeof index !== "object" || Array.isArray(index)) throw new Error("Invalid public index");
  const entries = Object.entries(index).filter(([path, page]) =>
    allowedPath.test(path) && page?.frontmatter?.publish === true
  ).sort(([a], [b]) => a.localeCompare(b, "en"));
  if (entries.length === 0 || entries.length > 50000) throw new Error("Invalid sitemap size");
  const urls = entries.map(([path, page]) => {
    const route = path.slice(0, -3).split("/").map(part => encodeURIComponent(part).replaceAll("%20", "+")).join("/");
    const updated = page.frontmatter.updated;
    const validDate = typeof updated === "string" && /^\d{4}-\d{2}-\d{2}$/.test(updated)
      && !Number.isNaN(Date.parse(updated)) && new Date(updated).toISOString().slice(0, 10) === updated;
    return `<url><loc>${xmlEscape(origin + "/" + route)}</loc>${validDate ? `<lastmod>${updated}</lastmod>` : ""}</url>`;
  });
  return '<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n' + urls.join("\n") + '\n</urlset>\n';
}

function respond(request, body, status, type, extra = {}) {
  return new Response(request.method === "HEAD" ? null : body, { status, headers: {
    "Content-Type": type + "; charset=utf-8",
    "X-Content-Type-Options": "nosniff",
    "Content-Security-Policy": "default-src 'none'; frame-ancestors 'none'",
    "Referrer-Policy": "no-referrer",
    "Cache-Control": status === 200 ? "public, max-age=60" : "no-store",
    ...extra
  }});
}

export default {
  async fetch(request) {
    const url = new URL(request.url);
    if (!["/sitemap.xml", "/robots.txt"].includes(url.pathname)) {
      return respond(request, "Not found\n", 404, "text/plain");
    }
    if (!["GET", "HEAD"].includes(request.method)) {
      return respond(request, "Method not allowed\n", 405, "text/plain", { Allow: "GET, HEAD" });
    }
    if (url.protocol !== "https:" || url.hostname !== "mediafinance.guide") {
      return Response.redirect(origin + url.pathname, 301);
    }
    if (url.pathname === "/robots.txt") {
      return respond(request, "User-agent: *\nAllow: /\nSitemap: " + origin + "/sitemap.xml\n", 200, "text/plain");
    }
    let stage = "fetch";
    try {
      const response = await fetch(indexUrl, {
        headers: { Accept: "application/json" },
        redirect: "manual",
        signal: AbortSignal.timeout(10000),
        cf: { cacheTtl: 60, cacheEverything: true }
      });
      stage = "upstream-" + response.status;
      if (!response.ok) throw new Error("Public index unavailable");
      stage = "parse";
      const index = await response.json();
      stage = "build";
      return respond(request, buildSitemap(index), 200, "application/xml", { "X-MH-Discovery": "public-index-v1" });
    } catch {
      // Never return an empty successful sitemap on an upstream failure.
      return respond(request, "Sitemap temporarily unavailable\n", 503, "text/plain", { "Retry-After": "60", "X-MH-Discovery-Status": stage });
    }
  }
};

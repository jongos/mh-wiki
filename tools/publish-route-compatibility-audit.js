"use strict";

const fs = require("node:fs");
const vm = require("node:vm");

const publishJsPath = process.argv[2];
if (!publishJsPath) throw new Error("Usage: node publish-route-compatibility-audit.js <publish.js>");

const publishJs = fs.readFileSync(publishJsPath, "utf8");
const cases = [
  {
    source: "https://mediafinance.guide/wiki",
    expected: "https://mediafinance.guide/MediaHedge+Knowledgebase"
  },
  {
    source: "https://mediafinance.guide/wiki/?legacy=1#old",
    expected: "https://mediafinance.guide/MediaHedge+Knowledgebase"
  },
  {
    source: "https://publish.obsidian.md/mediahdge/wiki",
    expected: "https://publish.obsidian.md/mediahdge/MediaHedge+Knowledgebase"
  }
];

for (const testCase of cases) {
  const location = new URL(testCase.source);
  let destination = "";
  location.replace = (value) => {
    destination = value;
  };

  vm.runInNewContext(publishJs, {
    URL,
    window: { location }
  });

  if (destination !== testCase.expected) {
    throw new Error(`Legacy route ${testCase.source} redirected to ${destination || "nothing"}; expected ${testCase.expected}`);
  }
}

console.log("Legacy /wiki compatibility redirects resolve to the published knowledgebase home page.");

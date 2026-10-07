---
publish: false
---

# Reader Interface Design Record

Updated: 2026-10-07. Scope: the Obsidian Publish reader website. This maintenance record is excluded from the website and remains in the intentionally public Git repository.

## Direction

Use a distinctive editorial field guide for financiers, newcomers and production counsel. Put reader tasks before the conceptual lifecycle illustration. Preserve the MediaHedge navy, teal and warm-white identity, existing URLs, original diagrams and Obsidian navigation. Page dates mean edit dates, not policy verification dates. Policy uncertainty remains visible beside decision guidance.

## Typography and Layout

The October 7 Dazzler refresh pairs Libre Baskerville variable headings with Inter Variable reading and interface text. Genuine Libre Baskerville italics give captions and emphasis an editorial voice. Three unchanged bundled WOFF2 files (about 467 KiB combined) are embedded in publish.css so Obsidian serves them as part of the verified theme without third-party font requests. Source files, copyright, OFL licenses and provenance are retained in tools/design-fonts; the CSS also carries full license notices. No OS font installation is required. Segoe UI and Georgia remain fallbacks. Body text uses fluid sizing from 1rem to 1.125rem and a maximum measure of 60ch. Tables and diagrams may exceed this measure because their relationships need space; narrow screens scroll these regions rather than the document. Use one reader H1, serif display hierarchy, clear section spacing and a teal rule above the page metadata. A navy navigation rail anchors the reading surface. Comparison tables use navy header bands, aligned numeric typography and square edges; prose remains limited to 60ch. The home routes carry sequential navigation numbers, not performance metrics. The platform's duplicate filename H1 stays hidden.

The home page has four task routes in two columns, collapsing to one below 700px. The banner is compact. Sidebar search has a 44px minimum height, and mobile navigation targets have a 44px minimum height. Reading content takes priority over decorative frames and shadows.

## Color and Interaction

Light roles: warm-white background `#fbfaf7`, body `#243238`, muted text `#55666d`, links `#176b73`, heading navy `#0c224f`. Warning titles use RGB 135, 70, 15. Dark roles: background `#111923`, body `#e6ecee`, muted text `#aab8bd`, links `#6bd3dc`, heading `#f4f8f9`; warnings use `#f0b36f`. Callouts carry written labels as well as color.

Provide a focus-visible Skip to Article link, named keyboard-scroll regions for diagrams and tables, and full-size diagram/research-graphic links that identify their new-tab behavior. Research raster graphics now use the same named keyboard-scroll and full-size controls as SVG diagrams, retaining their source captions. Preserve the search combobox/listbox contract and scoped navigation observer. Content enhancement reuses the existing coalesced metadata update; do not add a document-wide mutation observer. Reduced-motion and forced-color preferences remain respected; print omits interaction controls.

## Historical Verification and Limits

Local Chrome previews used the live Obsidian-rendered home and loan-sizing DOM with local CSS, JavaScript and revised content. Desktop (1440px), mobile (390px), dark mode and 32px root text at 640px all had no document overflow. These static snapshots prove layout, not Obsidian routing or the complete live search integration.

Rendered contrast checks sampled metadata, introductory text, links and warning/tip titles and bodies in both themes. All sampled pairs exceeded 4.5:1 after fixing the light warning title from 3.99:1 to 5.94:1. Real ArrowRight input scrolled the focused mobile diagram with a visible outline. The browser regression fixture verifies skip-link focus, one date row before the actual reader H1 (including a hidden platform H1), diagram links, table focus, search states and scoped observation. The required 12-check Windows suite passed. This is targeted evidence, not a complete WCAG or screen-reader certification.

Before treating a release as deployed, run the repository's live Publish audit and verify the selected reader notes. Keep raw evidence, sources, operations and this design record out of the website selection.

Live deployment verified on 2026-09-30: 39-file inventory and exact asset hashes matched; all six revised reader notes matched local content. The live browser passed search, SEO, navigation, visible dates/review warnings, skip focus and mobile diagram keyboard scrolling.

## Native Scrolling Contract

The 2026-09-30 interaction review found and fixed backward scroll drift caused by inserting metadata directly into Obsidian's virtualized sizer. All custom article UI must live inside an existing native section; never add sibling sections to `.markdown-preview-sizer`. The date row belongs inside `.el-h1`. The live regression audit must prove that finite wheel input settles without continued movement, including vertical wheel input over mobile diagrams. Skip to Article resets the article scroll container. Search Escape dismisses results; native folder controls expose keyboard focus, Enter/Space activation and expanded state. Browser shortcuts remain native. Synthetic Chrome wheel tests do not certify every trackball driver or physical device.

## October 7 Dazzler Design Review

The user requested the newly installed Dazzler skill across the wiki. Three directions were considered: a dark research terminal, a film-poster composition, and an editorial credit field guide. The field guide best supports sustained reading, dense comparisons and evidentiary caveats. Its defining move is the fixed navy reference rail against a warm reading surface, with expressive serif headings and dense sans-serif evidence tables. Strong contrast in navigation and table headers supplies the drama; body text, charts and policy wording remain restrained and intact. This extends the existing field-guide identity rather than introducing a new brand or platform.

Local browser previews used actual Obsidian-rendered research-library content with the proposed stylesheet. Both selected families and the genuine italic face loaded. Desktop 1280px, mobile 390px and mobile dark-mode captures passed the scoped GDC checks for document overflow, title presence, title-font binding and opaque table-header contrast (15.47:1 light, 10.86:1 dark). The observations were collected through Codex tab CDP and evaluated with Dazzler's GDC engine; reports in tools/design-review state the limited coverage. These measurements do not certify complete accessibility or aesthetic quality. The rendered review found the type hierarchy, rail, table bands and evidence frames coherent and distinct from the prior system-sans presentation.

The Dazzler color helper validated the preserved brand seed and locked light reading roles. Unused generated ramp warnings were not adopted as page tokens. Final colors remain the authored shared CSS roles, including separate high-contrast rail text and active/focus colors. No financial quantities, sources, current-policy qualifications or chart pixels changed.

Heading audit covers all 342 authored public headings. The three lowercase “into” headings are explicit exceptions under AGENTS.md's existing short-preposition rule, retained in this visual-only refresh. All other headings follow protected Title Case. Rendered headings and interactions are checked again after deployment.

Final live verification: the full Publish audit passed with all 65 file hashes matching, all 39 routes and sitemap entries correct, and successful search, SEO, Site Navigator, keyboard navigation, skip-to-top, desktop wheel settling and mobile wheel chaining checks. Home, research library, a long Georgia profile and incentive-monetization artwork were visually inspected. Real ArrowRight input moved the focused raster graphic, which retained a visible outline and full-size link. The 390px page had no document overflow. A 640px preview with 32px root text also had no document overflow. Sampled live navigation, metadata, title and introductory-text contrast ranged from 5.74:1 to 15.47:1. All 14 local Windows regressions passed, including the new raster-graphic assertion. Hosted CI and archive verification accompany the release commit/tag.

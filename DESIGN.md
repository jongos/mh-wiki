---
publish: false
---

# Reader Interface Design Record

Updated: 2026-09-30. Scope: the Obsidian Publish reader website. This maintenance record is excluded from the website and remains in the intentionally public Git repository.

## Direction

Use a restrained editorial field guide for financiers, newcomers and production counsel. Put reader tasks before the conceptual lifecycle illustration. Preserve the MediaHedge navy, teal and warm-white identity, existing URLs, original diagrams and Obsidian navigation. Page dates mean edit dates, not policy verification dates. Policy uncertainty remains visible beside decision guidance.

## Typography and Layout

Keep the established Aptos, Segoe UI and sans-serif system fallback stack. No font download, dependency or OS installation is introduced. Body text uses fluid sizing from 1rem to 1.125rem and a maximum measure of 60ch. Tables and diagrams may exceed this measure because their relationships need space; narrow screens scroll these regions rather than the document. Use one reader H1, clear section spacing and restrained horizontal rules. The platform's duplicate filename H1 stays hidden.

The home page has four task routes in two columns, collapsing to one below 700px. The banner is compact. Sidebar search has a 44px minimum height, and mobile navigation targets have a 44px minimum height. Reading content takes priority over decorative frames and shadows.

## Color and Interaction

Light roles: warm-white background `#fbfaf7`, body `#243238`, muted text `#55666d`, links `#176b73`, heading navy `#0c224f`. Warning titles use RGB 135, 70, 15. Dark roles: background `#111923`, body `#e6ecee`, muted text `#aab8bd`, links `#6bd3dc`, heading `#f4f8f9`; warnings use `#f0b36f`. Callouts carry written labels as well as color.

Provide a focus-visible Skip to Article link, named keyboard-scroll regions for diagrams and tables, and a full-size diagram link that identifies its new-tab behavior. Preserve the search combobox/listbox contract and scoped navigation observer. Content enhancement reuses the existing coalesced metadata update; do not add a document-wide mutation observer. Reduced-motion and forced-color preferences remain respected; print omits interaction controls.

## Verification and Limits

Local Chrome previews used the live Obsidian-rendered home and loan-sizing DOM with local CSS, JavaScript and revised content. Desktop (1440px), mobile (390px), dark mode and 32px root text at 640px all had no document overflow. These static snapshots prove layout, not Obsidian routing or the complete live search integration.

Rendered contrast checks sampled metadata, introductory text, links and warning/tip titles and bodies in both themes. All sampled pairs exceeded 4.5:1 after fixing the light warning title from 3.99:1 to 5.94:1. Real ArrowRight input scrolled the focused mobile diagram with a visible outline. The browser regression fixture verifies skip-link focus, one date row before the actual reader H1 (including a hidden platform H1), diagram links, table focus, search states and scoped observation. The required 12-check Windows suite passed. This is targeted evidence, not a complete WCAG or screen-reader certification.

Before treating a release as deployed, run the repository's live Publish audit and verify the selected reader notes. Keep raw evidence, sources, operations and this design record out of the website selection.

Live deployment verified on 2026-09-30: 39-file inventory and exact asset hashes matched; all six revised reader notes matched local content. The live browser passed search, SEO, navigation, visible dates/review warnings, skip focus and mobile diagram keyboard scrolling.

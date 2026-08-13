/* MediaHedge reader-navigation enhancements for Obsidian Publish. */

(() => {
  "use strict";

  // BEGIN GENERATED READER LABELS
  const readerLabels = new Map([
    ["MediaHedge Knowledgebase.md", "Welcome & Start Here"],
    ["wiki", "Knowledgebase Library"],
    ["wiki/concepts", "Financing Essentials"],
    ["wiki/entities", "About MediaHedge"],
    ["wiki/syntheses", "Guides & Decision Maps"],
    ["wiki/concepts/cash-control-and-waterfalls.md", "Cash Control & Waterfalls"],
    ["wiki/concepts/completion-protection.md", "Completion Protection"],
    ["wiki/concepts/defaults-workouts-and-recoveries.md", "Defaults, Workouts & Recoveries"],
    ["wiki/concepts/financier-return-economics.md", "Financing-Partner Return Economics"],
    ["wiki/concepts/forward-flow-governance.md", "Financing-Partner Governance"],
    ["wiki/concepts/full-financing.md", "Full Financing"],
    ["wiki/concepts/gap-collateral.md", "Gap Collateral"],
    ["wiki/concepts/loan-sizing.md", "Loan Sizing"],
    ["wiki/concepts/monitoring-and-servicing.md", "Monitoring & Servicing"],
    ["wiki/concepts/portfolio-construction.md", "Portfolio Construction"],
    ["wiki/concepts/pre-sales-collateral.md", "Pre-Sales Collateral"],
    ["wiki/concepts/production-insurance.md", "Production Insurance"],
    ["wiki/concepts/protection-stack.md", "Protection Stack"],
    ["wiki/concepts/security-package.md", "Security Package"],
    ["wiki/concepts/surety-credit-protection.md", "Surety & Credit Protection"],
    ["wiki/concepts/tax-credit-collateral.md", "Tax-Credit Collateral"],
    ["wiki/entities/mediahedge.md", "Who MediaHedge Is"],
    ["wiki/evidence-and-limitations.md", "Evidence & Limitations"],
    ["wiki/glossary.md", "Plain-English Glossary"],
    ["wiki/overview.md", "How the Lending Model Works"],
    ["wiki/syntheses/credit-lifecycle.md", "Film-Finance Credit Lifecycle"],
    ["wiki/syntheses/financier-diligence-route.md", "Financier's Guide"],
    ["wiki/syntheses/media-finance-lending-landscape.md", "Media Finance Lending Landscape"],
    ["wiki/syntheses/policy-rails-and-control-matrix.md", "Policy & Control Guide"],
    ["wiki/syntheses/repayment-and-risk-map.md", "Repayment & Risk Map"],
    ["wiki/syntheses/site-navigator.md", "Site Navigator"]
  ]);
  // END GENERATED READER LABELS

  const navigatorPath = "wiki/syntheses/site-navigator.md";
  const searchListId = "mh-search-suggestions";
  const searchStatusId = "mh-search-status";
  const relevantNavigationSelector = ".nav-view-outer, .search-view-outer, .search-view-container, .search-results";
  let updateScheduled = false;
  let navigationObserver;
  let layoutObserver;
  let observedNavigationRoot;

  const normalizePath = (path) => (path || "").replaceAll("\\", "/");

  const labelForPath = (path) => readerLabels.get(normalizePath(path));

  const categoryLabelForPath = (path) => {
    const normalized = normalizePath(path).replace(/\.md$/, "");
    const categoryPath = ["wiki/concepts", "wiki/entities", "wiki/syntheses", "wiki"]
      .find((candidate) => normalized === candidate || normalized.startsWith(`${candidate}/`));
    return categoryPath ? labelForPath(categoryPath) : undefined;
  };

  const setHighlightedLabel = (element, label, query) => {
    const normalizedQuery = query || "";
    if (element.dataset.mhReaderLabel === label &&
        element.dataset.mhReaderQuery === normalizedQuery) return;

    const rememberRendering = () => {
      element.dataset.mhReaderLabel = label;
      element.dataset.mhReaderQuery = normalizedQuery;
    };
    if (!query || element.textContent === label) {
      if (element.textContent !== label) element.textContent = label;
      rememberRendering();
      return;
    }

    const matchIndex = label.toLocaleLowerCase().indexOf(query.toLocaleLowerCase());
    if (matchIndex < 0) {
      element.textContent = label;
      rememberRendering();
      return;
    }

    const match = document.createElement("span");
    match.className = "suggestion-highlight";
    match.textContent = label.slice(matchIndex, matchIndex + query.length);
    element.replaceChildren(
      label.slice(0, matchIndex),
      match,
      label.slice(matchIndex + query.length)
    );
    rememberRendering();
  };

  const labelNavigation = () => {
    document.querySelectorAll(".nav-view-outer .tree-item-self[data-path]").forEach((item) => {
      const label = labelForPath(item.dataset.path);
      const inner = item.querySelector(":scope > .tree-item-inner");
      if (!label || !inner) return;

      const labelTarget = inner.querySelector(":scope > a") || inner;
      if (labelTarget.textContent !== label) labelTarget.textContent = label;
      item.setAttribute("aria-label", label);
      item.setAttribute("title", label);
    });
  };

  const ensureNavigatorShortcut = () => {
    const rootSelf = document.querySelector('.nav-view-outer .tree-item-self.mod-root[data-path=""]');
    const rootChildren = rootSelf?.parentElement?.querySelector(":scope > .tree-item-children");
    if (!rootChildren) return;

    const home = rootChildren.querySelector(':scope > .tree-item > .tree-item-self[data-path="MediaHedge Knowledgebase.md"]')?.parentElement;
    let shortcut = rootChildren.querySelector(':scope > .tree-item[data-mh-navigator-shortcut="true"]');

    if (!shortcut) {
      shortcut = document.createElement("div");
      shortcut.className = "tree-item mh-navigator-shortcut";
      shortcut.dataset.mhNavigatorShortcut = "true";

      const item = document.createElement("div");
      item.className = "tree-item-self is-clickable";
      item.dataset.path = navigatorPath;

      const inner = document.createElement("div");
      inner.className = "tree-item-inner";

      const link = document.createElement("a");
      link.href = new URL("/wiki/syntheses/site-navigator", window.location.origin).href;
      link.textContent = "Site Navigator";

      inner.append(link);
      item.append(inner);
      shortcut.append(item);
    }

    if (home && rootChildren.firstElementChild !== home) rootChildren.prepend(home);
    if (home?.nextElementSibling !== shortcut) home?.insertAdjacentElement("afterend", shortcut);
    if (!home && rootChildren.firstElementChild !== shortcut) rootChildren.prepend(shortcut);

    const currentPath = decodeURIComponent(window.location.pathname).replaceAll("+", " ");
    const shortcutItem = shortcut.querySelector(".tree-item-self");
    const isNavigatorActive = currentPath.endsWith("/wiki/syntheses/site-navigator");
    if (shortcutItem && shortcutItem.classList.contains("mod-active") !== isNavigatorActive) {
      shortcutItem.classList.toggle("mod-active", isNavigatorActive);
    }
  };

  const enhanceSearch = () => {
    const container = document.querySelector(".search-view-container");
    const input = container?.querySelector("input.search-bar");
    if (!container || !input) return;

    if (!container.querySelector(".mh-search-label")) {
      const label = document.createElement("label");
      label.className = "mh-search-label";
      label.htmlFor = "mh-site-search";
      label.textContent = "Search the Knowledgebase";
      container.prepend(label);
    }

    if (!container.querySelector(`#${searchStatusId}`)) {
      const status = document.createElement("span");
      status.id = searchStatusId;
      status.className = "mh-search-status";
      status.setAttribute("role", "status");
      status.setAttribute("aria-live", "polite");
      status.setAttribute("aria-atomic", "true");
      container.append(status);
    }

    input.id = "mh-site-search";
    input.placeholder = "Search pages and topics…";
    input.setAttribute("aria-label", "Search the MediaHedge knowledgebase");
    input.setAttribute("aria-autocomplete", "list");
    input.setAttribute("aria-controls", searchListId);
    input.setAttribute("aria-describedby", searchStatusId);
    if (!input.hasAttribute("aria-expanded")) input.setAttribute("aria-expanded", "false");
    input.setAttribute("aria-haspopup", "listbox");
    input.setAttribute("autocomplete", "off");
    input.setAttribute("role", "combobox");

    if (input.dataset.mhComboboxBound !== "true") {
      input.dataset.mhComboboxBound = "true";
      input.addEventListener("input", scheduleReaderNavigation);
      input.addEventListener("keydown", () => window.setTimeout(scheduleReaderNavigation, 0));
    }
  };

  const enhanceSearchResults = () => {
    const input = document.querySelector("input.search-bar");
    const results = document.querySelector(".search-results");
    const status = document.getElementById(searchStatusId);
    if (!input) return;

    const query = input.value.trim();
    const items = [...document.querySelectorAll(".search-results .suggestion-item")];
    const selectedItem = items.find((item) =>
      item.matches(".is-selected, .mod-active") || item.contains(document.activeElement)
    );

    if (results) {
      results.id = searchListId;
      results.setAttribute("role", "listbox");
      results.setAttribute("aria-label", "Search suggestions");
    }

    items.forEach((item, index) => {
      const title = item.querySelector(".suggestion-title");
      const note = item.querySelector(".suggestion-note");
      if (!title || !note) return;

      item.id = `mh-search-option-${index + 1}`;
      item.setAttribute("role", "option");
      item.setAttribute("aria-selected", item === selectedItem ? "true" : "false");

      const rawTitle = title.dataset.mhRawTitle || title.textContent.trim();
      const rawPath = note.dataset.mhRawPath || note.textContent.trim();
      title.dataset.mhRawTitle = rawTitle;
      note.dataset.mhRawPath = rawPath;

      const pagePath = rawPath.endsWith(`/${rawTitle}`)
        ? `${rawPath}.md`
        : `${rawPath}/${rawTitle}.md`;
      const readerTitle = labelForPath(pagePath) || labelForPath(`${rawPath}.md`);
      if (readerTitle) setHighlightedLabel(title, readerTitle, query);

      const categoryLabel = categoryLabelForPath(rawPath);
      if (categoryLabel && note.textContent !== categoryLabel) note.textContent = categoryLabel;
      if (categoryLabel && !note.classList.contains("mh-reader-category")) {
        note.classList.add("mh-reader-category");
      }

      item.querySelectorAll(".suggestion-detail").forEach((detail) => {
        const detailText = detail.textContent.trim();
        const isTechnicalDetail = /(^|\/)assets\//i.test(detailText) || /\.(svg|png|jpe?g|webp)$/i.test(detailText);
        if (detail.classList.contains("mh-technical-search-detail") !== isTechnicalDetail) {
          detail.classList.toggle("mh-technical-search-detail", isTechnicalDetail);
        }
      });
    });

    const isExpanded = query.length > 0 && items.length > 0;
    input.setAttribute("aria-expanded", String(isExpanded));
    if (selectedItem?.id) {
      input.setAttribute("aria-activedescendant", selectedItem.id);
    } else {
      input.removeAttribute("aria-activedescendant");
    }

    if (status) {
      const announcement = !query
        ? ""
        : items.length > 0
          ? `${items.length} suggestion${items.length === 1 ? "" : "s"} available. Use the up and down arrow keys to review them.`
          : "No suggestions found.";
      if (status.textContent !== announcement) status.textContent = announcement;
    }
  };

  const applyReaderNavigation = () => {
    updateScheduled = false;
    enhanceSearch();
    enhanceSearchResults();
    ensureNavigatorShortcut();
    labelNavigation();
  };

  const scheduleReaderNavigation = () => {
    if (updateScheduled) return;
    updateScheduled = true;
    window.requestAnimationFrame(applyReaderNavigation);
  };

  const mutationTouchesReaderNavigation = (mutation) => {
    const target = mutation.target instanceof Element
      ? mutation.target
      : mutation.target.parentElement;
    if (target?.closest(relevantNavigationSelector)) return true;

    return [...mutation.addedNodes, ...mutation.removedNodes].some((node) =>
      node instanceof Element &&
      (node.matches(relevantNavigationSelector) || node.querySelector(relevantNavigationSelector))
    );
  };

  const getNavigationRoot = () =>
    document.querySelector(".site-body-left-column") ||
    document.querySelector(".nav-view-outer")?.parentElement ||
    document.querySelector(".search-view-outer")?.parentElement;

  const observeReaderNavigation = () => {
    const navigationRoot = getNavigationRoot();
    if (!navigationRoot || navigationRoot === observedNavigationRoot) return;

    navigationObserver?.disconnect();
    observedNavigationRoot = navigationRoot;
    navigationObserver = new MutationObserver((mutations) => {
      if (mutations.some(mutationTouchesReaderNavigation)) scheduleReaderNavigation();
    });
    navigationObserver.observe(navigationRoot, {
      attributes: true,
      attributeFilter: ["class"],
      childList: true,
      subtree: true
    });
  };

  const start = () => {
    scheduleReaderNavigation();
    observeReaderNavigation();

    const layoutRoot = document.querySelector(".site-body") || document.body;
    layoutObserver = new MutationObserver(() => {
      if (getNavigationRoot() !== observedNavigationRoot) {
        observeReaderNavigation();
        scheduleReaderNavigation();
      }
    });
    layoutObserver.observe(layoutRoot, { childList: true });
  };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", start, { once: true });
  } else {
    start();
  }
})();

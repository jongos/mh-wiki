/* MediaHedge reader-navigation enhancements for Obsidian Publish. */

(() => {
  "use strict";

  const legacyWikiPathPattern = /\/wiki\/?$/;
  if (legacyWikiPathPattern.test(window.location.pathname)) {
    const homeUrl = new URL(window.location.href);
    homeUrl.pathname = homeUrl.pathname.replace(legacyWikiPathPattern, "/MediaHedge+Knowledgebase");
    homeUrl.search = "";
    homeUrl.hash = "";
    window.location.replace(homeUrl.href);
    return;
  }

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

  // BEGIN GENERATED SEO METADATA
  const seoPages = new Map([
    ["MediaHedge Knowledgebase.md", { title: "Welcome to the MediaHedge Knowledgebase", seoTitle: "Film and Television Finance Guide | MediaHedge", description: "Explore film and television finance through MediaHedge's guide to collateral, loan sizing, cash control, risk protection, servicing, recovery and returns.", updated: "2026-08-28", type: "operations" }],
    ["wiki/concepts/cash-control-and-waterfalls.md", { title: "Cash Control and Waterfalls", seoTitle: "Cash Control and Waterfalls | Media Finance Guide", description: "Learn how payment directions, collection accounts, account control, contractual waterfalls and reconciliation turn proceeds into prioritized loan repayment.", updated: "2026-08-28", type: "concept" }],
    ["wiki/concepts/completion-protection.md", { title: "Completion Protection", seoTitle: "Completion Protection | Media Finance Guide", description: "Understand how completion bonds and guaranties support production and delivery, what remedies they may provide and why they do not guarantee loan repayment.", updated: "2026-08-28", type: "concept" }],
    ["wiki/concepts/defaults-workouts-and-recoveries.md", { title: "Defaults, Workouts and Recoveries", seoTitle: "Defaults, Workouts and Recoveries | Media Finance Guide", description: "Explore how lenders diagnose film-finance distress, preserve collateral and claims, govern workouts and select remedies that maximize risk-adjusted recovery.", updated: "2026-08-28", type: "concept" }],
    ["wiki/concepts/financier-return-economics.md", { title: "Financing-Partner Return Economics", seoTitle: "Financing-Partner Return Economics | Media Finance Guide", description: "Evaluate film-finance returns through actual dated cash flows, fees, duration, prepayment, extensions, defaults, recoveries, expenses and capital utilization.", updated: "2026-08-28", type: "concept" }],
    ["wiki/concepts/forward-flow-governance.md", { title: "Financing-Partner Governance", seoTitle: "Financing-Partner Governance | Media Finance Guide", description: "See how MediaHedge and financing partners divide eligibility, delegated authority, reserved decisions, servicing duties and risk oversight in forward-flow programs.", updated: "2026-08-28", type: "concept" }],
    ["wiki/concepts/full-financing.md", { title: "Full Financing", seoTitle: "Full Financing | Media Finance Guide", description: "Learn why a film or television production must have complete, verified and properly timed sources to cover production, delivery, reserves and contingency.", updated: "2026-08-28", type: "concept" }],
    ["wiki/concepts/gap-collateral.md", { title: "Gap Collateral", seoTitle: "Gap Collateral | Media Finance Guide", description: "Understand gap financing against discounted unsold film and television rights, including valuation, eligibility, concentration and repayment risks.", updated: "2026-08-28", type: "concept" }],
    ["wiki/concepts/loan-sizing.md", { title: "Loan Sizing", seoTitle: "Loan Sizing | Media Finance Guide", description: "Learn how eligible collateral value, advance rates, concentration limits, leverage, budget exposure, tenor and liquidity constraints determine loan size.", updated: "2026-08-28", type: "concept" }],
    ["wiki/concepts/monitoring-and-servicing.md", { title: "Monitoring and Servicing", seoTitle: "Monitoring and Servicing | Media Finance Guide", description: "See how active servicing tracks production progress, collateral, cash, covenants and recovery timing while escalating material variances for decision.", updated: "2026-08-28", type: "concept" }],
    ["wiki/concepts/portfolio-construction.md", { title: "Portfolio Construction", seoTitle: "Portfolio Construction | Media Finance Guide", description: "Learn how film-finance portfolios manage concentration by distributor, incentive program, guarantor, producer, platform, collateral market and collection timing.", updated: "2026-08-28", type: "concept" }],
    ["wiki/concepts/pre-sales-collateral.md", { title: "Pre-Sales Collateral", seoTitle: "Pre-Sales Collateral | Media Finance Guide", description: "Understand how executed distribution agreements create minimum-guarantee receivables and how financiers verify, discount and control pre-sales collateral.", updated: "2026-08-28", type: "concept" }],
    ["wiki/concepts/production-insurance.md", { title: "Production Insurance", seoTitle: "Production Insurance | Media Finance Guide", description: "Learn how film-production insurance transfers defined casualty, personnel, liability and specialty risks without becoming a completion or repayment guaranty.", updated: "2026-08-28", type: "concept" }],
    ["wiki/concepts/protection-stack.md", { title: "Protection Stack", seoTitle: "Protection Stack | Media Finance Guide", description: "Explore the layered controls MediaHedge uses to address financeability, collateral, completion, payment, cash, servicing and recovery risks without relying on one safeguard.", updated: "2026-08-28", type: "concept" }],
    ["wiki/concepts/security-package.md", { title: "Security Package", seoTitle: "Security Package | Media Finance Guide", description: "Understand how a film-finance security package establishes priority, preserves collateral, captures proceeds and supports practical enforcement for each repayment asset.", updated: "2026-08-28", type: "concept" }],
    ["wiki/concepts/surety-credit-protection.md", { title: "Surety and Credit Protection", seoTitle: "Surety and Credit Protection | Media Finance Guide", description: "Learn how surety bonds and media-credit guarantees support specifically defined payment or performance obligations and where their loan protection ends.", updated: "2026-08-28", type: "concept" }],
    ["wiki/concepts/tax-credit-collateral.md", { title: "Tax-Credit Collateral", seoTitle: "Tax-Credit Collateral | Media Finance Guide", description: "Understand how production incentives become potential collateral through program eligibility, qualified spending, verification, assignment, timing and monetization.", updated: "2026-08-28", type: "concept" }],
    ["wiki/entities/mediahedge.md", { title: "MediaHedge", seoTitle: "MediaHedge | Media Finance Guide", description: "Meet MediaHedge, a specialist film-finance originator, underwriter and servicer working with institutional capital across structured financing relationships.", updated: "2026-08-28", type: "entity" }],
    ["wiki/evidence-and-limitations.md", { title: "Evidence and Limitations", seoTitle: "Evidence and Limitations | Media Finance Guide", description: "Understand the evidence supporting this knowledgebase, its limitations and the legal, policy, market and transaction facts financiers should verify.", updated: "2026-08-28", type: "synthesis" }],
    ["wiki/glossary.md", { title: "MediaHedge Film-Finance Glossary", seoTitle: "MediaHedge Film-Finance Glossary | Media Finance Guide", description: "Learn the film-finance, private-credit, collateral, production, servicing and return terms used throughout the MediaHedge knowledgebase.", updated: "2026-08-28", type: "glossary" }],
    ["wiki/overview.md", { title: "How the MediaHedge Lending Model Works", seoTitle: "How the MediaHedge Lending Model Works | Media Finance Guide", description: "See how MediaHedge connects full financing, collateral eligibility, loan sizing, cash control, protection, servicing, recovery and portfolio discipline.", updated: "2026-08-28", type: "overview" }],
    ["wiki/syntheses/credit-lifecycle.md", { title: "Film-Finance Credit Lifecycle", seoTitle: "Film-Finance Credit Lifecycle | Media Finance Guide", description: "Follow the film-finance credit lifecycle from screening and underwriting through closing, funding, production, servicing, recovery and portfolio reporting.", updated: "2026-08-28", type: "synthesis" }],
    ["wiki/syntheses/financier-diligence-route.md", { title: "Financier's Guide", seoTitle: "Financier's Guide | Media Finance Guide", description: "Use eight financier-focused questions to evaluate financeability, repayment, sizing, control, protection, monitoring, recovery and portfolio economics.", updated: "2026-08-28", type: "synthesis" }],
    ["wiki/syntheses/media-finance-lending-landscape.md", { title: "Media Finance Lending Landscape", seoTitle: "Media Finance Lending Landscape | Media Finance Guide", description: "Compare banks, specialty lenders, private-credit managers, account banks, insurers, completion guarantors and surety providers across media finance.", updated: "2026-08-28", type: "synthesis" }],
    ["wiki/syntheses/policy-rails-and-control-matrix.md", { title: "Policy and Control Guide", seoTitle: "Policy and Control Guide | Media Finance Guide", description: "Review the source-stated MediaHedge sizing rails, exposure limits and operating controls that govern collateral, commitment, closing, servicing and exceptions.", updated: "2026-08-28", type: "synthesis" }],
    ["wiki/syntheses/repayment-and-risk-map.md", { title: "Repayment and Risk Map", seoTitle: "Repayment and Risk Map | Media Finance Guide", description: "Compare contracted receivables, tax incentives, unsold rights, insurance, completion support and surety as distinct repayment and protection paths.", updated: "2026-08-28", type: "synthesis" }],
    ["wiki/syntheses/site-navigator.md", { title: "Site Navigator", seoTitle: "Site Navigator | Media Finance Guide", description: "Navigate the MediaHedge knowledgebase as a connected map of financeability, collateral, control, protection, servicing, recovery and portfolio economics.", updated: "2026-08-28", type: "synthesis" }]
  ]);
  // END GENERATED SEO METADATA

  const navigatorPath = "wiki/syntheses/site-navigator.md";
  const homePagePath = "MediaHedge Knowledgebase.md";
  const canonicalOrigin = "https://mediafinance.guide";
  const siteName = "Media Finance Guide";
  const socialImageUrl = "https://publish-01.obsidian.md/access/ab225bc87f274ad75f0e37d5bcd53bff/assets/mediahedge-banner.jpg";
  const searchListId = "mh-search-suggestions";
  const searchStatusId = "mh-search-status";
  const relevantNavigationSelector = ".nav-view-outer, .search-view-outer, .search-view-container, .search-results";
  let updateScheduled = false;
  let seoUpdateScheduled = false;
  let navigationObserver;
  let seoObserver;
  let layoutObserver;
  let observedNavigationRoot;
  let observedContentRoot;

  const normalizePath = (path) => (path || "").replaceAll("\\", "/");

  const labelForPath = (path) => readerLabels.get(normalizePath(path));

  const categoryLabelForPath = (path) => {
    const normalized = normalizePath(path).replace(/\.md$/, "");
    const categoryPath = ["wiki/concepts", "wiki/entities", "wiki/syntheses", "wiki"]
      .find((candidate) => normalized === candidate || normalized.startsWith(`${candidate}/`));
    return categoryPath ? labelForPath(categoryPath) : undefined;
  };

  const pagePathForLocation = () => {
    const fixturePagePath = window.location.protocol === "file:"
      ? document.documentElement.dataset.mhSeoPage
      : undefined;
    if (fixturePagePath && seoPages.has(fixturePagePath)) return fixturePagePath;

    let decodedPath;
    try {
      decodedPath = decodeURIComponent(window.location.pathname);
    } catch {
      return undefined;
    }
    const route = decodedPath.replaceAll("+", " ").replace(/^\/+|\/+$/g, "");
    if (!route || route === "MediaHedge Knowledgebase") return homePagePath;

    const pagePath = `${route}.md`;
    return seoPages.has(pagePath) ? pagePath : undefined;
  };

  const canonicalUrlForPage = (pagePath) => {
    const route = pagePath
      .replace(/\.md$/, "")
      .split("/")
      .map((segment) => encodeURIComponent(segment).replaceAll("%20", "+"))
      .join("/");
    return `${canonicalOrigin}/${route}`;
  };

  const setMeta = (attribute, name, content) => {
    let meta = document.head.querySelector(`meta[${attribute}="${name}"]`);
    if (!meta) {
      meta = document.createElement("meta");
      meta.setAttribute(attribute, name);
      document.head.append(meta);
    }
    if (meta.content !== content) meta.content = content;
  };

  const setCanonical = (href) => {
    let canonical = document.head.querySelector('link[rel="canonical"]');
    if (!canonical) {
      canonical = document.createElement("link");
      canonical.rel = "canonical";
      document.head.append(canonical);
    }
    if (canonical.href !== href) canonical.href = href;
  };

  const setStructuredData = (pagePath, metadata, canonicalUrl) => {
    const organizationId = `${canonicalOrigin}/#organization`;
    const websiteId = `${canonicalOrigin}/#website`;
    const organization = {
      "@type": "Organization",
      "@id": organizationId,
      name: "MediaHedge",
      url: "https://mediahedge.com/",
      logo: {
        "@type": "ImageObject",
        url: socialImageUrl
      }
    };
    const website = {
      "@type": "WebSite",
      "@id": websiteId,
      url: `${canonicalOrigin}/`,
      name: siteName,
      alternateName: "MediaHedge Knowledgebase",
      description: seoPages.get(homePagePath)?.description || metadata.description,
      publisher: { "@id": organizationId },
      inLanguage: "en-US"
    };
    const graph = [organization, website];

    if (pagePath === homePagePath) {
      graph.push({
        "@type": "WebPage",
        "@id": `${canonicalUrl}#webpage`,
        url: canonicalUrl,
        name: metadata.title,
        description: metadata.description,
        isPartOf: { "@id": websiteId },
        about: { "@id": organizationId },
        dateModified: metadata.updated,
        inLanguage: "en-US"
      });
    } else {
      graph.push({
        "@type": "Article",
        "@id": `${canonicalUrl}#article`,
        mainEntityOfPage: { "@id": `${canonicalUrl}#webpage` },
        headline: metadata.title,
        description: metadata.description,
        image: [socialImageUrl],
        dateModified: metadata.updated,
        author: { "@id": organizationId },
        publisher: { "@id": organizationId },
        isPartOf: { "@id": websiteId },
        inLanguage: "en-US"
      });
      graph.push({
        "@type": "BreadcrumbList",
        "@id": `${canonicalUrl}#breadcrumb`,
        itemListElement: [
          {
            "@type": "ListItem",
            position: 1,
            name: "Media Finance Guide",
            item: canonicalUrlForPage(homePagePath)
          },
          {
            "@type": "ListItem",
            position: 2,
            name: metadata.title,
            item: canonicalUrl
          }
        ]
      });
      graph.push({
        "@type": "WebPage",
        "@id": `${canonicalUrl}#webpage`,
        url: canonicalUrl,
        name: metadata.title,
        description: metadata.description,
        breadcrumb: { "@id": `${canonicalUrl}#breadcrumb` },
        isPartOf: { "@id": websiteId },
        dateModified: metadata.updated,
        inLanguage: "en-US"
      });
    }

    let script = document.getElementById("mh-seo-jsonld");
    if (!script) {
      script = document.createElement("script");
      script.id = "mh-seo-jsonld";
      script.type = "application/ld+json";
      document.head.append(script);
    }
    const json = JSON.stringify({ "@context": "https://schema.org", "@graph": graph }).replaceAll("<", "\\u003c");
    if (script.textContent !== json) script.textContent = json;
  };

  const applySeoMetadata = () => {
    seoUpdateScheduled = false;
    const pagePath = pagePathForLocation();
    const metadata = pagePath ? seoPages.get(pagePath) : undefined;
    if (!metadata) return;

    const canonicalUrl = canonicalUrlForPage(pagePath);
    const socialType = pagePath === homePagePath ? "website" : "article";
    document.documentElement.lang = "en";
    if (document.title !== metadata.seoTitle) document.title = metadata.seoTitle;
    setCanonical(canonicalUrl);
    setMeta("name", "description", metadata.description);
    setMeta("name", "robots", "index,follow,max-image-preview:large,max-snippet:-1,max-video-preview:-1");
    setMeta("property", "og:type", socialType);
    setMeta("property", "og:site_name", siteName);
    setMeta("property", "og:title", metadata.seoTitle);
    setMeta("property", "og:description", metadata.description);
    setMeta("property", "og:url", canonicalUrl);
    setMeta("property", "og:image", socialImageUrl);
    setMeta("property", "og:image:alt", "MediaHedge film and television finance knowledgebase");
    setMeta("name", "twitter:card", "summary_large_image");
    setMeta("name", "twitter:title", metadata.seoTitle);
    setMeta("name", "twitter:description", metadata.description);
    setMeta("name", "twitter:image", socialImageUrl);
    setMeta("name", "twitter:image:alt", "MediaHedge film and television finance knowledgebase");
    setStructuredData(pagePath, metadata, canonicalUrl);
  };

  const scheduleSeoMetadata = () => {
    if (seoUpdateScheduled) return;
    seoUpdateScheduled = true;
    window.queueMicrotask(applySeoMetadata);
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

  const getContentRoot = () =>
    document.querySelector(".site-body-center-column") ||
    document.querySelector(".markdown-rendered")?.parentElement;

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

  const observeSeoMetadata = () => {
    const contentRoot = getContentRoot();
    if (!contentRoot || contentRoot === observedContentRoot) return;

    seoObserver?.disconnect();
    observedContentRoot = contentRoot;
    seoObserver = new MutationObserver(scheduleSeoMetadata);
    seoObserver.observe(contentRoot, { childList: true, subtree: true });
  };

  const start = () => {
    scheduleReaderNavigation();
    scheduleSeoMetadata();
    observeReaderNavigation();
    observeSeoMetadata();
    window.addEventListener("popstate", scheduleSeoMetadata);

    const layoutRoot = document.querySelector(".site-body") || document.body;
    layoutObserver = new MutationObserver(() => {
      if (getNavigationRoot() !== observedNavigationRoot) {
        observeReaderNavigation();
        scheduleReaderNavigation();
      }
      if (getContentRoot() !== observedContentRoot) {
        observeSeoMetadata();
        scheduleSeoMetadata();
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

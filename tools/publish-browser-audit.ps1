[CmdletBinding()]
param(
    [string]$SiteUrl = 'https://mediafinance.guide',
    [int]$TimeoutSeconds = 30,
    [switch]$UseLocalAssets
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'browser-audit-lib.ps1')

$session = $null
try {
    $session = Start-BrowserAuditSession -TimeoutSeconds $TimeoutSeconds
    $socket = $session.Socket
    if ($UseLocalAssets) {
        [void](Invoke-CdpCommand -Socket $socket -Method 'Network.enable')
        [void](Invoke-CdpCommand -Socket $socket -Method 'Network.setBlockedURLs' -Parameters @{ urls = @('*publish.js*', '*publish.css*') })
    }
    function Initialize-LocalAssets {
        if (-not $UseLocalAssets) { return }
        Wait-ForBrowserCondition -Socket $socket -TimeoutSeconds $TimeoutSeconds `
            -Expression "document.readyState === 'complete' && !!document.querySelector('.markdown-rendered h1:not(.page-header)')" `
            -FailureMessage 'Native article did not render before local asset testing.'
        $vault = Split-Path -Parent $PSScriptRoot
        $css = [IO.File]::ReadAllText((Join-Path $vault 'publish.css')) | ConvertTo-Json -Compress
        [void](Invoke-BrowserExpression -Socket $socket -Expression "(() => { const style = document.createElement('style'); style.textContent = $css; document.head.append(style); return true; })()")
        [void](Invoke-BrowserExpression -Socket $socket -Expression ([IO.File]::ReadAllText((Join-Path $vault 'publish.js')) + ';true'))
    }
    $legacyWikiUrl = $SiteUrl.TrimEnd('/') + '/wiki'
    if ($UseLocalAssets) { $legacyWikiUrl = $SiteUrl.TrimEnd('/') + '/MediaHedge+Knowledgebase' }
    [void](Invoke-CdpCommand -Socket $socket -Method 'Page.navigate' -Parameters @{ url = $legacyWikiUrl })
    Initialize-LocalAssets
    $legacyRedirectExpression = "decodeURIComponent(window.location.pathname).replaceAll('+', ' ').replace(/\/+$/, '') === '/MediaHedge Knowledgebase' && document.readyState === 'complete' && !!document.querySelector('input.search-bar') && !!document.querySelector('.nav-view-outer') && [...document.querySelectorAll('.markdown-rendered h1:not(.page-header)')].some((heading) => heading.innerText.trim() === 'MediaHedge Knowledgebase' && getComputedStyle(heading).display !== 'none' && getComputedStyle(heading).visibility !== 'hidden') && !document.body.innerText.includes('This page does not exist')"
    try {
        Wait-ForBrowserCondition -Socket $socket -TimeoutSeconds $TimeoutSeconds `
            -Expression $legacyRedirectExpression `
            -FailureMessage 'Legacy /wiki route did not redirect to the published knowledgebase home page.'
    } catch {
        $legacyState = Invoke-BrowserExpression -Socket $socket -Expression @'
(() => ({
  href: window.location.href,
  pathname: window.location.pathname,
  readyState: document.readyState,
  hasSearch: !!document.querySelector('input.search-bar'),
  hasNavigation: !!document.querySelector('.nav-view-outer'),
  hasHomeHeading: [...document.querySelectorAll('h1')].some((heading) => heading.innerText.trim() === 'MediaHedge Knowledgebase'),
  hasVisibleNotFound: document.body.innerText.includes('This page does not exist')
}))()
'@
        throw "$($_.Exception.Message) State: $($legacyState | ConvertTo-Json -Compress)"
    }

    $homeSeo = Invoke-BrowserExpression -Socket $socket -Expression @'
(() => {
  let jsonLd = {};
  try { jsonLd = JSON.parse(document.getElementById('mh-seo-jsonld')?.textContent || '{}'); } catch {}
  const schemaTypes = (jsonLd['@graph'] || []).map((node) => node['@type']);
  const visibleH1s = [...document.querySelectorAll('h1')].filter((heading) => {
    const style = getComputedStyle(heading);
    return style.display !== 'none' && style.visibility !== 'hidden';
  }).map((heading) => heading.innerText.trim());
  return {
    title: document.title,
    description: document.querySelector('meta[name="description"]')?.content || '',
    canonical: document.querySelector('link[rel="canonical"]')?.href || '',
    robots: document.querySelector('meta[name="robots"]')?.content || '',
    ogTitle: document.querySelector('meta[property="og:title"]')?.content || '',
    twitterCard: document.querySelector('meta[name="twitter:card"]')?.content || '',
    schemaTypes,
    visibleH1s
  };
})()
'@
    if ($homeSeo.title -ne 'Film and Television Finance Guide | MediaHedge' -or
        $homeSeo.description -notmatch '^Explore film and television finance' -or
        $homeSeo.canonical -ne "$($SiteUrl.TrimEnd('/'))/MediaHedge+Knowledgebase" -or
        $homeSeo.robots -notmatch 'index,follow' -or
        $homeSeo.ogTitle -ne $homeSeo.title -or
        $homeSeo.twitterCard -ne 'summary_large_image' -or
        'Organization' -notin @($homeSeo.schemaTypes) -or
        'WebSite' -notin @($homeSeo.schemaTypes) -or
        'WebPage' -notin @($homeSeo.schemaTypes) -or
        @($homeSeo.visibleH1s).Count -ne 1 -or
        $homeSeo.visibleH1s[0] -ne 'MediaHedge Knowledgebase') {
        throw "Published home page is missing complete SEO metadata or a single reader-facing H1. State: $($homeSeo | ConvertTo-Json -Compress -Depth 5)"
    }

    $searchStarted = Invoke-BrowserExpression -Socket $socket -Expression @'
(() => {
  const input = document.querySelector('input.search-bar');
  if (!input) return false;
  const setter = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value').set;
  setter.call(input, 'cash');
  input.dispatchEvent(new InputEvent('input', { bubbles: true, inputType: 'insertText', data: 'cash' }));
  return true;
})()
'@
    if (-not $searchStarted) { throw 'Published search input could not be exercised.' }
    Wait-ForBrowserCondition -Socket $socket -TimeoutSeconds $TimeoutSeconds `
        -Expression "document.querySelectorAll('.search-results .suggestion-item').length > 0" `
        -FailureMessage 'Published search returned no live type-ahead suggestions for cash.'

    $libraryExpanded = Invoke-BrowserExpression -Socket $socket -Expression @'
(() => {
  const library = document.querySelector('.nav-view-outer .tree-item-self[data-path="wiki"]');
  if (!library) return false;
  if (!document.querySelector('.nav-view-outer .tree-item-self[data-path="wiki/concepts"]')) {
    (library.querySelector(':scope > .collapse-icon') || library).click();
  }
  return true;
})()
'@
    if (-not $libraryExpanded) { throw 'Published Knowledgebase Library navigation could not be exercised.' }
    $conceptNavigationExpression = @'
!!document.querySelector('.nav-view-outer .tree-item-self[data-path="wiki/concepts"]')
'@
    try {
        Wait-ForBrowserCondition -Socket $socket -TimeoutSeconds $TimeoutSeconds `
            -Expression $conceptNavigationExpression `
            -FailureMessage 'Published Knowledgebase Library did not reveal its reader-facing category navigation.'
    } catch {
        $navigationState = Invoke-BrowserExpression -Socket $socket -Expression @'
(() => {
  const library = document.querySelector('.nav-view-outer .tree-item-self[data-path="wiki"]');
  const parent = library?.parentElement;
  return {
    libraryClass: library?.className || '',
    ariaExpanded: library?.getAttribute('aria-expanded') || '',
    iconClass: library?.querySelector('.collapse-icon')?.className || '',
    parentClass: parent?.className || '',
    childPaths: [...(parent?.querySelectorAll('[data-path]') || [])].map((node) => node.dataset.path).slice(0, 10)
  };
})()
'@
        throw "$($_.Exception.Message) State: $($navigationState | ConvertTo-Json -Compress)"
    }
    $friendlyConceptExpression = @'
[...document.querySelectorAll('.nav-view-outer .tree-item-inner')]
  .some((node) => node.textContent.trim() === 'Financing Essentials')
'@
    Wait-ForBrowserCondition -Socket $socket -TimeoutSeconds $TimeoutSeconds `
        -Expression $friendlyConceptExpression `
        -FailureMessage 'Published navigation did not relabel the expanded concepts folder as Financing Essentials.'

    $result = Invoke-BrowserExpression -Socket $socket -Expression @'
(() => {
  const input = document.querySelector('input.search-bar');
  const inputRect = input?.getBoundingClientRect();
  const results = document.querySelector('.search-results');
  const options = [...document.querySelectorAll('.search-results .suggestion-item')];
  const titles = [...document.querySelectorAll('.search-results .suggestion-title')].map((node) => node.textContent.trim());
  const labels = [...document.querySelectorAll('.nav-view-outer .tree-item-inner')].map((node) => node.textContent.trim());
  const shortcut = document.querySelector('.mh-navigator-shortcut a');
  const continueHeading = [...document.querySelectorAll('h2')].find((node) => node.textContent.trim() === 'Continue Exploring');
  const footerContainer = continueHeading?.closest('.el-h2')?.nextElementSibling || continueHeading?.nextElementSibling;
  const footerLinks = [...(footerContainer?.querySelectorAll('a') || [])].map((node) => node.href);
  return {
    searchVisible: !!inputRect && inputRect.width > 0 && inputRect.height > 0,
    suggestionCount: titles.length,
    suggestionTitles: titles.slice(0, 5),
    accessibleCombobox: input?.getAttribute('role') === 'combobox' &&
      input?.getAttribute('aria-autocomplete') === 'list' &&
      input?.getAttribute('aria-expanded') === 'true' &&
      input?.getAttribute('aria-controls') === results?.id &&
      input?.getAttribute('aria-describedby') === 'mh-search-status',
    accessibleListbox: results?.getAttribute('role') === 'listbox' &&
      options.length > 0 && options.every((item) => item.getAttribute('role') === 'option'),
    announcedResults: /^\d+ suggestions? available\./.test(document.getElementById('mh-search-status')?.textContent || ''),
    hasFriendlyLibrary: labels.includes('Knowledgebase Library'),
    hasFriendlyConcepts: labels.includes('Financing Essentials'),
    shortcutText: shortcut?.textContent.trim() || '',
    shortcutHref: shortcut?.href || '',
    navigationLabels: labels.slice(0, 20),
    footerHasNavigator: footerLinks.some((href) => href.endsWith('/wiki/syntheses/site-navigator'))
  };
})()
'@

    if (-not $result.searchVisible) { throw 'Published search input is not visibly available.' }
    if ([int]$result.suggestionCount -lt 1) { throw 'Published search suggestions are empty.' }
    if (@($result.suggestionTitles | Where-Object { $_ -match '(?i)cash control' }).Count -eq 0) {
        throw "Published search suggestions did not include Cash Control: $($result.suggestionTitles -join ', ')"
    }
    if (-not $result.accessibleCombobox -or -not $result.accessibleListbox -or -not $result.announcedResults) {
        throw 'Published search is missing its complete combobox, listbox, option or live-status accessibility semantics.'
    }
    if (-not $result.hasFriendlyLibrary -or -not $result.hasFriendlyConcepts) {
        throw "Published navigation is missing its reader-facing Knowledgebase Library or Financing Essentials labels. Visible labels: $($result.navigationLabels -join ', ')"
    }
    $expectedNavigator = $SiteUrl.TrimEnd('/') + '/wiki/syntheses/site-navigator'
    if ($result.shortcutText -ne 'Site Navigator' -or $result.shortcutHref.TrimEnd('/') -ne $expectedNavigator) {
        throw 'Published navigation is missing the canonical Site Navigator shortcut.'
    }
    if (-not $result.footerHasNavigator) {
        throw 'Published home-page footer is missing the Site Navigator route.'
    }

    [void](Invoke-BrowserExpression -Socket $socket -Expression "document.querySelector('input.search-bar').focus(); true")
    foreach ($type in @('rawKeyDown', 'keyUp')) {
        [void](Invoke-CdpCommand -Socket $socket -Method 'Input.dispatchKeyEvent' -Parameters @{ type = $type; key = 'Escape'; code = 'Escape'; windowsVirtualKeyCode = 27 })
    }
    Wait-ForBrowserCondition -Socket $socket -TimeoutSeconds $TimeoutSeconds `
        -Expression "document.querySelector('input.search-bar').value === '' && document.querySelector('input.search-bar').getAttribute('aria-expanded') === 'false'" `
        -FailureMessage 'Escape did not clear and dismiss the native search results.'
    $folderBefore = Invoke-BrowserExpression -Socket $socket -Expression @'
(() => { const folder = document.querySelector('.tree-item-self[data-path="wiki"]'); folder.focus(); return folder.getAttribute('aria-expanded'); })()
'@
    foreach ($type in @('rawKeyDown', 'keyUp')) {
        [void](Invoke-CdpCommand -Socket $socket -Method 'Input.dispatchKeyEvent' -Parameters @{ type = $type; key = 'Enter'; code = 'Enter'; windowsVirtualKeyCode = 13 })
    }
    Wait-ForBrowserCondition -Socket $socket -TimeoutSeconds $TimeoutSeconds `
        -Expression "document.querySelector('.tree-item-self[data-path=wiki]').getAttribute('aria-expanded') !== '$folderBefore'" `
        -FailureMessage 'Enter did not toggle the keyboard-focused navigation folder.'

    $conceptUrl = $SiteUrl.TrimEnd('/') + '/wiki/concepts/loan-sizing'
    [void](Invoke-CdpCommand -Socket $socket -Method 'Page.navigate' -Parameters @{ url = $conceptUrl })
    Initialize-LocalAssets
    try {
        Wait-ForBrowserCondition -Socket $socket -TimeoutSeconds $TimeoutSeconds `
            -Expression "location.pathname === '/wiki/concepts/loan-sizing' && document.readyState === 'complete' && !!document.getElementById('mh-seo-jsonld') && document.querySelector('h1.publish-article-heading')?.innerText.trim() === 'Loan Sizing' && !!document.querySelector('.mh-diagram-tools a')" `
            -FailureMessage 'Representative concept did not finish loading its SEO runtime.'
    } catch {
        $conceptState = Invoke-BrowserExpression -Socket $socket -Expression @'
(() => ({
  href: window.location.href,
  readyState: document.readyState,
  title: document.title,
  canonical: document.querySelector('link[rel="canonical"]')?.href || '',
  hasSeoRuntime: !!document.getElementById('mh-seo-jsonld'),
  bodyPreview: document.body.innerText.slice(0, 180)
}))()
'@
        throw "$($_.Exception.Message) State: $($conceptState | ConvertTo-Json -Compress)"
    }
    $conceptSeo = Invoke-BrowserExpression -Socket $socket -Expression @'
(() => {
  let jsonLd = {};
  try { jsonLd = JSON.parse(document.getElementById('mh-seo-jsonld')?.textContent || '{}'); } catch {}
  const schemaTypes = (jsonLd['@graph'] || []).map((node) => node['@type']);
  const visibleH1s = [...document.querySelectorAll('h1')].filter((heading) => {
    const style = getComputedStyle(heading);
    return style.display !== 'none' && style.visibility !== 'hidden';
  }).map((heading) => heading.innerText.trim());
  return {
    title: document.title,
    description: document.querySelector('meta[name="description"]')?.content || '',
    canonical: document.querySelector('link[rel="canonical"]')?.href || '',
    ogUrl: document.querySelector('meta[property="og:url"]')?.content || '',
    ogImage: document.querySelector('meta[property="og:image"]')?.content || '',
    schemaTypes,
    visibleH1s
  };
})()
'@
    if ($conceptSeo.title -ne 'Loan Sizing | Media Finance Guide' -or
        $conceptSeo.description -notmatch '^Learn how eligible collateral value' -or
        $conceptSeo.canonical -ne $conceptUrl -or
        $conceptSeo.ogUrl -ne $conceptUrl -or
        $conceptSeo.ogImage -notmatch '^https://publish-01\.obsidian\.md/access/.+/assets/mediahedge-banner\.jpg$' -or
        'Article' -notin @($conceptSeo.schemaTypes) -or
        'BreadcrumbList' -notin @($conceptSeo.schemaTypes) -or
        @($conceptSeo.visibleH1s).Count -ne 1 -or
        $conceptSeo.visibleH1s[0] -ne 'Loan Sizing') {
        throw "Published concept is missing complete SEO metadata or a single reader-facing H1. State: $($conceptSeo | ConvertTo-Json -Compress -Depth 5)"
    }

    # Obsidian virtualizes direct sizer children. A custom metadata sibling used
    # to be removed/reinserted every scroll, causing continuous backward drift.
    [void](Invoke-BrowserExpression -Socket $socket -Expression "document.querySelector('.mh-skip-link').click(); true")
    foreach ($delta in @(240, 180, 90, 30)) {
        [void](Invoke-CdpCommand -Socket $socket -Method 'Input.dispatchMouseEvent' -Parameters @{ type = 'mouseWheel'; x = 600; y = 400; deltaX = 0; deltaY = $delta })
        Start-Sleep -Milliseconds 60
    }
    Start-Sleep -Milliseconds 300
    $settled = Invoke-BrowserExpression -Socket $socket -Expression @'
(async () => {
  const article = document.querySelector('.markdown-rendered');
  const samples = [];
  for (let i = 0; i < 12; i++) { samples.push(article.scrollTop); await new Promise(resolve => setTimeout(resolve, 100)); }
  return { min: Math.min(...samples), max: Math.max(...samples), position: article.scrollTop,
    ownsSections: !document.querySelector('.markdown-preview-sizer > .mh-page-meta') };
})()
'@
    if (-not $settled.ownsSections -or $settled.position -lt 500 -or ($settled.max - $settled.min) -gt 2) {
        throw "Wheel motion continued after input ended or native sections were changed: $($settled | ConvertTo-Json -Compress)"
    }

    $reader = Invoke-BrowserExpression -Socket $socket -Expression @'
(() => {
  document.querySelector('.mh-skip-link')?.click();
  const frame = document.querySelector('.mh-scroll-region');
  const link = document.querySelector('.mh-diagram-tools a');
  return {
    skipFocus: document.activeElement.id === 'mh-reader-content',
    skipTop: document.getElementById('mh-reader-content').scrollTop === 0,
    editDate: /^Page Updated \d{4}-\d{2}-\d{2}$/.test(document.querySelector('.mh-page-meta time')?.textContent || ''),
    oneMetadataRow: document.querySelectorAll('.mh-page-meta').length === 1,
    policyReview: !!document.querySelector('.callout[data-callout="warning"]')?.innerText.includes('Policy Review Pending'),
    diagramLink: !!link && link.href === frame?.querySelector('img')?.src && link.rel === 'noopener'
  };
})()
'@
    foreach ($property in @('skipFocus', 'skipTop', 'editDate', 'oneMetadataRow', 'policyReview', 'diagramLink')) {
        if (-not $reader.$property) { throw "Live reader enhancement failed: $property" }
    }
    [void](Invoke-CdpCommand -Socket $socket -Method 'Emulation.setDeviceMetricsOverride' -Parameters @{ width = 390; height = 844; deviceScaleFactor = 1; mobile = $false })
    [void](Invoke-BrowserExpression -Socket $socket -Expression "document.querySelector('.mh-scroll-region').focus(); true")
    [void](Invoke-CdpCommand -Socket $socket -Method 'Input.dispatchKeyEvent' -Parameters @{ type = 'keyDown'; key = 'ArrowRight'; code = 'ArrowRight'; windowsVirtualKeyCode = 39 })
    [void](Invoke-CdpCommand -Socket $socket -Method 'Input.dispatchKeyEvent' -Parameters @{ type = 'keyUp'; key = 'ArrowRight'; code = 'ArrowRight'; windowsVirtualKeyCode = 39 })
    Wait-ForBrowserCondition -Socket $socket -TimeoutSeconds $TimeoutSeconds `
        -Expression "document.querySelector('.mh-scroll-region').scrollLeft > 0 && document.documentElement.scrollWidth <= innerWidth && getComputedStyle(document.activeElement).outlineStyle !== 'none'" `
        -FailureMessage 'Live mobile diagram did not scroll with keyboard input and visible focus, or the document overflowed.'

    $mobileWheel = Invoke-BrowserExpression -Socket $socket -Expression @'
(() => { const frame = document.querySelector('.mh-scroll-region'); const rect = frame.getBoundingClientRect();
  return { x: Math.max(25, Math.min(innerWidth - 25, rect.left + 60)), y: Math.max(60, Math.min(innerHeight - 60, rect.top + 80)), before: document.querySelector('.markdown-rendered').scrollTop }; })()
'@
    [void](Invoke-CdpCommand -Socket $socket -Method 'Input.dispatchMouseEvent' -Parameters @{ type = 'mouseWheel'; x = $mobileWheel.x; y = $mobileWheel.y; deltaX = 0; deltaY = 180 })
    Start-Sleep -Milliseconds 350
    $mobileAfter = Invoke-BrowserExpression -Socket $socket -Expression "document.querySelector('.markdown-rendered').scrollTop"
    if ($mobileAfter -le $mobileWheel.before) { throw 'Vertical wheel input over the mobile diagram failed to scroll the article.' }
    Start-Sleep -Milliseconds 700
    $mobileFinal = Invoke-BrowserExpression -Socket $socket -Expression "document.querySelector('.markdown-rendered').scrollTop"
    if ([Math]::Abs($mobileFinal - $mobileAfter) -gt 2) { throw 'Mobile article continued drifting after wheel input stopped.' }

    if ($UseLocalAssets) { Write-Output 'Prepublication mode used local assets on the native canonical home and concept routes; legacy redirect is checked only in live mode.' }
    Write-Output 'Reader behavior passed: SEO, search Escape, keyboard folder navigation, Site Navigator, visible metadata, skip-to-top, desktop wheel settling, mobile wheel chaining and keyboard diagrams'
} finally {
    Stop-BrowserAuditSession -Session $session
}

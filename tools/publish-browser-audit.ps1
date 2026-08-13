[CmdletBinding()]
param(
    [string]$SiteUrl = 'https://mediafinance.guide',
    [int]$TimeoutSeconds = 30
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'browser-audit-lib.ps1')

$session = $null
try {
    $session = Start-BrowserAuditSession -TimeoutSeconds $TimeoutSeconds
    $socket = $session.Socket
    $homeUrl = $SiteUrl.TrimEnd('/') + '/MediaHedge+Knowledgebase'
    [void](Invoke-CdpCommand -Socket $socket -Method 'Page.navigate' -Parameters @{ url = $homeUrl })
    Wait-ForBrowserCondition -Socket $socket -TimeoutSeconds $TimeoutSeconds `
        -Expression "document.readyState === 'complete' && !!document.querySelector('input.search-bar') && !!document.querySelector('.nav-view-outer')" `
        -FailureMessage 'Published home page did not load its search and navigation controls.'

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

    Write-Output 'Live reader behavior: accessible search suggestions, friendly navigation labels and Site Navigator footer passed'
} finally {
    Stop-BrowserAuditSession -Session $session
}

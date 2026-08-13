[CmdletBinding()]
param(
    [string]$VaultRoot,
    [int]$TimeoutSeconds = 20
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($VaultRoot)) {
    $VaultRoot = Split-Path -Parent $PSScriptRoot
}
$vault = (Resolve-Path -LiteralPath $VaultRoot).Path
. (Join-Path $vault 'tools\browser-audit-lib.ps1')

$fixturePath = (Resolve-Path -LiteralPath (Join-Path $vault 'tools\fixtures\publish-navigation.html')).Path
$fixtureUri = ([Uri]$fixturePath).AbsoluteUri
$session = $null
try {
    $session = Start-BrowserAuditSession -TimeoutSeconds $TimeoutSeconds
    $socket = $session.Socket
    [void](Invoke-CdpCommand -Socket $socket -Method 'Page.navigate' -Parameters @{ url = $fixtureUri })
    Wait-ForBrowserCondition -Socket $socket -TimeoutSeconds $TimeoutSeconds `
        -Expression "document.readyState === 'complete' && document.querySelector('input.search-bar')?.getAttribute('aria-expanded') === 'true'" `
        -FailureMessage 'Local Publish fixture did not initialize its enhanced search interface.'

    $initial = Invoke-BrowserExpression -Socket $socket -Expression @'
(() => {
  const input = document.querySelector('input.search-bar');
  const results = document.querySelector('.search-results');
  const options = [...document.querySelectorAll('.suggestion-item')];
  const selected = options.find((item) => item.getAttribute('aria-selected') === 'true');
  const labels = [...document.querySelectorAll('.nav-view-outer .tree-item-inner')].map((node) => node.textContent.trim());
  return {
    combobox: input?.getAttribute('role') === 'combobox',
    autocomplete: input?.getAttribute('aria-autocomplete') === 'list',
    controlsList: input?.getAttribute('aria-controls') === results?.id,
    describedByStatus: input?.getAttribute('aria-describedby') === 'mh-search-status',
    expanded: input?.getAttribute('aria-expanded') === 'true',
    activeDescendant: !!selected?.id && input?.getAttribute('aria-activedescendant') === selected.id,
    listbox: results?.getAttribute('role') === 'listbox',
    optionCount: options.filter((item) => item.getAttribute('role') === 'option').length,
    statusText: document.getElementById('mh-search-status')?.textContent || '',
    friendlyHome: labels.includes('Welcome & Start Here'),
    friendlyLibrary: labels.includes('Knowledgebase Library'),
    navigatorShortcut: document.querySelector('.mh-navigator-shortcut a')?.textContent.trim() === 'Site Navigator',
    frames: window.mhAnimationFrames
  };
})()
'@
    foreach ($property in @('combobox', 'autocomplete', 'controlsList', 'describedByStatus', 'expanded', 'activeDescendant', 'listbox', 'friendlyHome', 'friendlyLibrary', 'navigatorShortcut')) {
        if (-not $initial.$property) { throw "Local Publish fixture failed accessibility/navigation assertion: $property" }
    }
    if ([int]$initial.optionCount -ne 2 -or $initial.statusText -notmatch '^2 suggestions available\.') {
        throw 'Local Publish fixture did not expose two announced listbox options.'
    }

    Start-Sleep -Milliseconds 500
    $stableFrameCount = [int](Invoke-BrowserExpression -Socket $socket -Expression 'window.mhAnimationFrames')
    [void](Invoke-BrowserExpression -Socket $socket -Expression @'
(() => {
  const unrelated = document.createElement('p');
  unrelated.textContent = 'Unrelated reader-content mutation';
  document.getElementById('main-content').append(unrelated);
  return true;
})()
'@)
    Start-Sleep -Milliseconds 400
    $afterUnrelatedMutation = [int](Invoke-BrowserExpression -Socket $socket -Expression 'window.mhAnimationFrames')
    if ($afterUnrelatedMutation -ne $stableFrameCount) {
        $mutationState = Invoke-BrowserExpression -Socket $socket -Expression 'window.mhObservedMutations.slice(-12)'
        throw "An unrelated main-content mutation triggered reader-navigation work: $stableFrameCount -> $afterUnrelatedMutation. Mutations: $($mutationState | ConvertTo-Json -Compress)"
    }

    [void](Invoke-BrowserExpression -Socket $socket -Expression @'
(() => {
  const wrapper = document.createElement('div');
  wrapper.className = 'tree-item';
  const item = document.createElement('div');
  item.className = 'tree-item-self mod-collapsible is-clickable';
  item.dataset.path = 'wiki/concepts';
  const inner = document.createElement('div');
  inner.className = 'tree-item-inner';
  inner.textContent = 'concepts';
  item.append(inner);
  wrapper.append(item);
  document.querySelector('#wiki-folder > .tree-item-children').append(wrapper);
  return true;
})()
'@)
    Wait-ForBrowserCondition -Socket $socket -TimeoutSeconds $TimeoutSeconds `
        -Expression "[...document.querySelectorAll('.nav-view-outer .tree-item-inner')].some((node) => node.textContent.trim() === 'Financing Essentials')" `
        -FailureMessage 'Scoped observer did not enhance dynamically added navigation.'
    $afterRelevantMutation = [int](Invoke-BrowserExpression -Socket $socket -Expression 'window.mhAnimationFrames')
    if ($afterRelevantMutation -le $afterUnrelatedMutation) {
        throw 'Relevant navigation mutation did not schedule reader-navigation work.'
    }

    Write-Output 'Local Publish UI fixture: generated labels, ARIA combobox semantics and scoped observation passed'
} finally {
    Stop-BrowserAuditSession -Session $session
}

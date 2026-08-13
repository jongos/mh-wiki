[CmdletBinding()]
param(
    [string]$SiteUrl = 'https://mediafinance.guide',
    [int]$TimeoutSeconds = 30
)

$ErrorActionPreference = 'Stop'

function Get-AvailableBrowser {
    $candidates = @(
        (Join-Path $env:ProgramFiles 'Google\Chrome\Application\chrome.exe'),
        (Join-Path ${env:ProgramFiles(x86)} 'Google\Chrome\Application\chrome.exe'),
        (Join-Path $env:LOCALAPPDATA 'Google\Chrome\Application\chrome.exe'),
        (Join-Path $env:ProgramFiles 'Microsoft\Edge\Application\msedge.exe'),
        (Join-Path ${env:ProgramFiles(x86)} 'Microsoft\Edge\Application\msedge.exe')
    )
    foreach ($candidate in $candidates) {
        if (-not [string]::IsNullOrWhiteSpace($candidate) -and
            (Test-Path -LiteralPath $candidate -PathType Leaf)) {
            return $candidate
        }
    }
    throw 'Live Publish behavior audit requires Google Chrome or Microsoft Edge.'
}

function Get-AvailableTcpPort {
    $listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, 0)
    try {
        $listener.Start()
        return ([Net.IPEndPoint]$listener.LocalEndpoint).Port
    } finally {
        $listener.Stop()
    }
}

function Receive-WebSocketText {
    param([Net.WebSockets.ClientWebSocket]$Socket)

    $builder = [Text.StringBuilder]::new()
    $buffer = New-Object byte[] 65536
    do {
        $segment = [ArraySegment[byte]]::new($buffer)
        $result = $Socket.ReceiveAsync($segment, [Threading.CancellationToken]::None).GetAwaiter().GetResult()
        if ($result.MessageType -eq [Net.WebSockets.WebSocketMessageType]::Close) {
            throw 'Headless browser closed its debugging connection unexpectedly.'
        }
        [void]$builder.Append([Text.Encoding]::UTF8.GetString($buffer, 0, $result.Count))
    } until ($result.EndOfMessage)
    return $builder.ToString()
}

$script:cdpCommandId = 0
function Invoke-CdpCommand {
    param(
        [Net.WebSockets.ClientWebSocket]$Socket,
        [string]$Method,
        [hashtable]$Parameters = @{}
    )

    $script:cdpCommandId++
    $id = $script:cdpCommandId
    $payload = @{
        id = $id
        method = $Method
        params = $Parameters
    } | ConvertTo-Json -Compress -Depth 20
    $bytes = [Text.Encoding]::UTF8.GetBytes($payload)
    [void]$Socket.SendAsync(
        [ArraySegment[byte]]::new($bytes),
        [Net.WebSockets.WebSocketMessageType]::Text,
        $true,
        [Threading.CancellationToken]::None
    ).GetAwaiter().GetResult()

    while ($true) {
        $message = (Receive-WebSocketText -Socket $Socket) | ConvertFrom-Json
        if ($message.id -ne $id) { continue }
        if ($null -ne $message.error) {
            throw "Headless browser command failed ($Method): $($message.error.message)"
        }
        return $message.result
    }
}

function Invoke-BrowserExpression {
    param(
        [Net.WebSockets.ClientWebSocket]$Socket,
        [string]$Expression
    )

    $response = Invoke-CdpCommand -Socket $Socket -Method 'Runtime.evaluate' -Parameters @{
        expression = $Expression
        returnByValue = $true
        awaitPromise = $true
    }
    if ($null -ne $response.exceptionDetails) {
        $detail = $response.exceptionDetails.exception.description
        if ([string]::IsNullOrWhiteSpace([string]$detail)) { $detail = $response.exceptionDetails.text }
        throw "Live page evaluation failed: $detail"
    }
    return $response.result.value
}

function Wait-ForBrowserCondition {
    param(
        [Net.WebSockets.ClientWebSocket]$Socket,
        [string]$Expression,
        [string]$FailureMessage,
        [int]$TimeoutSeconds
    )

    $deadline = [DateTime]::UtcNow.AddSeconds($TimeoutSeconds)
    do {
        try {
            if (Invoke-BrowserExpression -Socket $Socket -Expression $Expression) { return }
        } catch {
            if ([DateTime]::UtcNow -ge $deadline) { throw }
        }
        Start-Sleep -Milliseconds 200
    } while ([DateTime]::UtcNow -lt $deadline)
    throw $FailureMessage
}

function Remove-AuditDirectory {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) { return }
    $resolved = [IO.Path]::GetFullPath($Path).TrimEnd([char[]]'\/')
    $tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd([char[]]'\/') + [IO.Path]::DirectorySeparatorChar
    if (-not $resolved.StartsWith($tempRoot, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to remove a browser-audit directory outside the system temporary directory: $resolved"
    }
    Remove-Item -LiteralPath $resolved -Recurse -Force
}

$browserPath = Get-AvailableBrowser
$port = Get-AvailableTcpPort
$profile = Join-Path ([IO.Path]::GetTempPath()) ("MediaHedge-Publish-Audit-" + [Guid]::NewGuid().ToString('N'))
$socket = $null
$browserProcess = $null

try {
    [void](New-Item -ItemType Directory -Path $profile)
    $arguments = @(
        '--headless=new',
        '--disable-background-networking',
        '--disable-component-update',
        '--disable-default-apps',
        '--disable-extensions',
        '--disable-gpu',
        '--no-default-browser-check',
        '--no-first-run',
        "--remote-debugging-port=$port",
        "--user-data-dir=$profile",
        'about:blank'
    )
    $browserProcess = Start-Process -FilePath $browserPath -ArgumentList $arguments -PassThru -WindowStyle Hidden

    $endpoint = "http://127.0.0.1:$port/json/list"
    $deadline = [DateTime]::UtcNow.AddSeconds($TimeoutSeconds)
    $targets = $null
    do {
        try {
            $targets = Invoke-RestMethod -Uri $endpoint -Method Get -TimeoutSec 2
        } catch {
            Start-Sleep -Milliseconds 200
        }
    } while ($null -eq $targets -and [DateTime]::UtcNow -lt $deadline)
    if ($null -eq $targets) { throw 'Headless browser did not expose its debugging endpoint.' }

    $pageTarget = @($targets | Where-Object { $_.type -eq 'page' } | Select-Object -First 1)[0]
    if ($null -eq $pageTarget -or [string]::IsNullOrWhiteSpace([string]$pageTarget.webSocketDebuggerUrl)) {
        throw 'Headless browser did not expose a page target.'
    }

    $socket = [Net.WebSockets.ClientWebSocket]::new()
    [void]$socket.ConnectAsync([Uri]$pageTarget.webSocketDebuggerUrl, [Threading.CancellationToken]::None).GetAwaiter().GetResult()
    [void](Invoke-CdpCommand -Socket $socket -Method 'Page.enable')
    [void](Invoke-CdpCommand -Socket $socket -Method 'Runtime.enable')

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
  const titles = [...document.querySelectorAll('.search-results .suggestion-title')].map((node) => node.textContent.trim());
  const labels = [...document.querySelectorAll('.nav-view-outer .tree-item-inner')].map((node) => node.textContent.trim());
  const shortcut = document.querySelector('.mh-navigator-shortcut a');
  const continueHeading = [...document.querySelectorAll('h2')].find((node) => node.textContent.trim() === 'Continue Exploring');
  const footerContainer = continueHeading?.closest('.el-h2')?.nextElementSibling || continueHeading?.nextElementSibling;
  const footerLinks = [...(footerContainer?.querySelectorAll('a') || [])].map((node) => node.href);
  return {
    url: location.href,
    searchVisible: !!inputRect && inputRect.width > 0 && inputRect.height > 0,
    suggestionCount: titles.length,
    suggestionTitles: titles.slice(0, 5),
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

    Write-Output 'Live reader behavior: search suggestions, friendly navigation labels and Site Navigator footer passed'
} finally {
    if ($null -ne $socket) {
        try { [void](Invoke-CdpCommand -Socket $socket -Method 'Browser.close') } catch {}
        $socket.Dispose()
    }
    if ($null -ne $browserProcess -and -not $browserProcess.HasExited) {
        try { [void]$browserProcess.WaitForExit(3000) } catch {}
        if (-not $browserProcess.HasExited) { Stop-Process -Id $browserProcess.Id -Force -ErrorAction SilentlyContinue }
    }
    Start-Sleep -Milliseconds 300
    Remove-AuditDirectory -Path $profile
}

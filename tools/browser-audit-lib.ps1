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
    throw 'Browser-backed audits require Google Chrome or Microsoft Edge.'
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

function Remove-BrowserAuditDirectory {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) { return }
    $resolved = [IO.Path]::GetFullPath($Path).TrimEnd([char[]]'\/')
    $tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd([char[]]'\/') + [IO.Path]::DirectorySeparatorChar
    if (-not $resolved.StartsWith($tempRoot, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to remove a browser-audit directory outside the system temporary directory: $resolved"
    }
    Remove-Item -LiteralPath $resolved -Recurse -Force
}

function Start-BrowserAuditSession {
    param(
        [int]$TimeoutSeconds = 30,
        [ValidateRange(1, 5)]
        [int]$MaxAttempts = 3
    )

    $browserPath = Get-AvailableBrowser
    $attemptErrors = [Collections.Generic.List[string]]::new()
    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
        $port = Get-AvailableTcpPort
        $profile = Join-Path ([IO.Path]::GetTempPath()) ("MediaHedge-Publish-Audit-" + [Guid]::NewGuid().ToString('N'))
        $browserProcess = $null
        $socket = $null
        try {
            [void](New-Item -ItemType Directory -Path $profile)
            $arguments = @(
                '--headless=new',
                '--allow-file-access-from-files',
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
            if ($null -eq $targets) { throw "Headless browser did not expose its debugging endpoint on port $port." }

            $pageTarget = @($targets | Where-Object { $_.type -eq 'page' } | Select-Object -First 1)[0]
            if ($null -eq $pageTarget -or [string]::IsNullOrWhiteSpace([string]$pageTarget.webSocketDebuggerUrl)) {
                throw 'Headless browser did not expose a page target.'
            }

            $socket = [Net.WebSockets.ClientWebSocket]::new()
            [void]$socket.ConnectAsync([Uri]$pageTarget.webSocketDebuggerUrl, [Threading.CancellationToken]::None).GetAwaiter().GetResult()
            [void](Invoke-CdpCommand -Socket $socket -Method 'Page.enable')
            [void](Invoke-CdpCommand -Socket $socket -Method 'Runtime.enable')

            return [pscustomobject]@{
                Process = $browserProcess
                Profile = $profile
                Socket = $socket
            }
        } catch {
            $attemptErrors.Add("attempt $attempt on port ${port}: $($_.Exception.Message)")
            if ($null -ne $socket) { $socket.Dispose() }
            if ($null -ne $browserProcess -and -not $browserProcess.HasExited) {
                Stop-Process -Id $browserProcess.Id -Force -ErrorAction SilentlyContinue
            }
            Remove-BrowserAuditDirectory -Path $profile
            if ($attempt -lt $MaxAttempts) { Start-Sleep -Milliseconds (250 * $attempt) }
        }
    }

    throw "Headless browser failed after $MaxAttempts attempts. $($attemptErrors -join ' | ')"
}

function Stop-BrowserAuditSession {
    param($Session)

    if ($null -eq $Session) { return }
    if ($null -ne $Session.Socket) {
        try { [void](Invoke-CdpCommand -Socket $Session.Socket -Method 'Browser.close') } catch {}
        $Session.Socket.Dispose()
    }
    if ($null -ne $Session.Process -and -not $Session.Process.HasExited) {
        try { [void]$Session.Process.WaitForExit(3000) } catch {}
        if (-not $Session.Process.HasExited) {
            Stop-Process -Id $Session.Process.Id -Force -ErrorAction SilentlyContinue
        }
    }
    Start-Sleep -Milliseconds 300
    Remove-BrowserAuditDirectory -Path $Session.Profile
}

[CmdletBinding()]
param(
    [string]$VaultRoot,
    [string]$SiteUrl = 'https://mediafinance.guide',
    [switch]$SkipBrowserAudit
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($VaultRoot)) {
    $VaultRoot = Split-Path -Parent $PSScriptRoot
}
$vault = (Resolve-Path -LiteralPath $VaultRoot).Path
$strictUtf8 = New-Object System.Text.UTF8Encoding($false, $true)

function Read-Utf8Text {
    param([string]$Path)
    return [IO.File]::ReadAllText($Path, $script:strictUtf8)
}

function Get-Frontmatter {
    param([string]$Content)
    $match = [regex]::Match($Content, '\A---\r?\n(?<yaml>.*?)\r?\n---(?:\r?\n|$)', 'Singleline')
    if ($match.Success) { return $match.Groups['yaml'].Value }
    return ''
}

$desired = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
$publicMarkdown = Get-ChildItem -LiteralPath $vault -Recurse -File -Filter '*.md' |
    Where-Object { $_.FullName -notmatch '[\\/]\.git(?:[\\/]|$)' -and $_.FullName -notmatch '[\\/]\.tmp_' } |
    Where-Object {
        $content = Read-Utf8Text -Path $_.FullName
        (Get-Frontmatter -Content $content) -match '(?m)^publish:\s*true\s*$'
    }

foreach ($file in $publicMarkdown) {
    $relative = $file.FullName.Substring($vault.Length).TrimStart([char[]]'\/').Replace('\', '/')
    [void]$desired.Add($relative)
    $content = Read-Utf8Text -Path $file.FullName
    foreach ($embed in [regex]::Matches($content, '!\[\[([^\]\r\n]+)\]\]')) {
        $target = $embed.Groups[1].Value.Split('|')[0].Split('#')[0].Trim()
        if ($target -notlike 'assets/*') { continue }
        $assetPath = Join-Path $vault $target.Replace('/', [IO.Path]::DirectorySeparatorChar)
        if (-not (Test-Path -LiteralPath $assetPath -PathType Leaf)) {
            throw "Published page references a missing asset: $relative -> $target"
        }
        [void]$desired.Add($target)
    }
}

$publishCss = Join-Path $vault 'publish.css'
if (-not (Test-Path -LiteralPath $publishCss -PathType Leaf)) {
    throw 'Missing root publish.css'
}
[void]$desired.Add('publish.css')

$publishJs = Join-Path $vault 'publish.js'
if (-not (Test-Path -LiteralPath $publishJs -PathType Leaf)) {
    throw 'Missing root publish.js'
}
[void]$desired.Add('publish.js')

$publishConfigPath = Join-Path $vault '.obsidian\publish.json'
if (-not (Test-Path -LiteralPath $publishConfigPath -PathType Leaf)) {
    throw 'Missing .obsidian/publish.json'
}
$publishConfig = (Read-Utf8Text -Path $publishConfigPath) | ConvertFrom-Json
if ([string]$publishConfig.siteId -notmatch '^[0-9a-fA-F]{32}$' -or
    [string]$publishConfig.host -notmatch '^publish-[0-9]+\.obsidian\.md$') {
    throw 'Invalid Obsidian Publish configuration'
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$cacheUri = "https://$($publishConfig.host)/cache/$($publishConfig.siteId)"
try {
    $remote = Invoke-RestMethod -Uri $cacheUri -Method Get -TimeoutSec 30
} catch {
    throw "Unable to read the public Publish inventory: $($_.Exception.Message)"
}

$remotePaths = @($remote.PSObject.Properties.Name)
$missing = @($desired | Where-Object { $remotePaths -notcontains $_ } | Sort-Object)
$extra = @($remotePaths | Where-Object { -not $desired.Contains($_) } | Sort-Object)

Write-Output 'MediaHedge Publish audit'
Write-Output "Expected public files: $($desired.Count)"
Write-Output "Remote public files: $($remotePaths.Count)"
Write-Output "Missing: $($missing.Count)"
foreach ($path in $missing) { Write-Output "MISSING: $path" }
Write-Output "Unexpected/private: $($extra.Count)"
foreach ($path in $extra) { Write-Output "UNEXPECTED: $path" }

if ($missing.Count -gt 0 -or $extra.Count -gt 0) {
    exit 1
}

function Get-RemoteFileHash {
    param(
        [string]$Uri,
        [string]$Label
    )

    $temporaryFile = Join-Path ([IO.Path]::GetTempPath()) ("MediaHedge-Publish-" + [Guid]::NewGuid().ToString('N'))
    try {
        Invoke-WebRequest -Uri $Uri -UseBasicParsing -TimeoutSec 30 -OutFile $temporaryFile
        return (Get-FileHash -LiteralPath $temporaryFile -Algorithm SHA256).Hash
    } catch {
        throw "Unable to download deployed ${Label}: $($_.Exception.Message)"
    } finally {
        if (Test-Path -LiteralPath $temporaryFile) { Remove-Item -LiteralPath $temporaryFile -Force }
    }
}

$siteRoot = $SiteUrl.TrimEnd('/')
$liveRoutes = @(
    @{ Label = 'homepage'; Uri = "$siteRoot/MediaHedge+Knowledgebase" },
    @{ Label = 'Site Navigator'; Uri = "$siteRoot/wiki/syntheses/site-navigator" },
    @{ Label = 'representative concept'; Uri = "$siteRoot/wiki/concepts/cash-control-and-waterfalls" }
)
foreach ($route in $liveRoutes) {
    try {
        $response = Invoke-WebRequest -Uri $route.Uri -UseBasicParsing -MaximumRedirection 5 -TimeoutSec 30
    } catch {
        throw "Live $($route.Label) request failed: $($_.Exception.Message)"
    }
    if ([int]$response.StatusCode -ne 200) {
        throw "Live $($route.Label) returned HTTP $($response.StatusCode): $($route.Uri)"
    }
}

$assetRoot = "https://$($publishConfig.host)/access/$($publishConfig.siteId)"
$localCssHash = (Get-FileHash -LiteralPath $publishCss -Algorithm SHA256).Hash
$remoteCssHash = Get-RemoteFileHash -Uri "$assetRoot/publish.css" -Label 'publish.css'
if ($localCssHash -ne $remoteCssHash) {
    throw "Deployed publish.css does not match the local file: $remoteCssHash versus $localCssHash"
}
$localJsHash = (Get-FileHash -LiteralPath $publishJs -Algorithm SHA256).Hash
$remoteJsHash = Get-RemoteFileHash -Uri "$assetRoot/publish.js" -Label 'publish.js'
if ($localJsHash -ne $remoteJsHash) {
    throw "Deployed publish.js does not match the local file: $remoteJsHash versus $localJsHash"
}

if (-not $SkipBrowserAudit) {
    $browserAudit = Join-Path $vault 'tools\publish-browser-audit.ps1'
    if (-not (Test-Path -LiteralPath $browserAudit -PathType Leaf)) {
        throw 'Missing live reader behavior audit: tools/publish-browser-audit.ps1'
    }
    $browserOutput = @(& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $browserAudit -SiteUrl $siteRoot 2>&1)
    if ($LASTEXITCODE -ne 0) {
        throw "Live reader behavior audit failed:`n$($browserOutput | Out-String)"
    }
    $browserOutput | Write-Output
}

Write-Output 'Live routes: homepage, Site Navigator and representative concept returned HTTP 200'
Write-Output 'Deployed assets: publish.css and publish.js exactly match their local SHA-256 values'
Write-Output 'Publish inventory and live reader behavior match the intended public wiki.'

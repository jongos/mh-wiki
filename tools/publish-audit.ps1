[CmdletBinding()]
param(
    [string]$VaultRoot
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
Write-Output 'Required site homepage: MediaHedge Knowledgebase'
Write-Output 'Reader navigation: visible file explorer, native search and Site Navigator shortcut'

if ($missing.Count -gt 0 -or $extra.Count -gt 0) {
    exit 1
}

Write-Output 'Publish inventory matches the intended public wiki.'

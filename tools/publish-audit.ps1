[CmdletBinding()]
param(
    [string]$VaultRoot,
    [string]$SiteUrl = 'https://mediafinance.guide',
    [switch]$SkipBrowserAudit
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'hash-lib.ps1')
. (Join-Path $PSScriptRoot 'publish-response-lib.ps1')
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
        return Get-Sha256Hash -Path $temporaryFile
    } catch {
        throw "Unable to download deployed ${Label}: $($_.Exception.Message)"
    } finally {
        if (Test-Path -LiteralPath $temporaryFile) { Remove-Item -LiteralPath $temporaryFile -Force }
    }
}

$siteRoot = $SiteUrl.TrimEnd('/')
$httpRequest = [Net.HttpWebRequest]::Create("http://$(([Uri]$siteRoot).Host)/")
$httpRequest.AllowAutoRedirect = $false
$httpRequest.Timeout = 30000
$httpResponse = $httpRequest.GetResponse()
try {
    if ([int]$httpResponse.StatusCode -notin @(301, 308) -or
        $httpResponse.Headers['Location'] -notin @("$siteRoot/", "$siteRoot/MediaHedge+Knowledgebase")) {
        throw 'The public HTTP root must permanently redirect to the canonical HTTPS root or home note.'
    }
} finally { $httpResponse.Close() }
try {
    $rootResponse = Invoke-WebRequest -Uri "$siteRoot/" -UseBasicParsing -MaximumRedirection 5 -TimeoutSec 30
} catch {
    throw "Live site-root request failed: $($_.Exception.Message)"
}
$rootHtml = [string]$rootResponse.Content
if ([int]$rootResponse.StatusCode -ne 200) {
    throw "Live site root returned HTTP $($rootResponse.StatusCode): $siteRoot/"
}
if ($rootHtml -notmatch [regex]::Escape('window.preloadPage')) {
    throw 'Live site-root HTML does not declare an Obsidian Publish preload target.'
}
if ($rootHtml -match '(?i)Knowledgebase(?:%20|\+|\s)*\.md\.md' -or
    $rootHtml -match '(?i)does not exist') {
    throw 'Live site-root HTML exposes a broken crawler preload target or missing-page response.'
}
if ($rootHtml -notmatch [regex]::Escape('/MediaHedge%20Knowledgebase.md')) {
    throw 'Live site-root HTML does not preload the canonical MediaHedge Knowledgebase note with exactly one .md extension.'
}
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

try {
    $robotsResponse = Invoke-WebRequest -Uri "$siteRoot/robots.txt" -UseBasicParsing -TimeoutSec 30
} catch {
    throw "Unable to read live robots.txt: $($_.Exception.Message)"
}
$robotsText = [string]$robotsResponse.Content
if ([int]$robotsResponse.StatusCode -ne 200 -or
    [string]$robotsResponse.Headers['Content-Type'] -notmatch '^text/plain(?:;|$)' -or
    $robotsText -notmatch '(?im)^User-agent:\s*\*\s*$' -or
    $robotsText -notmatch '(?im)^Allow:\s*/\s*$' -or
    $robotsText -notmatch ('(?im)^Sitemap:\s*' + [regex]::Escape("$siteRoot/sitemap.xml") + '\s*$') -or
    $robotsText -match '(?im)^Disallow:\s*/\s*$') {
    throw "Live robots.txt does not clearly allow public-site crawling: $($robotsText -replace '\s+', ' ')"
}

try {
    $sitemapResponse = Invoke-WebRequest -Uri "$siteRoot/sitemap.xml" -UseBasicParsing -TimeoutSec 30
    if ([string]$sitemapResponse.Headers['Content-Type'] -notmatch '^(?:application|text)/xml(?:;|$)') {
        throw 'Sitemap response is not XML.'
    }
    [xml]$sitemapXml = $sitemapResponse.Content
} catch {
    throw "Unable to read or parse live sitemap.xml: $($_.Exception.Message)"
}
$namespace = New-Object System.Xml.XmlNamespaceManager($sitemapXml.NameTable)
$namespace.AddNamespace('s', 'http://www.sitemaps.org/schemas/sitemap/0.9')
$sitemapUrls = @($sitemapXml.SelectNodes('//s:url/s:loc', $namespace) | ForEach-Object { $_.InnerText.Trim() })
$expectedSitemapUrls = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
foreach ($file in $publicMarkdown) {
    $relative = $file.FullName.Substring($vault.Length).TrimStart([char[]]'\/').Replace('\', '/')
    $route = $relative.Substring(0, $relative.Length - 3).Split('/') |
        ForEach-Object { [Uri]::EscapeDataString($_).Replace('%20', '+') }
    [void]$expectedSitemapUrls.Add("$siteRoot/$($route -join '/')")
}
$sitemapMissing = @($expectedSitemapUrls | Where-Object { $_ -notin $sitemapUrls } | Sort-Object)
$sitemapUnexpected = @($sitemapUrls | Where-Object { -not $expectedSitemapUrls.Contains($_) } | Sort-Object)
$sitemapDuplicates = @($sitemapUrls | Group-Object | Where-Object { $_.Count -gt 1 })
if ($sitemapMissing.Count -gt 0 -or $sitemapUnexpected.Count -gt 0 -or $sitemapDuplicates.Count -gt 0) {
    $sitemapFailure = "Live sitemap inventory mismatch. Missing: $($sitemapMissing -join ', '); unexpected: $($sitemapUnexpected -join ', '); duplicate: $(($sitemapDuplicates.Name) -join ', ')"
    Write-Warning $sitemapFailure
}

$assetRoot = "https://$($publishConfig.host)/access/$($publishConfig.siteId)"
$localCssHash = Get-Sha256Hash -Path $publishCss
$remoteCssHash = Get-RemoteFileHash -Uri "$assetRoot/publish.css" -Label 'publish.css'
if ($localCssHash -ne $remoteCssHash) {
    throw "Deployed publish.css does not match the local file: $remoteCssHash versus $localCssHash"
}
$localJsHash = Get-Sha256Hash -Path $publishJs
$remoteJsHash = Get-RemoteFileHash -Uri "$assetRoot/publish.js" -Label 'publish.js'
if ($localJsHash -ne $remoteJsHash) {
    throw "Deployed publish.js does not match the local file: $remoteJsHash versus $localJsHash"
}

# Verify the complete published corpus, even while an upstream sitemap is stale.
# A correct inventory alone cannot establish that the deployed bytes are current.
foreach ($path in @($desired | Sort-Object)) {
    if ($path -in @('publish.css', 'publish.js')) { continue }
    $encodedPath = ($path.Split('/') | ForEach-Object { [Uri]::EscapeDataString($_) }) -join '/'
    $localHash = Get-Sha256Hash -Path (Join-Path $vault $path)
    $remoteHash = Get-RemoteFileHash -Uri "$assetRoot/$encodedPath" -Label $path
    if ($localHash -ne $remoteHash) { throw "Deployed content does not match local SHA-256: $path" }
    if ($path.EndsWith('.md')) {
        $route = $encodedPath.Substring(0, $encodedPath.Length - 3).Replace('%20', '+')
        $pageResponse = Invoke-WebRequest -Uri "$siteRoot/$route" -UseBasicParsing -TimeoutSec 30
        Assert-PublishPageResponse -StatusCode ([int]$pageResponse.StatusCode) `
            -ContentType ([string]$pageResponse.Headers['Content-Type']) `
            -RobotsHeader ([string]$pageResponse.Headers['X-Robots-Tag']) `
            -Html ([string]$pageResponse.Content) -ExpectedAssetUrl "$assetRoot/$encodedPath" -Label $route
    }
}
Write-Output "Full-corpus verification: all $($desired.Count) published files match local SHA-256; all $($publicMarkdown.Count) public note routes pass crawler-response checks"

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

if ($sitemapFailure) { throw $sitemapFailure }
Write-Output 'Live routes: every public note returned HTTP 200 HTML with the correct crawler preload and no indexing block'
Write-Output 'Transport and discovery: HTTP permanently redirects to HTTPS; robots.txt is plain text and advertises the XML sitemap'
Write-Output "Crawl controls: the site-root preload uses one .md extension, robots.txt allows the public site and sitemap.xml contains exactly $($sitemapUrls.Count) canonical note URLs"
Write-Output 'Deployed assets: publish.css and publish.js exactly match their local SHA-256 values'
Write-Output 'Publish inventory and live reader behavior match the intended public wiki.'

[CmdletBinding()]
param(
    [string]$VaultRoot,
    [switch]$Check
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($VaultRoot)) {
    $VaultRoot = Split-Path -Parent $PSScriptRoot
}
$vault = (Resolve-Path -LiteralPath $VaultRoot).Path
$strictUtf8 = New-Object Text.UTF8Encoding($false, $true)
$utf8NoBom = New-Object Text.UTF8Encoding($false)

function Read-Utf8Text {
    param([string]$Path)

    return [IO.File]::ReadAllText($Path, $script:strictUtf8)
}

function Get-FrontmatterScalar {
    param(
        [string]$Frontmatter,
        [string]$Name
    )

    $match = [regex]::Match($Frontmatter, "(?m)^$([regex]::Escape($Name)):\s*([^\r\n]*)\r?$")
    if (-not $match.Success) { return $null }
    $value = $match.Groups[1].Value.Trim()
    if (($value.StartsWith('"') -and $value.EndsWith('"')) -or
        ($value.StartsWith("'") -and $value.EndsWith("'"))) {
        return $value.Substring(1, $value.Length - 2)
    }
    return $value
}

function ConvertTo-JavaScriptString {
    param([string]$Value)

    $json = [string](ConvertTo-Json -InputObject $Value -Compress)
    return $json.Replace('\u0026', '&').Replace('\u0027', "'")
}

$configPath = Join-Path $vault 'tools\publish-navigation.json'
$publishJsPath = Join-Path $vault 'publish.js'
if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
    throw 'Missing navigation metadata: tools/publish-navigation.json'
}
if (-not (Test-Path -LiteralPath $publishJsPath -PathType Leaf)) {
    throw 'Missing reader-navigation script: publish.js'
}

try {
    $config = (Read-Utf8Text -Path $configPath) | ConvertFrom-Json
} catch {
    throw "Invalid tools/publish-navigation.json: $($_.Exception.Message)"
}

$publishedPages = @{}
$publishedSeo = @{}
$seenDescriptions = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
foreach ($file in Get-ChildItem -LiteralPath $vault -Recurse -File -Filter '*.md' |
    Where-Object { $_.FullName -notmatch '[\\/]\.git(?:[\\/]|$)' -and $_.FullName -notmatch '[\\/]\.tmp_' }) {
    $content = Read-Utf8Text -Path $file.FullName
    $frontmatterMatch = [regex]::Match(
        $content,
        '\A---\r?\n(?<yaml>.*?)\r?\n---(?:\r?\n|$)',
        [Text.RegularExpressions.RegexOptions]::Singleline
    )
    if (-not $frontmatterMatch.Success) { continue }
    $frontmatter = $frontmatterMatch.Groups['yaml'].Value
    if ((Get-FrontmatterScalar -Frontmatter $frontmatter -Name 'publish') -ne 'true') { continue }
    $title = Get-FrontmatterScalar -Frontmatter $frontmatter -Name 'title'
    if ([string]::IsNullOrWhiteSpace($title)) {
        throw "Published note has no usable title: $($file.FullName)"
    }
    $description = Get-FrontmatterScalar -Frontmatter $frontmatter -Name 'description'
    if ([string]::IsNullOrWhiteSpace($description)) {
        throw "Published note has no SEO description: $($file.FullName)"
    }
    if ($description.Length -lt 80 -or $description.Length -gt 180) {
        throw "Published-note SEO description must contain 80-180 characters: $($file.FullName) ($($description.Length))"
    }
    if (-not $seenDescriptions.Add($description)) {
        throw "Published-note SEO descriptions must be unique: $description"
    }
    $seoTitle = Get-FrontmatterScalar -Frontmatter $frontmatter -Name 'seo_title'
    if ([string]::IsNullOrWhiteSpace($seoTitle)) {
        $seoTitle = "$title | Media Finance Guide"
    }
    if ($seoTitle.Length -lt 20 -or $seoTitle.Length -gt 65) {
        throw "Published-note SEO title must contain 20-65 characters: $($file.FullName) ($($seoTitle.Length))"
    }
    $updated = Get-FrontmatterScalar -Frontmatter $frontmatter -Name 'updated'
    if ($updated -notmatch '^\d{4}-\d{2}-\d{2}$') {
        throw "Published note has no valid updated date for SEO metadata: $($file.FullName)"
    }
    $pageType = Get-FrontmatterScalar -Frontmatter $frontmatter -Name 'type'
    if ([string]::IsNullOrWhiteSpace($pageType)) {
        throw "Published note has no usable type for SEO metadata: $($file.FullName)"
    }
    $relative = $file.FullName.Substring($vault.Length).TrimStart([char[]]'\/').Replace('\', '/')
    if ($publishedPages.ContainsKey($relative)) {
        throw "Duplicate published navigation path: $relative"
    }
    $publishedPages[$relative] = $title
    $publishedSeo[$relative] = [pscustomobject]@{
        Title = $title
        SeoTitle = $seoTitle
        Description = $description
        Updated = $updated
        Type = $pageType
    }
}
if ($publishedPages.Count -eq 0) { throw 'No publish: true notes were found.' }

$homePath = [string]$config.home_path
if ([string]::IsNullOrWhiteSpace($homePath) -or -not $publishedPages.ContainsKey($homePath)) {
    throw "Configured home_path is not a published note: $homePath"
}

$overrides = @{}
foreach ($property in $config.label_overrides.PSObject.Properties) {
    $path = [string]$property.Name
    $label = [string]$property.Value
    if (-not $publishedPages.ContainsKey($path)) {
        throw "Navigation label override does not target a published note: $path"
    }
    if ([string]::IsNullOrWhiteSpace($label)) {
        throw "Navigation label override is empty: $path"
    }
    $overrides[$path] = $label
}

$entries = [System.Collections.Generic.List[object]]::new()
$seenPaths = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
function Add-NavigationEntry {
    param(
        [string]$Path,
        [string]$Label
    )

    if ([string]::IsNullOrWhiteSpace($Path) -or [string]::IsNullOrWhiteSpace($Label)) {
        throw 'Generated navigation entries require non-empty paths and labels.'
    }
    if (-not $script:seenPaths.Add($Path)) {
        throw "Duplicate generated navigation path: $Path"
    }
    $script:entries.Add([pscustomobject]@{ Path = $Path; Label = $Label })
}

$homeLabel = if ($overrides.ContainsKey($homePath)) { $overrides[$homePath] } else { $publishedPages[$homePath] }
Add-NavigationEntry -Path $homePath -Label $homeLabel
foreach ($folder in $config.folder_labels) {
    Add-NavigationEntry -Path ([string]$folder.path) -Label ([string]$folder.label)
}
foreach ($path in @($publishedPages.Keys | Where-Object { $_ -ne $homePath } | Sort-Object)) {
    $label = if ($overrides.ContainsKey($path)) { $overrides[$path] } else { $publishedPages[$path] }
    Add-NavigationEntry -Path $path -Label $label
}

$beginMarker = '  // BEGIN GENERATED READER LABELS'
$endMarker = '  // END GENERATED READER LABELS'
$publishJs = Read-Utf8Text -Path $publishJsPath
$beginIndex = $publishJs.IndexOf($beginMarker, [StringComparison]::Ordinal)
$endIndex = $publishJs.IndexOf($endMarker, [StringComparison]::Ordinal)
if ($beginIndex -lt 0 -or $endIndex -le $beginIndex -or
    $publishJs.IndexOf($beginMarker, $beginIndex + $beginMarker.Length, [StringComparison]::Ordinal) -ge 0 -or
    $publishJs.IndexOf($endMarker, $endIndex + $endMarker.Length, [StringComparison]::Ordinal) -ge 0) {
    throw 'publish.js must contain exactly one ordered generated-reader-label marker pair.'
}

$newline = if ($publishJs.Contains("`r`n")) { "`r`n" } else { "`n" }
$generatedLines = [System.Collections.Generic.List[string]]::new()
$generatedLines.Add($beginMarker)
$generatedLines.Add('  const readerLabels = new Map([')
for ($index = 0; $index -lt $entries.Count; $index++) {
    $entry = $entries[$index]
    $suffix = if ($index -lt $entries.Count - 1) { ',' } else { '' }
    $pathJson = ConvertTo-JavaScriptString -Value $entry.Path
    $labelJson = ConvertTo-JavaScriptString -Value $entry.Label
    $generatedLines.Add("    [$pathJson, $labelJson]$suffix")
}
$generatedLines.Add('  ]);')
$generatedLines.Add($endMarker)
$generatedBlock = $generatedLines -join $newline
$updatedPublishJs = $publishJs.Substring(0, $beginIndex) +
    $generatedBlock +
    $publishJs.Substring($endIndex + $endMarker.Length)

$seoBeginMarker = '  // BEGIN GENERATED SEO METADATA'
$seoEndMarker = '  // END GENERATED SEO METADATA'
$seoBeginIndex = $updatedPublishJs.IndexOf($seoBeginMarker, [StringComparison]::Ordinal)
$seoEndIndex = $updatedPublishJs.IndexOf($seoEndMarker, [StringComparison]::Ordinal)
if ($seoBeginIndex -lt 0 -or $seoEndIndex -le $seoBeginIndex -or
    $updatedPublishJs.IndexOf($seoBeginMarker, $seoBeginIndex + $seoBeginMarker.Length, [StringComparison]::Ordinal) -ge 0 -or
    $updatedPublishJs.IndexOf($seoEndMarker, $seoEndIndex + $seoEndMarker.Length, [StringComparison]::Ordinal) -ge 0) {
    throw 'publish.js must contain exactly one ordered generated-SEO-metadata marker pair.'
}

$seoLines = [System.Collections.Generic.List[string]]::new()
$seoLines.Add($seoBeginMarker)
$seoLines.Add('  const seoPages = new Map([')
$seoPaths = @($publishedSeo.Keys | Sort-Object)
for ($index = 0; $index -lt $seoPaths.Count; $index++) {
    $path = $seoPaths[$index]
    $metadata = $publishedSeo[$path]
    $suffix = if ($index -lt $seoPaths.Count - 1) { ',' } else { '' }
    $pathJson = ConvertTo-JavaScriptString -Value $path
    $titleJson = ConvertTo-JavaScriptString -Value $metadata.Title
    $seoTitleJson = ConvertTo-JavaScriptString -Value $metadata.SeoTitle
    $descriptionJson = ConvertTo-JavaScriptString -Value $metadata.Description
    $updatedJson = ConvertTo-JavaScriptString -Value $metadata.Updated
    $typeJson = ConvertTo-JavaScriptString -Value $metadata.Type
    $seoLines.Add("    [$pathJson, { title: $titleJson, seoTitle: $seoTitleJson, description: $descriptionJson, updated: $updatedJson, type: $typeJson }]$suffix")
}
$seoLines.Add('  ]);')
$seoLines.Add($seoEndMarker)
$seoBlock = $seoLines -join $newline
$updatedPublishJs = $updatedPublishJs.Substring(0, $seoBeginIndex) +
    $seoBlock +
    $updatedPublishJs.Substring($seoEndIndex + $seoEndMarker.Length)

if ($updatedPublishJs -ceq $publishJs) {
    Write-Output "Reader navigation and SEO metadata are current for $($publishedPages.Count) published notes."
    exit 0
}
if ($Check) {
    throw 'publish.js reader labels or SEO metadata are stale. Run tools\generate-publish-navigation.cmd and commit the result.'
}

[IO.File]::WriteAllText($publishJsPath, $updatedPublishJs, $utf8NoBom)
Write-Output "Updated publish.js reader labels and SEO metadata for $($publishedPages.Count) published notes."

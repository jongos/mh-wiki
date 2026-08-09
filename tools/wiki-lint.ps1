[CmdletBinding()]
param(
    [string]$VaultRoot
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($VaultRoot)) {
    $VaultRoot = Split-Path -Parent $PSScriptRoot
}
$vault = (Resolve-Path -LiteralPath $VaultRoot).Path
$errors = [System.Collections.Generic.List[string]]::new()
$warnings = [System.Collections.Generic.List[string]]::new()

$markdownFiles = Get-ChildItem -LiteralPath $vault -Recurse -File -Filter '*.md' -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '[\\/]\.tmp_' -and $_.FullName -notmatch '[\\/]\.git(?:[\\/]|$)' }
$allFiles = Get-ChildItem -LiteralPath $vault -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '[\\/]\.tmp_' -and $_.FullName -notmatch '[\\/]\.git(?:[\\/]|$)' }

$relativeByFile = @{}
$filesByStem = @{}
foreach ($file in $allFiles) {
    $relative = $file.FullName.Substring($vault.Length).TrimStart([char[]]'\/').Replace('\', '/')
    $relativeByFile[$file.FullName] = $relative
    $stem = [IO.Path]::GetFileNameWithoutExtension($file.Name).ToLowerInvariant()
    if (-not $filesByStem.ContainsKey($stem)) {
        $filesByStem[$stem] = [System.Collections.Generic.List[string]]::new()
    }
    $filesByStem[$stem].Add($file.FullName)
}

function Resolve-WikiTarget {
    param(
        [string]$Target,
        [string]$SourceFile
    )

    $clean = $Target.Trim()
    if ([string]::IsNullOrWhiteSpace($clean)) {
        if ([string]::IsNullOrWhiteSpace($SourceFile)) {
            return @{ Status = 'missing'; Path = $null }
        }
        return @{ Status = 'ok'; Path = $SourceFile }
    }

    $clean = [Uri]::UnescapeDataString($clean).Replace('/', [IO.Path]::DirectorySeparatorChar)
    $extension = [IO.Path]::GetExtension($clean)
    $candidates = [System.Collections.Generic.List[string]]::new()

    if ($extension) {
        $candidates.Add((Join-Path $vault $clean))
    } else {
        $candidates.Add((Join-Path $vault ($clean + '.md')))
        $candidates.Add((Join-Path $vault (Join-Path $clean 'index.md')))
    }

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return @{ Status = 'ok'; Path = (Resolve-Path -LiteralPath $candidate).Path }
        }
    }

    if ($clean -notmatch '[\\/]') {
        $stem = [IO.Path]::GetFileNameWithoutExtension($clean).ToLowerInvariant()
        if ($filesByStem.ContainsKey($stem)) {
            if ($filesByStem[$stem].Count -eq 1) {
                return @{ Status = 'ok'; Path = $filesByStem[$stem][0] }
            }
            return @{ Status = 'ambiguous'; Path = $null }
        }
    }

    return @{ Status = 'missing'; Path = $null }
}

function Get-WikiLinkParts {
    param([string]$InnerText)

    $pipeIndex = $InnerText.IndexOf('|')
    $destination = $InnerText.Trim()
    $alias = $null
    $aliasEscaped = $false
    if ($pipeIndex -ge 0) {
        $destination = $InnerText.Substring(0, $pipeIndex).Trim()
        if ($destination.EndsWith('\')) {
            $aliasEscaped = $true
            $destination = $destination.Substring(0, $destination.Length - 1).TrimEnd()
        }
        $alias = $InnerText.Substring($pipeIndex + 1)
    }

    $target = $destination
    $fragment = $null
    $hashIndex = $destination.IndexOf('#')
    if ($hashIndex -ge 0) {
        $target = $destination.Substring(0, $hashIndex).Trim()
        $fragment = $destination.Substring($hashIndex + 1).Trim()
    }

    return @{
        Target = $target
        Fragment = $fragment
        Alias = $alias
        AliasEscaped = $aliasEscaped
    }
}

function Mask-MarkdownCode {
    param([string]$Content)

    $mask = {
        param($Match)
        return [regex]::Replace($Match.Value, '[^\r\n]', ' ')
    }
    $masked = [regex]::Replace(
        $Content,
        '(?ms)^[ \t]*(?:`{3,}|~{3,})[^\r\n]*(?:\r?\n).*?^[ \t]*(?:`{3,}|~{3,})[ \t]*$',
        $mask
    )
    return [regex]::Replace($masked, '`+[^`\r\n]*`+', $mask)
}

function Get-LineNumber {
    param(
        [string]$Content,
        [int]$Index
    )

    if ($Index -le 0) {
        return 1
    }
    return [regex]::Matches($Content.Substring(0, $Index), "`r`n|`n|`r").Count + 1
}

function Normalize-WikiHeading {
    param([string]$Heading)

    try {
        $normalized = [Uri]::UnescapeDataString($Heading)
    } catch {
        $normalized = $Heading
    }
    $normalized = $normalized.Trim()
    $normalized = $normalized -replace '\s+#+\s*$', ''
    $normalized = $normalized -replace '<[^>]+>', ''
    $normalized = $normalized -replace '\[([^\]]+)\]\([^\)]+\)', '$1'
    $normalized = $normalized -replace '\[\[[^\]|]+\|([^\]]+)\]\]', '$1'
    $normalized = $normalized -replace '\[\[([^\]]+)\]\]', '$1'
    $normalized = $normalized -replace '[`*_~]', ''
    $normalized = $normalized -replace '\s+', ' '
    return $normalized.Trim().ToLowerInvariant()
}

function Test-WikiFragment {
    param(
        [string]$TargetPath,
        [string]$Fragment
    )

    if ([string]::IsNullOrWhiteSpace($Fragment) -or [IO.Path]::GetExtension($TargetPath) -ne '.md') {
        return $false
    }

    $targetContent = Get-Content -Raw -LiteralPath $TargetPath
    if ($Fragment.StartsWith('^')) {
        $blockId = $Fragment.Substring(1).Trim()
        if ([string]::IsNullOrWhiteSpace($blockId)) {
            return $false
        }
        return $targetContent -match "(?m)(?:^|\\s)\^$([regex]::Escape($blockId))\\s*$"
    }

    $wantedHeading = Normalize-WikiHeading -Heading $Fragment
    foreach ($headingMatch in [regex]::Matches($targetContent, '(?m)^#{1,6}\s+(.+?)\s*$')) {
        if ((Normalize-WikiHeading -Heading $headingMatch.Groups[1].Value) -eq $wantedHeading) {
            return $true
        }
    }
    return $false
}

$inbound = @{}
foreach ($file in $allFiles) {
    $inbound[$file.FullName] = 0
}

$wikiLinkCount = 0
$anchoredWikiLinkCount = 0
foreach ($file in $markdownFiles) {
    $relative = $relativeByFile[$file.FullName]
    $content = Get-Content -Raw -LiteralPath $file.FullName
    $linkContent = Mask-MarkdownCode -Content $content
    $openIndex = -1
    foreach ($token in [regex]::Matches($linkContent, '(?<!\\)\[\[|(?<!\\)\]\]')) {
        $line = Get-LineNumber -Content $content -Index $token.Index
        if ($token.Value -eq '[[') {
            if ($openIndex -ge 0) {
                $errors.Add("Nested or unclosed opening wikilink delimiter in ${relative}:$line")
            }
            $openIndex = $token.Index
            continue
        }

        if ($openIndex -lt 0) {
            $errors.Add("Closing wikilink delimiter without an opening delimiter in ${relative}:$line")
            continue
        }

        $innerStart = $openIndex + 2
        $innerText = $content.Substring($innerStart, $token.Index - $innerStart)
        $openLine = Get-LineNumber -Content $content -Index $openIndex
        $openIndex = -1
        $wikiLinkCount++

        if ([string]::IsNullOrWhiteSpace($innerText)) {
            $errors.Add("Empty wikilink in ${relative}:$openLine")
            continue
        }
        if ($innerText -match '[\r\n]') {
            $errors.Add("Wikilink spans more than one line in ${relative}:$openLine")
            continue
        }

        $linkParts = Get-WikiLinkParts -InnerText $innerText
        $linkOpenIndex = $innerStart - 2
        $lineStart = $content.LastIndexOf("`n", [Math]::Max(0, $linkOpenIndex - 1))
        if ($lineStart -lt 0) {
            $lineStart = 0
        } else {
            $lineStart++
        }
        $lineEnd = $content.IndexOf("`n", $token.Index)
        if ($lineEnd -lt 0) {
            $lineEnd = $content.Length
        }
        $lineText = $content.Substring($lineStart, $lineEnd - $lineStart)
        if ($null -ne $linkParts.Alias -and -not $linkParts.AliasEscaped -and $lineText -match '^\s*(?:>\s*)?\|') {
            $errors.Add("Wikilink alias separator must be escaped as \| inside a Markdown table in ${relative}:${openLine}: [[$innerText]]")
        }
        if ($null -ne $linkParts.Alias -and [string]::IsNullOrWhiteSpace($linkParts.Alias)) {
            $errors.Add("Wikilink has an empty display alias in ${relative}:${openLine}: [[$innerText]]")
        }
        if ([string]::IsNullOrWhiteSpace($linkParts.Target) -and $null -eq $linkParts.Fragment) {
            $errors.Add("Wikilink has no target in ${relative}:${openLine}: [[$innerText]]")
            continue
        }
        if ($null -ne $linkParts.Fragment -and [string]::IsNullOrWhiteSpace($linkParts.Fragment)) {
            $errors.Add("Wikilink has an empty heading or block reference in ${relative}:${openLine}: [[$innerText]]")
            continue
        }

        $resolved = Resolve-WikiTarget -Target $linkParts.Target -SourceFile $file.FullName
        if ($resolved.Status -eq 'missing') {
            $errors.Add("Broken link in ${relative}:${openLine}: [[$innerText]]")
        } elseif ($resolved.Status -eq 'ambiguous') {
            $errors.Add("Ambiguous short link in ${relative}:${openLine}: [[$innerText]]")
        } elseif ($resolved.Status -eq 'ok') {
            if ($resolved.Path -ne $file.FullName) {
                $inbound[$resolved.Path] = [int]$inbound[$resolved.Path] + 1
            }
            if ($null -ne $linkParts.Fragment) {
                $anchoredWikiLinkCount++
                if (-not (Test-WikiFragment -TargetPath $resolved.Path -Fragment $linkParts.Fragment)) {
                    $errors.Add("Broken heading or block reference in ${relative}:${openLine}: [[$innerText]]")
                }
            }
        }
    }
    if ($openIndex -ge 0) {
        $line = Get-LineNumber -Content $content -Index $openIndex
        $errors.Add("Opening wikilink delimiter without a closing delimiter in ${relative}:$line")
    }
}

$requiredKeys = @('title', 'type', 'status', 'updated', 'source_count', 'publish', 'tags')
$allowedTypes = @('overview', 'source', 'concept', 'entity', 'synthesis', 'glossary', 'operations')
$allowedStatuses = @('current', 'needs-review', 'superseded', 'seed')
$wikiFiles = Get-ChildItem -LiteralPath (Join-Path $vault 'wiki') -Recurse -File -Filter '*.md'

foreach ($file in $wikiFiles) {
    $relative = $relativeByFile[$file.FullName]
    $content = Get-Content -Raw -LiteralPath $file.FullName
    if ($content -notmatch '(?s)^---\r?\n(.*?)\r?\n---\r?\n') {
        $errors.Add("Missing YAML frontmatter: $relative")
        continue
    }
    $frontmatter = $Matches[1]
    foreach ($key in $requiredKeys) {
        if ($frontmatter -notmatch "(?m)^${key}:") {
            $errors.Add("Missing frontmatter key '$key': $relative")
        }
    }
    if ($frontmatter -match '(?m)^type:\s*([^\r\n]+)') {
        $type = $Matches[1].Trim()
        if ($type -notin $allowedTypes) {
            $errors.Add("Invalid type '$type': $relative")
        }
    }
    if ($frontmatter -match '(?m)^status:\s*([^\r\n]+)') {
        $status = $Matches[1].Trim()
        if ($status -notin $allowedStatuses) {
            $errors.Add("Invalid status '$status': $relative")
        }
    }
    if ($frontmatter -match '(?m)^publish:\s*([^\r\n]+)') {
        $publishStatus = $Matches[1].Trim()
        if ($publishStatus -notin @('true', 'false')) {
            $errors.Add("Invalid publish value '$publishStatus': $relative")
        }
    }
    if ($relative -like 'wiki/sources/*') {
        if ($frontmatter -notmatch '(?m)^source_file:') {
            $errors.Add("Source page missing source_file: $relative")
        }
        if ($frontmatter -notmatch '(?m)^source_hash:\s*[A-Fa-f0-9]{64}\s*$') {
            $errors.Add("Source page has missing or invalid SHA-256: $relative")
        }
        if ($frontmatter -notmatch '(?m)^source_count:\s*1\s*$') {
            $errors.Add("Source page source_count must be 1: $relative")
        }
        if ($content -notmatch '\[\[raw/sources/') {
            $errors.Add("Source page missing raw-source wikilink: $relative")
        }
        if ($content -notmatch '\[\[wiki/concepts/') {
            $errors.Add("Source page missing related-concept link: $relative")
        }
        if ($content -notmatch '\[\[wiki/(syntheses/|overview(?:\||\]\]))') {
            $errors.Add("Source page missing synthesis or overview link: $relative")
        }
        if ($frontmatter -match '(?m)^source_kind:\s*derived-artifact\s*$') {
            if ($frontmatter -notmatch '(?m)^authority:\s*non-evidentiary\s*$') {
                $errors.Add("Derived source page must be marked authority: non-evidentiary: $relative")
            }
            if ($frontmatter -notmatch '(?m)^derived_from:\s*$') {
                $errors.Add("Derived source page missing derived_from lineage: $relative")
            }
        }
    }
    if ($relative -like 'wiki/concepts/*') {
        if ($content -notmatch '(?m)^## Source basis\s*$') {
            $errors.Add("Concept page missing Source basis section: $relative")
        }
        if ($content -notmatch '\[\[wiki/concepts/') {
            $errors.Add("Concept page missing adjacent-concept link: $relative")
        }
    }
    if ($frontmatter -match '(?m)^status:\s*needs-review\s*$' -and
        $frontmatter -match '(?m)^\s+-\s+policy\s*$' -and
        $frontmatter -notmatch '(?m)^as_of:\s*\S+') {
        $errors.Add("Policy page marked needs-review must record as_of (use 'unknown' if undated): $relative")
    }
    if ([int]$inbound[$file.FullName] -eq 0) {
        $warnings.Add("Orphan wiki page: $relative")
    }
}

$homePath = Join-Path $vault 'MediaHedge Knowledgebase.md'
if (-not (Test-Path -LiteralPath $homePath -PathType Leaf)) {
    $errors.Add('Missing public home note: MediaHedge Knowledgebase.md')
    $homeContent = ''
} else {
    $homeContent = Get-Content -Raw -LiteralPath $homePath
    if ($homeContent -notmatch '(?m)^publish:\s*true\s*$') {
        $errors.Add('Public home note must be marked publish: true')
    }
}

$catalogPath = Join-Path $vault 'wiki\operations\internal-catalog.md'
if (-not (Test-Path -LiteralPath $catalogPath -PathType Leaf)) {
    $errors.Add('Missing private internal catalog: wiki/operations/internal-catalog.md')
    $catalogContent = ''
} else {
    $catalogContent = Get-Content -Raw -LiteralPath $catalogPath
}

$publicWikiFiles = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
foreach ($file in $wikiFiles) {
    $relative = $relativeByFile[$file.FullName]
    $target = ($relative -replace '\.md$', '').Replace('\', '/')
    $content = Get-Content -Raw -LiteralPath $file.FullName
    $isPublished = $content -match '(?m)^publish:\s*true\s*$'
    $shouldBePrivate = $relative -like 'wiki/sources/*' -or
        $relative -like 'wiki/operations/*' -or
        $relative -eq 'wiki/welcome.md'

    if ($shouldBePrivate -and $isPublished) {
        $errors.Add("Private wiki page marked for publication: $relative")
    }
    if (-not $shouldBePrivate -and -not $isPublished) {
        $errors.Add("Reader-facing wiki page is not marked publish: true: $relative")
    }
    if ($isPublished) {
        $publicWikiFiles.Add($file)
        if ($homeContent -notmatch [regex]::Escape("[[$target")) {
            $warnings.Add("Published page absent from public home: $relative")
        }

        $visibleContent = [regex]::Replace($content, '(?s)<!--.*?-->', '')
        if ($visibleContent -notmatch [regex]::Escape('[[MediaHedge Knowledgebase')) {
            $errors.Add("Published wiki page does not link back to the public home: $relative")
        }
        foreach ($match in [regex]::Matches($visibleContent, '\[\[([^\]]+)\]\]')) {
            $visibleTarget = ($match.Groups[1].Value -split '\|', 2)[0]
            if ($visibleTarget -match '^(raw/|wiki/sources/|wiki/operations/|AGENTS(?:\||$)|README(?:\||$)|index(?:\||$)|log(?:\||$))') {
                $errors.Add("Published page visibly links to private material: $relative -> [[$($match.Groups[1].Value)]]")
            }
        }
        if ($visibleContent -match '(?i)SHA-256|source_hash|raw/sources|AGENTS\.md|wiki-lint|YAML frontmatter|Git history') {
            $errors.Add("Published page displays maintenance terminology: $relative")
        }
    }

    if ($catalogContent -notmatch [regex]::Escape("[[$target")) {
        $warnings.Add("Wiki page absent from private internal catalog: $relative")
    }
}

$financierGuideTarget = '[[wiki/syntheses/financier-diligence-route'
if ($homeContent -notmatch [regex]::Escape($financierGuideTarget)) {
    $errors.Add('Public home does not link the Financier Guide')
}
foreach ($file in Get-ChildItem -LiteralPath (Join-Path $vault 'wiki\concepts') -File -Filter '*.md') {
    $relative = $relativeByFile[$file.FullName]
    $content = Get-Content -Raw -LiteralPath $file.FullName
    if ($content -notmatch [regex]::Escape($financierGuideTarget)) {
        $errors.Add("Concept page missing financier navigation: $relative")
    }
}

$privateRootFiles = @('AGENTS.md', 'README.md', 'index.md', 'log.md', 'raw/manifest.md')
foreach ($privateRelative in $privateRootFiles) {
    $privatePath = Join-Path $vault $privateRelative
    if (-not (Test-Path -LiteralPath $privatePath -PathType Leaf)) {
        $errors.Add("Missing private maintenance file: $privateRelative")
        continue
    }
    $privateContent = Get-Content -Raw -LiteralPath $privatePath
    if ($privateContent -notmatch '(?m)^publish:\s*false\s*$') {
        $errors.Add("Private maintenance file must be marked publish: false: $privateRelative")
    }
}

foreach ($template in Get-ChildItem -LiteralPath (Join-Path $vault 'templates') -File -Filter '*.md') {
    $templateContent = Get-Content -Raw -LiteralPath $template.FullName
    if ($templateContent -notmatch '(?m)^publish:\s*false\s*$') {
        $errors.Add("Template must be marked publish: false: $($relativeByFile[$template.FullName])")
    }
}

$sourceSnapshots = Get-ChildItem -LiteralPath (Join-Path $vault 'raw\sources') -File
$manifest = Get-Content -Raw -LiteralPath (Join-Path $vault 'raw\manifest.md')
foreach ($source in $sourceSnapshots) {
    $hash = (Get-FileHash -LiteralPath $source.FullName -Algorithm SHA256).Hash
    if ($manifest -notmatch [regex]::Escape($source.Name)) {
        $errors.Add("Raw source missing from manifest: $($source.Name)")
    }
    if ($manifest -notmatch [regex]::Escape($hash)) {
        $errors.Add("Raw source hash missing or changed: $($source.Name)")
    }
}

Write-Output "MediaHedge wiki lint"
Write-Output "Markdown files: $($markdownFiles.Count)"
Write-Output "Wiki pages: $($wikiFiles.Count)"
Write-Output "Wikilinks: $wikiLinkCount"
Write-Output "Heading and block links: $anchoredWikiLinkCount"
Write-Output "Raw sources: $($sourceSnapshots.Count)"
Write-Output "Errors: $($errors.Count)"
Write-Output "Warnings: $($warnings.Count)"

foreach ($item in $errors) {
    Write-Output "ERROR: $item"
}
foreach ($item in $warnings) {
    Write-Output "WARN: $item"
}

if ($errors.Count -gt 0) {
    exit 1
}

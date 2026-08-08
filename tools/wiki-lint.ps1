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
    param([string]$Target)

    $clean = ($Target -split '\|', 2)[0]
    $clean = ($clean -split '#', 2)[0].Trim()
    if ([string]::IsNullOrWhiteSpace($clean)) {
        return @{ Status = 'skip'; Path = $null }
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

$inbound = @{}
foreach ($file in $allFiles) {
    $inbound[$file.FullName] = 0
}

foreach ($file in $markdownFiles) {
    $relative = $relativeByFile[$file.FullName]
    $content = Get-Content -Raw -LiteralPath $file.FullName
    foreach ($match in [regex]::Matches($content, '\[\[([^\]]+)\]\]')) {
        $target = $match.Groups[1].Value
        $resolved = Resolve-WikiTarget -Target $target
        if ($resolved.Status -eq 'missing') {
            $errors.Add("Broken link in ${relative}: [[$target]]")
        } elseif ($resolved.Status -eq 'ambiguous') {
            $errors.Add("Ambiguous short link in ${relative}: [[$target]]")
        } elseif ($resolved.Status -eq 'ok' -and $resolved.Path -ne $file.FullName) {
            $inbound[$resolved.Path] = [int]$inbound[$resolved.Path] + 1
        }
    }
}

$requiredKeys = @('title', 'type', 'status', 'updated', 'source_count', 'tags')
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

$homeCandidates = @('MediaHedge Knowledgebase.md', 'index.md')
$homePath = $null
foreach ($candidate in $homeCandidates) {
    $candidatePath = Join-Path $vault $candidate
    if (Test-Path -LiteralPath $candidatePath -PathType Leaf) {
        $homePath = $candidatePath
        break
    }
}
if ($null -eq $homePath) {
    $errors.Add('Missing home note: expected MediaHedge Knowledgebase.md or index.md')
    $homeContent = ''
} else {
    $homeContent = Get-Content -Raw -LiteralPath $homePath
}
foreach ($file in $wikiFiles) {
    $relative = $relativeByFile[$file.FullName]
    $target = ($relative -replace '\.md$', '').Replace('\', '/')
    if ($homeContent -notmatch [regex]::Escape("[[$target")) {
        $warnings.Add("Wiki page absent from home note: $relative")
    }
}

$financierGuideTarget = '[[wiki/syntheses/financier-diligence-route'
if ($homeContent -notmatch [regex]::Escape($financierGuideTarget)) {
    $errors.Add('Home note does not link the Financier Diligence Guide')
}
foreach ($file in Get-ChildItem -LiteralPath (Join-Path $vault 'wiki\concepts') -File -Filter '*.md') {
    $relative = $relativeByFile[$file.FullName]
    $content = Get-Content -Raw -LiteralPath $file.FullName
    if ($content -notmatch [regex]::Escape($financierGuideTarget)) {
        $errors.Add("Concept page missing financier navigation: $relative")
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

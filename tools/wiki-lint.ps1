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

$strictUtf8 = New-Object System.Text.UTF8Encoding($false, $true)

function Read-Utf8Text {
    param([string]$Path)

    try {
        return [IO.File]::ReadAllText($Path, $script:strictUtf8)
    } catch {
        $relative = if ($script:relativeByFile.ContainsKey($Path)) { $script:relativeByFile[$Path] } else { $Path }
        $script:errors.Add("Invalid UTF-8 encoding: $relative")
        return [IO.File]::ReadAllText($Path, [Text.Encoding]::UTF8)
    }
}

function Get-FrontmatterValue {
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

function Test-PublishVaultConfiguration {
    $obsidianDirectory = Join-Path $script:vault '.obsidian'
    $publishConfigPath = Join-Path $obsidianDirectory 'publish.json'
    $publishCssPath = Join-Path $script:vault 'publish.css'
    $publishJsPath = Join-Path $script:vault 'publish.js'

    if (-not (Test-Path -LiteralPath $obsidianDirectory -PathType Container)) {
        $script:errors.Add("Missing root .obsidian directory; open this directory, not its parent, as the Obsidian vault")
        return
    }
    if (-not (Test-Path -LiteralPath $publishConfigPath -PathType Leaf)) {
        $script:errors.Add("Missing root .obsidian/publish.json; the correctly rooted vault is not connected to Obsidian Publish")
        return
    }
    if (-not (Test-Path -LiteralPath $publishCssPath -PathType Leaf)) {
        $script:errors.Add("Missing root publish.css; Obsidian Publish will not load a nested custom stylesheet")
    }
    if (-not (Test-Path -LiteralPath $publishJsPath -PathType Leaf)) {
        $script:errors.Add("Missing root publish.js; custom-domain reader navigation will not load")
    }

    try {
        $publishConfig = (Read-Utf8Text -Path $publishConfigPath) | ConvertFrom-Json
    } catch {
        $script:errors.Add("Invalid JSON in .obsidian/publish.json: $($_.Exception.Message)")
        return
    }

    if ([string]$publishConfig.siteId -notmatch '^[0-9a-fA-F]{32}$') {
        $script:errors.Add('Invalid or missing siteId in .obsidian/publish.json')
    }
    if ([string]$publishConfig.host -notmatch '^publish-[0-9]+\.obsidian\.md$') {
        $script:errors.Add('Invalid or missing Publish host in .obsidian/publish.json')
    }

    $parent = Split-Path -Parent $script:vault
    $parentPublishConfigPath = Join-Path $parent '.obsidian\publish.json'
    if (Test-Path -LiteralPath $parentPublishConfigPath -PathType Leaf) {
        try {
            $parentPublishConfig = (Read-Utf8Text -Path $parentPublishConfigPath) | ConvertFrom-Json
            if ([string]$parentPublishConfig.siteId -eq [string]$publishConfig.siteId) {
                $script:errors.Add("The parent directory is connected to the same Publish site; disable its .obsidian/publish.json to prevent prefixed paths and broken vault-relative links")
            }
        } catch {
            $script:warnings.Add("Could not inspect the parent Publish configuration: $($_.Exception.Message)")
        }
    }

    if (-not [string]::IsNullOrWhiteSpace($env:APPDATA)) {
        $obsidianRegistryPath = Join-Path $env:APPDATA 'obsidian\obsidian.json'
        if (Test-Path -LiteralPath $obsidianRegistryPath -PathType Leaf) {
            try {
                $obsidianRegistry = (Read-Utf8Text -Path $obsidianRegistryPath) | ConvertFrom-Json
                $registeredPaths = @(
                    $obsidianRegistry.vaults.PSObject.Properties |
                        ForEach-Object { [IO.Path]::GetFullPath([string]$_.Value.path).TrimEnd([char[]]'\/') }
                )
                $normalizedVaultPath = [IO.Path]::GetFullPath($script:vault).TrimEnd([char[]]'\/')
                if ($registeredPaths -notcontains $normalizedVaultPath) {
                    $script:errors.Add("This directory is not registered as an Obsidian vault; the app may silently use a registered parent and publish broken prefixed paths")
                }
            } catch {
                $script:warnings.Add("Could not inspect Obsidian's registered vaults: $($_.Exception.Message)")
            }
        }
    }
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

function Get-MarkdownColumnCount {
    param([string]$Line)

    $trimmed = ($Line -replace '^\s*>\s*', '').Trim()
    $pipeCount = [regex]::Matches($trimmed, '(?<!\\)\|').Count
    $leadingPipe = if ($trimmed -match '^\|') { 1 } else { 0 }
    $trailingPipe = if ($trimmed -match '(?<!\\)\|\s*$') { 1 } else { 0 }
    return $pipeCount + 1 - $leadingPipe - $trailingPipe
}

function Test-MarkdownAlignmentRow {
    param([string]$Line)

    return $Line -match '^\s*(?:>\s*)?\|?\s*:?-{3,}:?\s*(?:\|\s*:?-{3,}:?\s*)+\|?\s*$' -or
        $Line -match '^\s*(?:>\s*)?\|\s*:?-{3,}:?\s*\|\s*$'
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

    if ($script:contentByFile.ContainsKey($TargetPath)) {
        $targetContent = $script:contentByFile[$TargetPath]
    } else {
        $targetContent = Read-Utf8Text -Path $TargetPath
        $script:contentByFile[$TargetPath] = $targetContent
    }
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

function Get-TitleCaseIssue {
    param([string]$Heading)

    $smallWords = @(
        'a', 'an', 'and', 'as', 'at', 'but', 'by', 'for', 'from', 'in', 'into',
        'nor', 'of', 'on', 'or', 'over', 'per', 'the', 'to', 'up', 'via', 'vs',
        'with', 'without', 'yet'
    )
    $tokens = $Heading -split '\s+'
    $lexicalTokens = @($tokens | Where-Object { $_ -match '\p{L}' })
    $lexicalIndex = 0
    $forceCapital = $true

    foreach ($token in $tokens) {
        if ($token -notmatch '\p{L}') {
            if ($token.EndsWith(':')) {
                $forceCapital = $true
            }
            continue
        }

        $segments = $token -split '-'
        $wordSegments = @($segments | Where-Object { $_ -match '\p{L}' })
        $wordSegmentIndex = 0
        foreach ($segment in $segments) {
            $wordMatch = [regex]::Match($segment, '\p{L}+[\p{L}0-9]*')
            if (-not $wordMatch.Success) {
                continue
            }

            $word = $wordMatch.Value
            $lowerWord = $word.ToLowerInvariant()
            $isFirst = $lexicalIndex -eq 0 -and $wordSegmentIndex -eq 0
            $isLast = $lexicalIndex -eq ($lexicalTokens.Count - 1) -and
                $wordSegmentIndex -eq ($wordSegments.Count - 1)
            $isSmallWord = $lowerWord -in $smallWords
            $mustBeCapitalized = $forceCapital -or $isFirst -or $isLast -or -not $isSmallWord

            if ($mustBeCapitalized -and -not [char]::IsUpper($word[0])) {
                return $word
            }
            if (-not $mustBeCapitalized -and -not [char]::IsLower($word[0])) {
                return $word
            }

            $forceCapital = $false
            $wordSegmentIndex++
        }
        if ($token.EndsWith(':')) {
            $forceCapital = $true
        }
        $lexicalIndex++
    }
    return $null
}

function Test-PublishedPresentation {
    param(
        [string]$Content,
        [string]$Relative,
        [bool]$RequireContinueExploring
    )

    $mask = {
        param($Match)
        return [regex]::Replace($Match.Value, '[^\r\n]', ' ')
    }
    $visible = [regex]::Replace($Content, '(?s)<!--.*?-->', $mask)
    $visible = Mask-MarkdownCode -Content $visible

    foreach ($headingMatch in [regex]::Matches($visible, '(?m)^(#{1,3})\s+(.+?)\s*$')) {
        $heading = $headingMatch.Groups[2].Value
        $issue = Get-TitleCaseIssue -Heading $heading
        if ($null -ne $issue) {
            $line = Get-LineNumber -Content $Content -Index $headingMatch.Index
            $script:errors.Add("Published heading is not in Title Case in ${Relative}:${line}: $heading")
        }
    }

    $h1Match = [regex]::Match($visible, '(?m)^#\s+.+?\s*$')
    if ($h1Match.Success) {
        $nextH2 = [regex]::Match($visible.Substring($h1Match.Index + $h1Match.Length), '(?m)^##\s+')
        $introEnd = if ($nextH2.Success) {
            $h1Match.Index + $h1Match.Length + $nextH2.Index
        } else {
            $visible.Length
        }
        $intro = $visible.Substring($h1Match.Index + $h1Match.Length, $introEnd - ($h1Match.Index + $h1Match.Length))
        if ($intro -notmatch '\p{L}') {
            $script:errors.Add("Published page needs concise introductory content before its first H2: $Relative")
        }
    }

    foreach ($spacingMatch in [regex]::Matches($visible, '(?m)^#{1,3}\s+[^\r\n]+\r?\n(?!\r?\n)')) {
        $line = Get-LineNumber -Content $Content -Index $spacingMatch.Index
        $script:errors.Add("Published heading must be followed by a blank line in ${Relative}:$line")
    }

    if ($RequireContinueExploring) {
        $continueCount = [regex]::Matches($visible, '(?m)^## Continue Exploring\s*$').Count
        if ($continueCount -ne 1) {
            $script:errors.Add("Published wiki page must contain exactly one 'Continue Exploring' section: $Relative (found $continueCount)")
        }
    }

    if ($visible -notmatch [regex]::Escape('[[wiki/syntheses/site-navigator|')) {
        $script:errors.Add("Published page footer must link to the Site Navigator: $Relative")
    }

    $allowedCalloutTypes = @('important', 'tip', 'note', 'warning')
    foreach ($calloutMatch in [regex]::Matches($visible, '(?m)^>\s*\[!([^\]]+)\]\s*(.*?)\s*$')) {
        $calloutType = $calloutMatch.Groups[1].Value.ToLowerInvariant()
        $calloutTitle = $calloutMatch.Groups[2].Value.Trim()
        $line = Get-LineNumber -Content $Content -Index $calloutMatch.Index
        if ($calloutType -notin $allowedCalloutTypes) {
            $script:errors.Add("Published page uses an unsupported callout type in ${Relative}:${line}: $calloutType")
        }
        if (-not [string]::IsNullOrWhiteSpace($calloutTitle) -and
            $null -ne (Get-TitleCaseIssue -Heading $calloutTitle)) {
            $script:errors.Add("Published callout title is not in Title Case in ${Relative}:${line}: $calloutTitle")
        }
    }

    foreach ($diagramMatch in [regex]::Matches($visible, '(?m)!\[\[(assets/diagrams/[^\]|]+\.svg)(?:\|([^\]]+))?\]\]')) {
        $script:diagramEmbedCount++
        $line = Get-LineNumber -Content $Content -Index $diagramMatch.Index
        $alias = $diagramMatch.Groups[2].Value.Trim()
        if ([string]::IsNullOrWhiteSpace($alias) -or $alias -match '^\d+$' -or $alias.Length -lt 12) {
            $script:errors.Add("Published diagram needs descriptive alternative text in ${Relative}:${line}: $($diagramMatch.Groups[1].Value)")
        }

        $afterDiagram = $visible.Substring($diagramMatch.Index + $diagramMatch.Length)
        $captionMatch = [regex]::Match($afterDiagram, '^\r?\n\r?\n\*([^*\r\n]+)\*')
        if (-not $captionMatch.Success) {
            $script:errors.Add("Published diagram needs an italic caption immediately after it in ${Relative}:${line}")
        } elseif ($captionMatch.Groups[1].Value -notmatch '(?i)conceptual|illustrative') {
            $script:errors.Add("Published diagram caption must identify conceptual or illustrative status in ${Relative}:${line}")
        }
    }

    if ($visible -match '\]\(https?://' -and $visible -notmatch 'Links checked:\s*\d{4}-\d{2}-\d{2}') {
        $script:errors.Add("Published page with external links needs a YYYY-MM-DD link-check date: $Relative")
    }
}

Test-PublishVaultConfiguration

$inbound = @{}
foreach ($file in $allFiles) {
    $inbound[$file.FullName] = 0
}

$contentByFile = @{}
$wikiLinkCount = 0
$anchoredWikiLinkCount = 0
$markdownTableCount = 0
$standardMarkdownLinkCount = 0
$externalMarkdownLinkCount = 0
$diagramEmbedCount = 0
foreach ($file in $markdownFiles) {
    $relative = $relativeByFile[$file.FullName]
    $content = Read-Utf8Text -Path $file.FullName
    $contentByFile[$file.FullName] = $content

    if ($content -match '\u00E2\u20AC|\u00C2\u00B7|\u00C3[\u0080-\u00BF]|\u00EF\u00BF\u00BD|\uFFFD') {
        $errors.Add("Possible mojibake or replacement character: $relative")
    }
    if ($content.IndexOf([char]0) -ge 0) {
        $errors.Add("NUL character in Markdown file: $relative")
    }

    $fenceMarker = $null
    $fenceLength = 0
    $fenceStartLine = 0
    $structureLines = $content -split '\r?\n'
    for ($lineIndex = 0; $lineIndex -lt $structureLines.Count; $lineIndex++) {
        if ($structureLines[$lineIndex] -notmatch '^[ \t]*(`{3,}|~{3,})') {
            continue
        }
        $marker = $Matches[1]
        if ($null -eq $fenceMarker) {
            $fenceMarker = $marker[0]
            $fenceLength = $marker.Length
            $fenceStartLine = $lineIndex + 1
        } elseif ($marker[0] -eq $fenceMarker -and $marker.Length -ge $fenceLength) {
            $fenceMarker = $null
            $fenceLength = 0
            $fenceStartLine = 0
        }
    }
    if ($null -ne $fenceMarker) {
        $errors.Add("Unclosed fenced code block in ${relative}:$fenceStartLine")
    }

    $linkContent = Mask-MarkdownCode -Content $content

    $commentOpenIndex = -1
    foreach ($commentToken in [regex]::Matches($linkContent, '<!--|-->')) {
        $commentLine = Get-LineNumber -Content $content -Index $commentToken.Index
        if ($commentToken.Value -eq '<!--') {
            if ($commentOpenIndex -ge 0) {
                $errors.Add("Nested or unclosed HTML comment in ${relative}:$commentLine")
            } else {
                $commentOpenIndex = $commentToken.Index
            }
        } elseif ($commentOpenIndex -lt 0) {
            $errors.Add("Closing HTML comment without an opening delimiter in ${relative}:$commentLine")
        } else {
            $commentOpenIndex = -1
        }
    }
    if ($commentOpenIndex -ge 0) {
        $commentLine = Get-LineNumber -Content $content -Index $commentOpenIndex
        $errors.Add("Opening HTML comment without a closing delimiter in ${relative}:$commentLine")
    }

    $headingContent = [regex]::Replace($linkContent, '(?s)<!--.*?-->', '')
    $seenHeadings = @{}
    foreach ($headingMatch in [regex]::Matches($headingContent, '(?m)^#{1,6}\s+(.+?)\s*$')) {
        $normalizedHeading = Normalize-WikiHeading -Heading $headingMatch.Groups[1].Value
        if ($seenHeadings.ContainsKey($normalizedHeading)) {
            $headingLine = Get-LineNumber -Content $content -Index $headingMatch.Index
            $errors.Add("Duplicate heading creates an ambiguous anchor in ${relative}:${headingLine}: $($headingMatch.Groups[1].Value)")
        } else {
            $seenHeadings[$normalizedHeading] = $true
        }
    }

    $tableLines = $linkContent -split '\r?\n'
    $tableLineNumbers = [System.Collections.Generic.HashSet[int]]::new()
    for ($alignmentIndex = 0; $alignmentIndex -lt $tableLines.Count; $alignmentIndex++) {
        if (-not (Test-MarkdownAlignmentRow -Line $tableLines[$alignmentIndex])) {
            continue
        }
        if ($alignmentIndex -eq 0 -or [string]::IsNullOrWhiteSpace($tableLines[$alignmentIndex - 1])) {
            $errors.Add("Markdown alignment row has no header in ${relative}:$($alignmentIndex + 1)")
            continue
        }

        $markdownTableCount++
        $expectedColumns = Get-MarkdownColumnCount -Line $tableLines[$alignmentIndex]
        $headerIndex = $alignmentIndex - 1
        $null = $tableLineNumbers.Add($headerIndex + 1)
        $null = $tableLineNumbers.Add($alignmentIndex + 1)
        if ((Get-MarkdownColumnCount -Line $tableLines[$headerIndex]) -ne $expectedColumns) {
            $errors.Add("Markdown table header has $((Get-MarkdownColumnCount -Line $tableLines[$headerIndex])) columns; expected $expectedColumns in ${relative}:$($headerIndex + 1)")
        }

        for ($dataIndex = $alignmentIndex + 1; $dataIndex -lt $tableLines.Count; $dataIndex++) {
            $dataLine = $tableLines[$dataIndex]
            if ([string]::IsNullOrWhiteSpace($dataLine)) {
                break
            }
            $unescapedPipes = [regex]::Matches($dataLine, '(?<!\\)\|').Count
            if (($expectedColumns -gt 1 -and $unescapedPipes -eq 0) -or
                ($expectedColumns -eq 1 -and $dataLine -notmatch '^\s*(?:>\s*)?\|')) {
                break
            }
            $null = $tableLineNumbers.Add($dataIndex + 1)
            $actualColumns = Get-MarkdownColumnCount -Line $dataLine
            if ($actualColumns -ne $expectedColumns) {
                $errors.Add("Markdown table row has $actualColumns columns; expected $expectedColumns in ${relative}:$($dataIndex + 1)")
            }
        }
    }

    foreach ($standardLink in [regex]::Matches($linkContent, '(!?)\[([^\]\r\n]*)\]\(([^\)\r\n]+)\)')) {
        $standardMarkdownLinkCount++
        $isImage = $standardLink.Groups[1].Value -eq '!'
        $label = $standardLink.Groups[2].Value.Trim()
        $destination = $standardLink.Groups[3].Value.Trim()
        $standardLine = Get-LineNumber -Content $content -Index $standardLink.Index
        if ($destination -match '^(?i)https?://') {
            $externalMarkdownLinkCount++
            if ($destination -notmatch '^https://') {
                $errors.Add("External Markdown link must use HTTPS in ${relative}:${standardLine}: $destination")
            }
            if ([string]::IsNullOrWhiteSpace($label)) {
                $errors.Add("External Markdown link needs a reader-facing label in ${relative}:${standardLine}: $destination")
            }
            if ($isImage) {
                $errors.Add("Externally hosted images are not permitted in ${relative}:${standardLine}: $destination")
            }
            try {
                $externalUri = [Uri]$destination
                if (-not $externalUri.IsAbsoluteUri -or [string]::IsNullOrWhiteSpace($externalUri.Host)) {
                    throw 'invalid URI'
                }
            } catch {
                $errors.Add("Malformed external Markdown link in ${relative}:${standardLine}: $destination")
            }
        }
    }

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
        $isTableRow = $tableLineNumbers.Contains($openLine)
        if ([regex]::Matches($innerText, '\|').Count -gt 1) {
            $errors.Add("Wikilink has multiple alias separators in ${relative}:${openLine}: [[$innerText]]")
        }
        if ($null -ne $linkParts.Alias -and -not $linkParts.AliasEscaped -and $isTableRow) {
            $errors.Add("Wikilink alias separator must be escaped as \| inside a Markdown table in ${relative}:${openLine}: [[$innerText]]")
        }
        if ($null -ne $linkParts.Alias -and $linkParts.AliasEscaped -and -not $isTableRow) {
            $errors.Add("Wikilink alias separator should not be escaped outside a Markdown table in ${relative}:${openLine}: [[$innerText]]")
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
            if ($linkParts.Target -match '[\\/]') {
                $decodedTarget = [Uri]::UnescapeDataString($linkParts.Target).Replace('\', '/')
                $resolvedRelative = $relativeByFile[$resolved.Path]
                $targetExtension = [IO.Path]::GetExtension($decodedTarget)
                $expectedTargets = if ($targetExtension) {
                    @($decodedTarget)
                } else {
                    @($decodedTarget + '.md', $decodedTarget.TrimEnd('/') + '/index.md')
                }
                $caseInsensitiveMatch = @($expectedTargets | Where-Object { $_ -ieq $resolvedRelative }).Count -gt 0
                $caseSensitiveMatch = @($expectedTargets | Where-Object { $_ -ceq $resolvedRelative }).Count -gt 0
                if ($caseInsensitiveMatch -and -not $caseSensitiveMatch) {
                    $errors.Add("Wikilink path casing differs from its target in ${relative}:${openLine}: [[$innerText]] -> $resolvedRelative")
                }
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
$manifestPath = Join-Path $vault 'raw\manifest.md'
$manifestRows = [System.Collections.Generic.List[object]]::new()
if (-not $contentByFile.ContainsKey($manifestPath)) {
    $errors.Add('Missing raw source manifest: raw/manifest.md')
} else {
    $manifestContent = $contentByFile[$manifestPath]
    foreach ($line in $manifestContent -split '\r?\n') {
        $rowMatch = [regex]::Match(
            $line,
            '^\|\s*\[\[(?<source>raw/sources/.+?)\\\|[^\]]+\]\]\s*\|\s*`(?<hash>[A-Fa-f0-9]{64})`\s*\|[^|]*\|\s*\[\[(?<page>wiki/sources/[^\]|]+)(?:\\\|[^\]]+)?\]\]\s*\|\s*$'
        )
        if (-not $rowMatch.Success) {
            if ($line -match '^\|\s*\[\[') {
                $errors.Add("Malformed raw source manifest row: $line")
            }
            continue
        }
        $manifestRows.Add([pscustomobject]@{
            Source = $rowMatch.Groups['source'].Value
            Hash = $rowMatch.Groups['hash'].Value.ToUpperInvariant()
            Page = $rowMatch.Groups['page'].Value
        })
    }
    if ($manifestRows.Count -eq 0) {
        $errors.Add('Raw source manifest contains no parseable source registry rows')
    }
    if ($manifestContent -notmatch '(?m)^source_count:\s*(\d+)\s*$' -or [int]$Matches[1] -ne $manifestRows.Count) {
        $errors.Add("Raw source manifest source_count does not equal its $($manifestRows.Count) registry rows")
    }
    foreach ($duplicate in $manifestRows | Group-Object Source | Where-Object { $_.Count -gt 1 }) {
        $errors.Add("Raw source manifest contains duplicate source rows: $($duplicate.Name)")
    }
    foreach ($duplicate in $manifestRows | Group-Object Page | Where-Object { $_.Count -gt 1 }) {
        $errors.Add("Raw source manifest contains duplicate source-page rows: $($duplicate.Name)")
    }
}

foreach ($file in $wikiFiles) {
    $relative = $relativeByFile[$file.FullName]
    $content = $contentByFile[$file.FullName]
    if ($file.BaseName -notmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') {
        $errors.Add("Wiki filename must use lowercase kebab-case: $relative")
    }
    if ($content -notmatch '(?s)^---\r?\n(.*?)\r?\n---\r?\n') {
        $errors.Add("Missing YAML frontmatter: $relative")
        continue
    }
    $frontmatter = $Matches[1]
    $frontmatterKeys = [regex]::Matches($frontmatter, '(?m)^([A-Za-z_][A-Za-z0-9_-]*):') |
        ForEach-Object { $_.Groups[1].Value }
    foreach ($duplicateKey in $frontmatterKeys | Group-Object | Where-Object { $_.Count -gt 1 }) {
        $errors.Add("Duplicate frontmatter key '$($duplicateKey.Name)': $relative")
    }
    foreach ($key in $requiredKeys) {
        if ($frontmatter -notmatch "(?m)^${key}:") {
            $errors.Add("Missing frontmatter key '$key': $relative")
        }
    }
    if ($frontmatter -match '(?m)^title:\s*([^\r\n]*)' -and [string]::IsNullOrWhiteSpace($Matches[1])) {
        $errors.Add("Empty frontmatter title: $relative")
    }
    if ($frontmatter -match '(?m)^updated:\s*([^\r\n]+)' -and $Matches[1].Trim() -notmatch '^\d{4}-\d{2}-\d{2}$') {
        $errors.Add("Invalid updated date; expected YYYY-MM-DD: $relative")
    }
    if ($frontmatter -match '(?m)^source_count:\s*([^\r\n]+)' -and $Matches[1].Trim() -notmatch '^\d+$') {
        $errors.Add("Invalid source_count; expected a non-negative integer: $relative")
    }
    if ($frontmatter -notmatch '(?m)^\s+-\s+mediahedge\s*$') {
        $errors.Add("Frontmatter tags must include mediahedge: $relative")
    }

    $pageStructure = Mask-MarkdownCode -Content $content
    $pageStructure = [regex]::Replace($pageStructure, '(?s)<!--.*?-->', '')
    $pageHeadings = [regex]::Matches($pageStructure, '(?m)^(#{1,6})\s+(.+?)\s*$')
    $h1Count = @($pageHeadings | Where-Object { $_.Groups[1].Length -eq 1 }).Count
    if ($h1Count -ne 1) {
        $errors.Add("Wiki page must contain exactly one H1 heading: $relative (found $h1Count)")
    }
    for ($headingIndex = 1; $headingIndex -lt $pageHeadings.Count; $headingIndex++) {
        $previousLevel = $pageHeadings[$headingIndex - 1].Groups[1].Length
        $currentLevel = $pageHeadings[$headingIndex].Groups[1].Length
        if ($currentLevel - $previousLevel -gt 1) {
            $line = Get-LineNumber -Content $content -Index $pageHeadings[$headingIndex].Index
            $errors.Add("Heading level jumps from H$previousLevel to H$currentLevel in ${relative}:$line")
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
        $sourceFileValue = Get-FrontmatterValue -Frontmatter $frontmatter -Name 'source_file'
        $sourceHashValue = Get-FrontmatterValue -Frontmatter $frontmatter -Name 'source_hash'
        $sourceTargetMatch = if ($null -ne $sourceFileValue) {
            [regex]::Match($sourceFileValue, '^\[\[(raw/sources/[^\]|#]+)(?:\|[^\]]+)?\]\]$')
        } else {
            $null
        }
        if ($null -eq $sourceFileValue) {
            $errors.Add("Source page missing source_file: $relative")
        } elseif ($null -eq $sourceTargetMatch -or -not $sourceTargetMatch.Success) {
            $errors.Add("Source page source_file must be one exact raw/sources wikilink: $relative")
        }
        if ($null -eq $sourceHashValue -or $sourceHashValue -notmatch '^[A-Fa-f0-9]{64}$') {
            $errors.Add("Source page has missing or invalid SHA-256: $relative")
        }
        if ($null -ne $sourceTargetMatch -and $sourceTargetMatch.Success -and
            $null -ne $sourceHashValue -and $sourceHashValue -match '^[A-Fa-f0-9]{64}$') {
            $sourceTarget = $sourceTargetMatch.Groups[1].Value
            $sourceDiskPath = Join-Path $vault $sourceTarget.Replace('/', [IO.Path]::DirectorySeparatorChar)
            if (-not (Test-Path -LiteralPath $sourceDiskPath -PathType Leaf)) {
                $errors.Add("Source page references a missing raw snapshot: $relative -> $sourceTarget")
            } else {
                $resolvedSourcePath = (Resolve-Path -LiteralPath $sourceDiskPath).Path
                $resolvedSourceRelative = $relativeByFile[$resolvedSourcePath]
                if ($resolvedSourceRelative -cne $sourceTarget) {
                    $errors.Add("Source page raw-file path casing differs from the snapshot: $relative -> $sourceTarget versus $resolvedSourceRelative")
                }
                $calculatedHash = (Get-FileHash -LiteralPath $resolvedSourcePath -Algorithm SHA256).Hash.ToUpperInvariant()
                if ($sourceHashValue.ToUpperInvariant() -ne $calculatedHash) {
                    $errors.Add("Source page hash does not match its raw snapshot: $relative -> $sourceTarget")
                }
                $sourcePageTarget = $relative.Substring(0, $relative.Length - 3)
                $matchingRows = @($manifestRows | Where-Object {
                    $_.Source -ceq $sourceTarget -and $_.Page -ceq $sourcePageTarget
                })
                if ($matchingRows.Count -ne 1) {
                    $errors.Add("Source page does not have one exact manifest lineage row: $relative -> $sourceTarget")
                } elseif ($matchingRows[0].Hash -ne $calculatedHash -or
                    $matchingRows[0].Hash -ne $sourceHashValue.ToUpperInvariant()) {
                    $errors.Add("Source page, raw snapshot and manifest hashes do not agree: $relative -> $sourceTarget")
                }
            }
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
        if ($content -notmatch '(?m)^## Source Basis\s*$') {
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
    $homeContent = $contentByFile[$homePath]
    if ($homeContent -notmatch '(?m)^publish:\s*true\s*$') {
        $errors.Add('Public home note must be marked publish: true')
    }
    Test-PublishedPresentation -Content $homeContent -Relative 'MediaHedge Knowledgebase.md' -RequireContinueExploring $true
    $homeVisibleContent = [regex]::Replace($homeContent, '(?s)<!--.*?-->', '')
    $homeVisibleContent = Mask-MarkdownCode -Content $homeVisibleContent
    foreach ($match in [regex]::Matches($homeVisibleContent, '\[\[([^\]]+)\]\]')) {
        $homeParts = Get-WikiLinkParts -InnerText $match.Groups[1].Value
        $homeTarget = $homeParts.Target
        if ($homeTarget -match '^(raw/|wiki/sources/|wiki/operations/|AGENTS$|README$|index$|log$)') {
            $errors.Add("Public home visibly links to private material: [[$($match.Groups[1].Value)]]")
        }
        $isEmbed = $match.Index -gt 0 -and $homeVisibleContent[$match.Index - 1] -eq '!'
        if (-not $isEmbed -and $homeTarget -match '[\\/]' -and $null -eq $homeParts.Alias) {
            $errors.Add("Public home link exposes a technical path instead of a display label: [[$($match.Groups[1].Value)]]")
        }
    }
    if ($homeVisibleContent -match '(?i)SHA-256|source_hash|raw/sources|AGENTS\.md|wiki-lint|YAML frontmatter|Git history') {
        $errors.Add('Public home displays maintenance terminology')
    }
}

$catalogPath = Join-Path $vault 'wiki\operations\internal-catalog.md'
if (-not (Test-Path -LiteralPath $catalogPath -PathType Leaf)) {
    $errors.Add('Missing private internal catalog: wiki/operations/internal-catalog.md')
    $catalogContent = ''
} else {
    $catalogContent = $contentByFile[$catalogPath]
}

$publicWikiFiles = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
foreach ($file in $wikiFiles) {
    $relative = $relativeByFile[$file.FullName]
    $target = ($relative -replace '\.md$', '').Replace('\', '/')
    $content = $contentByFile[$file.FullName]
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
        Test-PublishedPresentation -Content $content -Relative $relative -RequireContinueExploring $true
        if ($homeContent -notmatch [regex]::Escape("[[$target")) {
            $warnings.Add("Published page absent from public home: $relative")
        }

        $visibleContent = [regex]::Replace($content, '(?s)<!--.*?-->', '')
        $visibleContent = Mask-MarkdownCode -Content $visibleContent
        if ($visibleContent -notmatch [regex]::Escape('[[MediaHedge Knowledgebase')) {
            $errors.Add("Published wiki page does not link back to the public home: $relative")
        }
        foreach ($match in [regex]::Matches($visibleContent, '\[\[([^\]]+)\]\]')) {
            $visibleParts = Get-WikiLinkParts -InnerText $match.Groups[1].Value
            $visibleTarget = $visibleParts.Target
            if ($visibleTarget -match '^(raw/|wiki/sources/|wiki/operations/|AGENTS(?:\||$)|README(?:\||$)|index(?:\||$)|log(?:\||$))') {
                $errors.Add("Published page visibly links to private material: $relative -> [[$($match.Groups[1].Value)]]")
            }
            $isEmbed = $match.Index -gt 0 -and $visibleContent[$match.Index - 1] -eq '!'
            if (-not $isEmbed -and $visibleTarget -match '[\\/]' -and $null -eq $visibleParts.Alias) {
                $errors.Add("Published navigation link exposes a technical path instead of a display label: $relative -> [[$($match.Groups[1].Value)]]")
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
    $content = $contentByFile[$file.FullName]
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
    $privateContent = $contentByFile[$privatePath]
    if ($privateContent -notmatch '(?m)^publish:\s*false\s*$') {
        $errors.Add("Private maintenance file must be marked publish: false: $privateRelative")
    }
}

$requiredToolPatterns = @{
    'publish-audit.ps1' = @('Get-RemoteFileHash', 'publish-browser-audit.ps1')
    'publish-browser-audit.ps1' = @('search-results', 'Financing Essentials', 'footerHasNavigator')
    'wiki-archive.ps1' = @("fetch origin 'refs/heads/*:refs/heads/*'", 'Preserved archive-only refs')
    'github-sync.ps1' = @('credentialLocations', 'Values are redacted')
}
foreach ($toolName in $requiredToolPatterns.Keys) {
    $toolPath = Join-Path $vault (Join-Path 'tools' $toolName)
    if (-not (Test-Path -LiteralPath $toolPath -PathType Leaf)) {
        $errors.Add("Missing required maintenance tool: tools/$toolName")
        continue
    }
    $toolContent = Read-Utf8Text -Path $toolPath
    foreach ($requiredPattern in $requiredToolPatterns[$toolName]) {
        if ($toolContent -notmatch [regex]::Escape($requiredPattern)) {
            $errors.Add("tools/$toolName is missing required integrity support: $requiredPattern")
        }
    }
}
$archiveToolContent = Read-Utf8Text -Path (Join-Path $vault 'tools\wiki-archive.ps1')
if ($archiveToolContent -match 'fetch\s+--prune' -or $archiveToolContent -match "fetch[^\r\n]*'\+refs/") {
    $errors.Add('tools/wiki-archive.ps1 must not prune or force-update recovery refs')
}
foreach ($toolFile in Get-ChildItem -LiteralPath (Join-Path $vault 'tools') -File -Filter '*.ps1') {
    $tokens = $null
    $parseErrors = $null
    [void][Management.Automation.Language.Parser]::ParseFile($toolFile.FullName, [ref]$tokens, [ref]$parseErrors)
    foreach ($parseError in $parseErrors) {
        $errors.Add("PowerShell parse error in tools/$($toolFile.Name): $($parseError.Message)")
    }
}

foreach ($template in Get-ChildItem -LiteralPath (Join-Path $vault 'templates') -File -Filter '*.md') {
    $templateContent = $contentByFile[$template.FullName]
    if ($templateContent -notmatch '(?m)^publish:\s*false\s*$') {
        $errors.Add("Template must be marked publish: false: $($relativeByFile[$template.FullName])")
    }
}

$publishCssPath = Join-Path $vault 'publish.css'
if (-not (Test-Path -LiteralPath $publishCssPath -PathType Leaf)) {
    $errors.Add('Missing reader-facing stylesheet: publish.css')
} else {
    $publishCss = Read-Utf8Text -Path $publishCssPath
    $braceDepth = 0
    foreach ($character in $publishCss.ToCharArray()) {
        if ($character -eq '{') {
            $braceDepth++
        } elseif ($character -eq '}') {
            $braceDepth--
            if ($braceDepth -lt 0) {
                break
            }
        }
    }
    if ($braceDepth -ne 0) {
        $errors.Add('publish.css has unbalanced braces')
    }
    $requiredCssPatterns = @(
        'theme-dark',
        '@media (max-width:',
        '@media print',
        'data-heading="Continue Exploring"',
        'data-heading="Start Here"',
        'data-heading="External Context"',
        'img[src$=".svg"]',
        'p:has(.image-embed)',
        '.mod-header.mod-ui',
        '.el-h1 + .el-p',
        '.el-h2:has(',
        'width: 760px',
        '.table-wrapper',
        '.callout[data-callout=',
        ':focus-visible'
    )
    foreach ($requiredPattern in $requiredCssPatterns) {
        if ($publishCss -notmatch [regex]::Escape($requiredPattern)) {
            $errors.Add("publish.css is missing required reader-style support: $requiredPattern")
        }
    }
}

$publishJsPath = Join-Path $vault 'publish.js'
if (-not (Test-Path -LiteralPath $publishJsPath -PathType Leaf)) {
    $errors.Add('Missing reader-navigation script: publish.js')
} else {
    $publishJs = Read-Utf8Text -Path $publishJsPath
    $requiredJsPatterns = @(
        'Search the Knowledgebase',
        'MutationObserver',
        'wiki/syntheses/site-navigator.md',
        'Financing Essentials',
        'Guides & Decision Maps'
    )
    foreach ($requiredPattern in $requiredJsPatterns) {
        if ($publishJs -notmatch [regex]::Escape($requiredPattern)) {
            $errors.Add("publish.js is missing required reader-navigation support: $requiredPattern")
        }
    }
}

$svgCount = 0
$diagramDirectory = Join-Path $vault 'assets\diagrams'
if (-not (Test-Path -LiteralPath $diagramDirectory -PathType Container)) {
    $errors.Add('Missing original diagram directory: assets/diagrams')
} else {
    foreach ($svgFile in Get-ChildItem -LiteralPath $diagramDirectory -File -Filter '*.svg') {
        $svgCount++
        $svgRelative = $relativeByFile[$svgFile.FullName]
        if ($svgFile.BaseName -notmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') {
            $errors.Add("SVG diagram filename must use lowercase kebab-case: $svgRelative")
        }
        $svgContent = Read-Utf8Text -Path $svgFile.FullName
        try {
            $svgDocument = New-Object System.Xml.XmlDocument
            $svgDocument.XmlResolver = $null
            $svgDocument.LoadXml($svgContent)
            $svgRoot = $svgDocument.DocumentElement
            if ($svgRoot.LocalName -ne 'svg') {
                $errors.Add("Diagram root element is not SVG: $svgRelative")
                continue
            }
            if ($svgRoot.GetAttribute('viewBox') -notmatch '^\s*0\s+0\s+\d+\s+\d+\s*$') {
                $errors.Add("SVG diagram needs a valid viewBox: $svgRelative")
            } else {
                $viewBoxParts = @($svgRoot.GetAttribute('viewBox') -split '\s+')
                if ($svgRoot.GetAttribute('width') -ne $viewBoxParts[2] -or
                    $svgRoot.GetAttribute('height') -ne $viewBoxParts[3]) {
                    $errors.Add("SVG width and height must match its viewBox: $svgRelative")
                }
            }
            if ($svgRoot.GetAttribute('role') -ne 'img') {
                $errors.Add("SVG diagram needs role=img: $svgRelative")
            }
            $titleNode = $svgRoot.SelectSingleNode("*[local-name()='title']")
            $descNode = $svgRoot.SelectSingleNode("*[local-name()='desc']")
            if ($null -eq $titleNode -or [string]::IsNullOrWhiteSpace($titleNode.InnerText)) {
                $errors.Add("SVG diagram needs a non-empty title: $svgRelative")
            }
            if ($null -eq $descNode -or [string]::IsNullOrWhiteSpace($descNode.InnerText)) {
                $errors.Add("SVG diagram needs a non-empty description: $svgRelative")
            }
            $ariaIds = @($svgRoot.GetAttribute('aria-labelledby') -split '\s+' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
            $titleId = if ($null -ne $titleNode) { $titleNode.GetAttribute('id') } else { '' }
            $descId = if ($null -ne $descNode) { $descNode.GetAttribute('id') } else { '' }
            if ($ariaIds.Count -ne 2 -or $titleId -notin $ariaIds -or $descId -notin $ariaIds) {
                $errors.Add("SVG aria-labelledby must reference its title and description: $svgRelative")
            }
            $svgIds = @($svgDocument.SelectNodes('//*[@id]') | ForEach-Object { $_.GetAttribute('id') })
            foreach ($duplicateSvgId in $svgIds | Group-Object | Where-Object { $_.Count -gt 1 }) {
                $errors.Add("SVG diagram has duplicate id '$($duplicateSvgId.Name)': $svgRelative")
            }
            $svgReferences = @([regex]::Matches($svgContent, 'url\(#([^\)]+)\)') |
                ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique)
            foreach ($svgReference in $svgReferences) {
                if ($svgReference -notin $svgIds) {
                    $errors.Add("SVG diagram has an unresolved internal reference '$svgReference': $svgRelative")
                }
            }
        } catch {
            $errors.Add("Invalid SVG XML in ${svgRelative}: $($_.Exception.Message)")
        }
        if ($svgContent -match '(?i)<\s*(?:script|foreignObject|image)\b' -or
            $svgContent -match '(?i)\s(?:href|xlink:href|on[a-z]+)\s*=') {
            $errors.Add("SVG diagram contains unsafe or externally dependent content: $svgRelative")
        }
        if ([int]$inbound[$svgFile.FullName] -eq 0) {
            $warnings.Add("Unreferenced SVG diagram: $svgRelative")
        }
    }
}

$sourceSnapshots = Get-ChildItem -LiteralPath (Join-Path $vault 'raw\sources') -File
foreach ($source in $sourceSnapshots) {
    $sourceTarget = 'raw/sources/' + $source.Name
    $matchingRows = @($manifestRows | Where-Object { $_.Source -ceq $sourceTarget })
    if ($matchingRows.Count -ne 1) {
        $errors.Add("Raw source must have one exact manifest row: $($source.Name) (found $($matchingRows.Count))")
        continue
    }
    $hash = (Get-FileHash -LiteralPath $source.FullName -Algorithm SHA256).Hash.ToUpperInvariant()
    if ($matchingRows[0].Hash -ne $hash) {
        $errors.Add("Raw source hash does not match its manifest row: $($source.Name)")
    }
}
$sourcePages = @(Get-ChildItem -LiteralPath (Join-Path $vault 'wiki\sources') -File -Filter '*.md')
if ($manifestRows.Count -ne $sourceSnapshots.Count -or $manifestRows.Count -ne $sourcePages.Count) {
    $errors.Add("Source registry cardinality differs: $($sourceSnapshots.Count) raw snapshots, $($sourcePages.Count) source pages and $($manifestRows.Count) manifest rows")
}

Write-Output "MediaHedge wiki lint"
Write-Output "Markdown files: $($markdownFiles.Count)"
Write-Output "Wiki pages: $($wikiFiles.Count)"
Write-Output "Wikilinks: $wikiLinkCount"
Write-Output "Heading and block links: $anchoredWikiLinkCount"
Write-Output "Markdown tables: $markdownTableCount"
Write-Output "Standard Markdown links: $standardMarkdownLinkCount"
Write-Output "External Markdown links: $externalMarkdownLinkCount"
Write-Output "Published diagram embeds: $diagramEmbedCount"
Write-Output "SVG diagrams: $svgCount"
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

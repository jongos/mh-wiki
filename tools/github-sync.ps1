[CmdletBinding()]
param(
    [string]$VaultRoot,
    [string]$RemoteName = 'origin',
    [string]$ExpectedRemote = 'https://github.com/jongos/mh-wiki.git'
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($VaultRoot)) {
    $VaultRoot = Split-Path -Parent $PSScriptRoot
}
$vault = (Resolve-Path -LiteralPath $VaultRoot).Path
$git = (Get-Command git.exe -ErrorAction Stop).Source

function Invoke-Git {
    param(
        [string[]]$Arguments,
        [string]$FailureMessage
    )

    $oldErrorActionPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $output = @(& $script:git @Arguments 2>&1)
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $oldErrorActionPreference
    }
    if ($exitCode -ne 0) {
        throw "$FailureMessage`n$($output | Out-String)"
    }
    return $output
}

$inside = (Invoke-Git -Arguments @('-C', $vault, 'rev-parse', '--is-inside-work-tree') -FailureMessage 'The vault is not a Git working repository').Trim()
if ($inside -ne 'true') { throw "Not a Git working repository: $vault" }

$status = @(Invoke-Git -Arguments @('-C', $vault, 'status', '--porcelain') -FailureMessage 'Unable to inspect working-tree status')
if (@($status | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) }).Count -gt 0) {
    throw 'The working repository has uncommitted or untracked changes. Preserve and commit them before GitHub synchronization.'
}

$branch = (Invoke-Git -Arguments @('-C', $vault, 'branch', '--show-current') -FailureMessage 'Unable to resolve the current branch').Trim()
if ($branch -ne 'main') { throw "GitHub synchronization requires branch main; current branch is $branch" }

$remoteNames = @(Invoke-Git -Arguments @('-C', $vault, 'remote') -FailureMessage 'Unable to inventory Git remotes')
if ($remoteNames -notcontains $RemoteName) { throw "Missing required Git remote: $RemoteName" }
$remoteUrl = (Invoke-Git -Arguments @('-C', $vault, 'remote', 'get-url', $RemoteName) -FailureMessage "Unable to resolve remote $RemoteName").Trim()
if ($remoteUrl -ne $ExpectedRemote) {
    throw "Remote $RemoteName does not match the canonical GitHub repository: $remoteUrl versus $ExpectedRemote"
}

$lintScript = Join-Path $vault 'tools\wiki-lint.ps1'
$lintOutput = @(& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $lintScript -VaultRoot $vault 2>&1)
if ($LASTEXITCODE -ne 0) { throw "Wiki lint failed:`n$($lintOutput | Out-String)" }

$credentialPattern = '(gh[pousr]_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16}|-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----|sk-[A-Za-z0-9]{20,}|xox[baprs]-[A-Za-z0-9-]{10,})'
$credentialLocations = [System.Collections.Generic.List[string]]::new()
$commits = @(Invoke-Git -Arguments @('-C', $vault, 'rev-list', '--all') -FailureMessage 'Unable to inventory commit history for credential scanning')
foreach ($commit in $commits) {
    $oldErrorActionPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $found = @(& $git -C $vault grep -n -I -E $credentialPattern $commit 2>$null)
        $grepExitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $oldErrorActionPreference
    }
    if ($grepExitCode -eq 0) {
        $shortCommit = $commit.Substring(0, [Math]::Min(12, $commit.Length))
        foreach ($match in $found) {
            $location = [string]$match
            if ($location -match '^[0-9a-f]{40,64}:(?<path>.*?):(?<line>\d+):') {
                $credentialLocations.Add("$shortCommit $($Matches['path']):$($Matches['line'])")
            } else {
                $credentialLocations.Add("$shortCommit (location unavailable)")
            }
        }
    } elseif ($grepExitCode -ne 1) {
        throw "Credential scan failed at commit $commit"
    }
}
if ($credentialLocations.Count -gt 0) {
    $redactedLocations = @($credentialLocations | Sort-Object -Unique)
    throw "Possible credential or private-key material detected. Values are redacted and nothing was pushed. Review these locations:`n$($redactedLocations | Out-String)"
}

$archiveScript = Join-Path $vault 'tools\wiki-archive.ps1'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $archiveScript -VaultRoot $vault
if ($LASTEXITCODE -ne 0) { throw 'Independent archive update or verification failed; nothing was pushed to GitHub' }

$oldTerminalPrompt = $env:GIT_TERMINAL_PROMPT
try {
    $env:GIT_TERMINAL_PROMPT = '0'
    [void](Invoke-Git -Arguments @('-C', $vault, 'push', '-u', $RemoteName, 'main') -FailureMessage 'Unable to push main to GitHub')
    [void](Invoke-Git -Arguments @('-C', $vault, 'push', $RemoteName, '--tags') -FailureMessage 'Unable to push milestone tags to GitHub')
} finally {
    $env:GIT_TERMINAL_PROMPT = $oldTerminalPrompt
}

$sourceHead = (Invoke-Git -Arguments @('-C', $vault, 'rev-parse', 'refs/heads/main') -FailureMessage 'Unable to resolve local main').Trim()
$remoteHeadLine = @(Invoke-Git -Arguments @('-C', $vault, 'ls-remote', $RemoteName, 'refs/heads/main') -FailureMessage 'Unable to resolve GitHub main')
if ($remoteHeadLine.Count -ne 1) { throw 'GitHub main did not resolve to one commit' }
$remoteHead = ([string]$remoteHeadLine[0] -split "`t", 2)[0]
if ($sourceHead -ne $remoteHead) { throw "GitHub main does not match local main: $remoteHead versus $sourceHead" }

$localTags = @(
    Invoke-Git -Arguments @('-C', $vault, 'for-each-ref', '--format=%(refname) %(objectname)', 'refs/tags') -FailureMessage 'Unable to inventory local tags' |
        Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) } |
        Sort-Object
)
$remoteTagLines = @(Invoke-Git -Arguments @('-C', $vault, 'ls-remote', '--tags', $RemoteName) -FailureMessage 'Unable to inventory GitHub tags')
$remoteTags = @(
    $remoteTagLines |
        Where-Object { $_ -notmatch '\^\{\}$' } |
        ForEach-Object {
            $parts = [string]$_ -split "`t", 2
            "$($parts[1]) $($parts[0])"
        } |
        Sort-Object
)
$tagDifferences = @(Compare-Object -ReferenceObject $localTags -DifferenceObject $remoteTags)
if ($tagDifferences.Count -gt 0) {
    throw "GitHub tags do not exactly match local tags:`n$($tagDifferences | Out-String)"
}

Write-Output 'MediaHedge GitHub synchronization passed.'
Write-Output "Remote: $RemoteName -> $remoteUrl"
Write-Output "Local main: $sourceHead"
Write-Output "GitHub main: $remoteHead"
Write-Output "Verified annotated tags: $($localTags.Count)"
Write-Output "Commits credential-scanned: $($commits.Count)"

[CmdletBinding()]
param(
    [string]$VaultRoot
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($VaultRoot)) {
    $VaultRoot = Split-Path -Parent $PSScriptRoot
}
$vault = (Resolve-Path -LiteralPath $VaultRoot).Path
$gitCommand = Get-Command git.exe -ErrorAction Stop
$git = $gitCommand.Source

$inside = & $git -C $vault rev-parse --is-inside-work-tree
if ($LASTEXITCODE -ne 0 -or $inside.Trim() -ne 'true') {
    throw "Not a Git working repository: $vault"
}

Write-Output '# MediaHedge Wiki Live Git Index'
Write-Output ''
Write-Output "Repository: $vault"
Write-Output "Generated: $([DateTime]::Now.ToString('yyyy-MM-dd HH:mm:ss zzz'))"
Write-Output ''
Write-Output '## Milestone Tags'
Write-Output ''
Write-Output '| Tag | Commit | Date | Description |'
Write-Output '| --- | --- | --- | --- |'
$tagLines = @(& $git -C $vault for-each-ref --sort=creatordate '--format=%(refname:short)%09%(*objectname:short)%09%(creatordate:short)%09%(subject)' refs/tags)
if ($LASTEXITCODE -ne 0) { throw 'Unable to read Git tags' }
foreach ($line in $tagLines) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $parts = $line -split "`t", 4
    Write-Output "| ``$($parts[0])`` | ``$($parts[1])`` | $($parts[2]) | $($parts[3]) |"
}

Write-Output ''
Write-Output '## Complete Commit History'
Write-Output ''
Write-Output '| Commit | Date | Description |'
Write-Output '| --- | --- | --- |'
$commitLines = @(& $git -C $vault log --date=short '--pretty=format:%h%x09%ad%x09%s' --all)
if ($LASTEXITCODE -ne 0) { throw 'Unable to read Git history' }
foreach ($line in $commitLines) {
    $parts = $line -split "`t", 3
    Write-Output "| ``$($parts[0])`` | $($parts[1]) | $($parts[2]) |"
}

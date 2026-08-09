[CmdletBinding()]
param(
    [string]$VaultRoot,
    [string]$ArchiveGit,
    [string]$BundleDirectory,
    [switch]$CreateBundle
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($VaultRoot)) {
    $VaultRoot = Split-Path -Parent $PSScriptRoot
}
$vault = (Resolve-Path -LiteralPath $VaultRoot).Path
$documents = [Environment]::GetFolderPath('MyDocuments')
if ([string]::IsNullOrWhiteSpace($ArchiveGit)) {
    $ArchiveGit = Join-Path $documents 'New project\MediaHedge-Wiki-Archive.git'
}
if ([string]::IsNullOrWhiteSpace($BundleDirectory)) {
    $BundleDirectory = Join-Path $documents 'New project\MediaHedge-Wiki-Bundles'
}
$git = (Get-Command git.exe -ErrorAction Stop).Source

$inside = & $git -C $vault rev-parse --is-inside-work-tree
if ($LASTEXITCODE -ne 0 -or $inside.Trim() -ne 'true') {
    throw "Not a Git working repository: $vault"
}
$status = @(& $git -C $vault status --porcelain)
if ($LASTEXITCODE -ne 0) { throw 'Unable to inspect the working repository' }
if ($status.Count -gt 0) {
    throw 'The working repository has uncommitted changes. Commit or preserve them before archiving.'
}

$archiveParent = Split-Path -Parent $ArchiveGit
if (-not (Test-Path -LiteralPath $archiveParent -PathType Container)) {
    [void](New-Item -ItemType Directory -Path $archiveParent)
}

if (-not (Test-Path -LiteralPath $ArchiveGit)) {
    & $git clone --mirror $vault $ArchiveGit
    if ($LASTEXITCODE -ne 0) { throw 'Unable to create the bare archive mirror' }
} else {
    $isBare = & $git --git-dir=$ArchiveGit rev-parse --is-bare-repository
    if ($LASTEXITCODE -ne 0 -or $isBare.Trim() -ne 'true') {
        throw "Archive target is not a bare Git repository: $ArchiveGit"
    }
    $origin = (& $git --git-dir=$ArchiveGit remote get-url origin).Trim()
    if ($LASTEXITCODE -ne 0 -or [IO.Path]::GetFullPath($origin).TrimEnd([char[]]'\/') -ne $vault.TrimEnd([char[]]'\/')) {
        throw "Archive origin does not match the MediaHedge vault: $origin"
    }
    & $git --git-dir=$ArchiveGit fetch --prune origin '+refs/heads/*:refs/heads/*' '+refs/tags/*:refs/tags/*'
    if ($LASTEXITCODE -ne 0) { throw 'Unable to update the archive mirror' }
}

& $git --git-dir=$ArchiveGit fsck --full --strict
if ($LASTEXITCODE -ne 0) { throw 'Archive mirror failed Git integrity verification' }

$sourceHead = (& $git -C $vault rev-parse HEAD).Trim()
$archiveHead = (& $git --git-dir=$ArchiveGit rev-parse refs/heads/main).Trim()
if ($sourceHead -ne $archiveHead) {
    throw "Archive main does not match the source: $archiveHead versus $sourceHead"
}

$bundlePath = $null
if ($CreateBundle) {
    if (-not (Test-Path -LiteralPath $BundleDirectory -PathType Container)) {
        [void](New-Item -ItemType Directory -Path $BundleDirectory)
    }
    $stamp = [DateTime]::Now.ToString('yyyyMMdd-HHmmss')
    $bundlePath = Join-Path $BundleDirectory "MediaHedge-Wiki-$stamp.bundle"
    if (Test-Path -LiteralPath $bundlePath) { throw "Bundle already exists: $bundlePath" }
    & $git --git-dir=$ArchiveGit bundle create $bundlePath --all
    if ($LASTEXITCODE -ne 0) { throw 'Unable to create the full-history bundle' }
    & $git bundle verify $bundlePath
    if ($LASTEXITCODE -ne 0) { throw 'Full-history bundle failed verification' }
}

Write-Output 'MediaHedge wiki archive updated.'
Write-Output "Source HEAD: $sourceHead"
Write-Output "Mirror HEAD: $archiveHead"
Write-Output "Mirror: $ArchiveGit"
if ($null -ne $bundlePath) { Write-Output "Bundle: $bundlePath" }

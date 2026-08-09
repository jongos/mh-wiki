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

function Get-BundleChecksumPath {
    param([string]$BundlePath)

    return "$BundlePath.sha256"
}

function Write-BundleChecksum {
    param([string]$BundlePath)

    $checksumPath = Get-BundleChecksumPath -BundlePath $BundlePath
    $hash = (Get-FileHash -LiteralPath $BundlePath -Algorithm SHA256).Hash.ToUpperInvariant()
    $record = "$hash *$([IO.Path]::GetFileName($BundlePath))`r`n"
    [IO.File]::WriteAllText($checksumPath, $record, (New-Object Text.UTF8Encoding($false)))
    return $checksumPath
}

function Test-BundleChecksum {
    param([string]$BundlePath)

    $checksumPath = Get-BundleChecksumPath -BundlePath $BundlePath
    if (-not (Test-Path -LiteralPath $checksumPath -PathType Leaf)) {
        throw "Missing SHA-256 checksum sidecar: $checksumPath"
    }

    $record = (Get-Content -LiteralPath $checksumPath -Raw).Trim()
    if ($record -notmatch '^([0-9A-Fa-f]{64}) \*(.+)$') {
        throw "Malformed SHA-256 checksum sidecar: $checksumPath"
    }
    $expectedName = [IO.Path]::GetFileName($BundlePath)
    if ($Matches[2] -ne $expectedName) {
        throw "Checksum filename does not match its bundle: $checksumPath"
    }
    $actualHash = (Get-FileHash -LiteralPath $BundlePath -Algorithm SHA256).Hash
    if ($Matches[1] -ne $actualHash) {
        throw "Bundle SHA-256 checksum mismatch: $BundlePath"
    }
}

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

$sourceRefs = @(& $git -C $vault for-each-ref '--format=%(refname) %(objectname)' refs/heads refs/tags | Sort-Object)
if ($LASTEXITCODE -ne 0) { throw 'Unable to inventory source branches and tags' }
$archiveRefs = @(& $git --git-dir=$ArchiveGit for-each-ref '--format=%(refname) %(objectname)' refs/heads refs/tags | Sort-Object)
if ($LASTEXITCODE -ne 0) { throw 'Unable to inventory archive branches and tags' }
$refDifferences = @(Compare-Object -ReferenceObject $sourceRefs -DifferenceObject $archiveRefs)
if ($refDifferences.Count -gt 0) {
    throw "Archive branches or tags do not exactly match the source:`n$($refDifferences | Out-String)"
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
    $checksumPath = Write-BundleChecksum -BundlePath $bundlePath
    Test-BundleChecksum -BundlePath $bundlePath
}


$bundleCount = 0
if (Test-Path -LiteralPath $BundleDirectory -PathType Container) {
    foreach ($bundle in Get-ChildItem -LiteralPath $BundleDirectory -File -Filter '*.bundle' | Sort-Object Name) {
        & $git bundle verify $bundle.FullName
        if ($LASTEXITCODE -ne 0) { throw "Existing full-history bundle failed verification: $($bundle.FullName)" }
        Test-BundleChecksum -BundlePath $bundle.FullName
        $bundleCount++
    }
}

Write-Output 'MediaHedge wiki archive updated.'
Write-Output "Source HEAD: $sourceHead"
Write-Output "Mirror HEAD: $archiveHead"
Write-Output "Mirror: $ArchiveGit"
Write-Output "Verified branches and tags: $($sourceRefs.Count)"
Write-Output "Verified bundles: $bundleCount"
if ($null -ne $bundlePath) {
    Write-Output "Bundle: $bundlePath"
    Write-Output "SHA-256: $checksumPath"
}

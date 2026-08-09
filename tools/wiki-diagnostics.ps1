[CmdletBinding()]
param(
    [string]$VaultRoot,
    [string]$ArchiveGit,
    [string]$BundleDirectory,
    [switch]$DeepRestore
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
$failures = [System.Collections.Generic.List[string]]::new()
$passes = [System.Collections.Generic.List[string]]::new()

function Add-Pass {
    param([string]$Message)

    $script:passes.Add($Message)
    Write-Output "PASS: $Message"
}

function Add-Failure {
    param([string]$Message)

    $script:failures.Add($Message)
    Write-Output "FAIL: $Message"
}

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

function Get-RefSnapshot {
    param(
        [string]$Repository,
        [switch]$Bare
    )

    $arguments = if ($Bare) {
        @("--git-dir=$Repository", 'for-each-ref', '--format=%(refname) %(objectname)', 'refs/heads', 'refs/tags')
    } else {
        @('-C', $Repository, 'for-each-ref', '--format=%(refname) %(objectname)', 'refs/heads', 'refs/tags')
    }
    return @(
        Invoke-Git -Arguments $arguments -FailureMessage "Unable to read refs from $Repository" |
            Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) } |
            Sort-Object
    )
}

function Get-TrackedIndexDigest {
    param([string]$Repository)

    $records = @(Invoke-Git -Arguments @('-C', $Repository, 'ls-files', '--stage') -FailureMessage "Unable to inventory the tracked index in $Repository")
    $payload = [Text.Encoding]::UTF8.GetBytes(($records -join "`n"))
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        return ([BitConverter]::ToString($sha.ComputeHash($payload))).Replace('-', '')
    } finally {
        $sha.Dispose()
    }
}

function Remove-DiagnosticDirectory {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) { return }
    $resolved = [IO.Path]::GetFullPath($Path).TrimEnd([char[]]'\/')
    $tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd([char[]]'\/') + [IO.Path]::DirectorySeparatorChar
    if (-not $resolved.StartsWith($tempRoot, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to remove a diagnostics directory outside the system temporary directory: $resolved"
    }
    Remove-Item -LiteralPath $resolved -Recurse -Force
}

try {
    $inside = (Invoke-Git -Arguments @('-C', $vault, 'rev-parse', '--is-inside-work-tree') -FailureMessage 'The source vault is not a Git working repository').Trim()
    if ($inside -ne 'true') { throw 'The source vault is not a Git working repository' }
    Add-Pass 'source path is a Git working repository'
} catch { Add-Failure $_.Exception.Message }

try {
    $status = @(Invoke-Git -Arguments @('-C', $vault, 'status', '--porcelain') -FailureMessage 'Unable to inspect source working-tree status')
    if (@($status | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) }).Count -gt 0) {
        throw 'source working tree contains uncommitted or untracked changes'
    }
    Add-Pass 'source working tree is clean'
} catch { Add-Failure $_.Exception.Message }

try {
    [void](Invoke-Git -Arguments @('-C', $vault, 'fsck', '--full', '--strict') -FailureMessage 'Source Git object verification failed')
    Add-Pass 'source Git objects passed full strict verification'
} catch { Add-Failure $_.Exception.Message }

$sourceHead = $null
$sourceRefs = @()
try {
    $sourceHead = (Invoke-Git -Arguments @('-C', $vault, 'rev-parse', 'refs/heads/main') -FailureMessage 'Unable to resolve source main').Trim()
    $sourceRefs = @(Get-RefSnapshot -Repository $vault)
    if ($sourceRefs.Count -lt 2) { throw 'source repository has no milestone tags' }
    Add-Pass "source main and $($sourceRefs.Count - 1) milestone tags resolve"
} catch { Add-Failure $_.Exception.Message }

try {
    $tags = @(Invoke-Git -Arguments @('-C', $vault, 'tag') -FailureMessage 'Unable to inventory source tags')
    foreach ($tag in $tags) {
        $kind = (Invoke-Git -Arguments @('-C', $vault, 'cat-file', '-t', "refs/tags/$tag") -FailureMessage "Unable to inspect tag $tag").Trim()
        if ($kind -ne 'tag') { throw "Milestone tag is not annotated: $tag" }
        $peeled = (Invoke-Git -Arguments @('-C', $vault, 'rev-parse', "$tag^{}") -FailureMessage "Unable to peel tag $tag").Trim()
        [void](Invoke-Git -Arguments @('-C', $vault, 'merge-base', '--is-ancestor', $peeled, 'refs/heads/main') -FailureMessage "Milestone tag is not an ancestor of main: $tag")
    }
    Add-Pass "all $($tags.Count) milestone tags are annotated and reachable from main"
} catch { Add-Failure $_.Exception.Message }

$archiveHead = $null
try {
    if (-not (Test-Path -LiteralPath $ArchiveGit -PathType Container)) { throw "archive mirror is missing: $ArchiveGit" }
    $isBare = (Invoke-Git -Arguments @("--git-dir=$ArchiveGit", 'rev-parse', '--is-bare-repository') -FailureMessage 'Unable to inspect archive mirror').Trim()
    if ($isBare -ne 'true') { throw "archive is not a bare Git repository: $ArchiveGit" }
    [void](Invoke-Git -Arguments @("--git-dir=$ArchiveGit", 'fsck', '--full', '--strict') -FailureMessage 'Archive mirror Git object verification failed')
    Add-Pass 'archive is bare and its Git objects passed full strict verification'
} catch { Add-Failure $_.Exception.Message }

try {
    $archiveHead = (Invoke-Git -Arguments @("--git-dir=$ArchiveGit", 'rev-parse', 'refs/heads/main') -FailureMessage 'Unable to resolve archive main').Trim()
    $archiveRefs = @(Get-RefSnapshot -Repository $ArchiveGit -Bare)
    $refDifferences = @(Compare-Object -ReferenceObject $sourceRefs -DifferenceObject $archiveRefs)
    if ($refDifferences.Count -gt 0) { throw "source and archive branch/tag refs differ:`n$($refDifferences | Out-String)" }
    if ($sourceHead -ne $archiveHead) { throw "source and archive main differ: $sourceHead versus $archiveHead" }
    $sourceTree = (Invoke-Git -Arguments @('-C', $vault, 'rev-parse', 'refs/heads/main^{tree}') -FailureMessage 'Unable to resolve source tree').Trim()
    $archiveTree = (Invoke-Git -Arguments @("--git-dir=$ArchiveGit", 'rev-parse', 'refs/heads/main^{tree}') -FailureMessage 'Unable to resolve archive tree').Trim()
    if ($sourceTree -ne $archiveTree) { throw "source and archive tree objects differ: $sourceTree versus $archiveTree" }
    Add-Pass 'source and archive have identical branch refs, tag refs, main commit and main tree'
} catch { Add-Failure $_.Exception.Message }

$bundles = @()
try {
    if (-not (Test-Path -LiteralPath $BundleDirectory -PathType Container)) { throw "bundle directory is missing: $BundleDirectory" }
    $bundles = @(Get-ChildItem -LiteralPath $BundleDirectory -File -Filter '*.bundle' | Sort-Object Name)
    if ($bundles.Count -eq 0) { throw "no recovery bundles exist in $BundleDirectory" }
    foreach ($bundle in $bundles) {
        [void](Invoke-Git -Arguments @('bundle', 'verify', $bundle.FullName) -FailureMessage "Bundle verification failed: $($bundle.FullName)")
        $checksumPath = "$($bundle.FullName).sha256"
        if (-not (Test-Path -LiteralPath $checksumPath -PathType Leaf)) { throw "Missing checksum sidecar: $checksumPath" }
        $record = (Get-Content -LiteralPath $checksumPath -Raw).Trim()
        if ($record -notmatch '^([0-9A-Fa-f]{64}) \*(.+)$') { throw "Malformed checksum sidecar: $checksumPath" }
        if ($Matches[2] -ne $bundle.Name) { throw "Checksum filename does not match bundle: $checksumPath" }
        $actualHash = (Get-FileHash -LiteralPath $bundle.FullName -Algorithm SHA256).Hash
        if ($Matches[1] -ne $actualHash) { throw "Bundle checksum mismatch: $($bundle.FullName)" }
        $heads = @(Invoke-Git -Arguments @('bundle', 'list-heads', $bundle.FullName) -FailureMessage "Unable to inventory bundle refs: $($bundle.FullName)")
        $mainLine = @($heads | Where-Object { $_ -match '^[0-9a-f]{40} refs/heads/main$' })
        $headLine = @($heads | Where-Object { $_ -match '^[0-9a-f]{40} HEAD$' })
        if ($mainLine.Count -ne 1 -or $headLine.Count -ne 1) { throw "Bundle lacks one unambiguous main and HEAD ref: $($bundle.FullName)" }
        $bundleMain = ([string]$mainLine[0] -split ' ', 2)[0]
        $bundleHead = ([string]$headLine[0] -split ' ', 2)[0]
        if ($bundleMain -ne $bundleHead) { throw "Bundle main and HEAD differ: $($bundle.FullName)" }
        [void](Invoke-Git -Arguments @('-C', $vault, 'cat-file', '-e', "$bundleHead^{commit}") -FailureMessage "Bundle HEAD is absent from source history: $bundleHead")
        [void](Invoke-Git -Arguments @('-C', $vault, 'merge-base', '--is-ancestor', $bundleHead, 'refs/heads/main') -FailureMessage "Bundle HEAD is not an ancestor of source main: $bundleHead")
    }
    Add-Pass "all $($bundles.Count) bundles passed Git verification, SHA-256 verification and ancestry checks"
} catch { Add-Failure $_.Exception.Message }

try {
    $lintScript = Join-Path $vault 'tools\wiki-lint.ps1'
    $lintOutput = @(& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $lintScript -VaultRoot $vault 2>&1)
    if ($LASTEXITCODE -ne 0) { throw "Wiki lint failed:`n$($lintOutput | Out-String)" }
    Add-Pass 'wiki content, links, source hashes and Publish configuration passed lint'
} catch { Add-Failure $_.Exception.Message }

if ($DeepRestore) {
    $diagnosticRoot = Join-Path ([IO.Path]::GetTempPath()) ("MediaHedge-Wiki-Diagnostics-" + [Guid]::NewGuid().ToString('N'))
    $mirrorClone = Join-Path $diagnosticRoot 'mirror-restore'
    $bundleClone = Join-Path $diagnosticRoot 'bundle-restore'
    $guardArchive = Join-Path $diagnosticRoot 'dirty-guard.git'
    try {
        [void](New-Item -ItemType Directory -Path $diagnosticRoot)
        [void](Invoke-Git -Arguments @('clone', $ArchiveGit, $mirrorClone) -FailureMessage 'Unable to restore the archive mirror into a temporary directory')
        $restoredHead = (Invoke-Git -Arguments @('-C', $mirrorClone, 'rev-parse', 'HEAD') -FailureMessage 'Unable to resolve restored mirror HEAD').Trim()
        if ($restoredHead -ne $sourceHead) { throw "restored mirror HEAD differs from source: $restoredHead versus $sourceHead" }
        $mirrorStatus = @(Invoke-Git -Arguments @('-C', $mirrorClone, 'status', '--porcelain') -FailureMessage 'Unable to inspect restored mirror status')
        if (@($mirrorStatus | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) }).Count -gt 0) { throw 'restored mirror working tree is not clean' }
        $sourceDigest = Get-TrackedIndexDigest -Repository $vault
        $mirrorDigest = Get-TrackedIndexDigest -Repository $mirrorClone
        if ($sourceDigest -ne $mirrorDigest) { throw 'restored mirror index does not match the source index object-for-object' }
        Add-Pass 'mirror restore has the expected HEAD, an object-identical tracked index and a clean working tree'

        $tags = @(Invoke-Git -Arguments @('-C', $vault, 'tag') -FailureMessage 'Unable to inventory tags for restoration')
        foreach ($tag in $tags) {
            [void](Invoke-Git -Arguments @('-C', $mirrorClone, 'switch', '--detach', $tag) -FailureMessage "Unable to restore milestone tag $tag")
            $restoredTag = (Invoke-Git -Arguments @('-C', $mirrorClone, 'rev-parse', 'HEAD') -FailureMessage "Unable to resolve restored milestone tag $tag").Trim()
            $expectedTag = (Invoke-Git -Arguments @('-C', $vault, 'rev-parse', "$tag^{}") -FailureMessage "Unable to resolve source milestone tag $tag").Trim()
            if ($restoredTag -ne $expectedTag) { throw "restored milestone tag differs from source: $tag" }
        }
        Add-Pass "every one of the $($tags.Count) milestone tags restored to its expected commit"

        [void](Invoke-Git -Arguments @('-C', $mirrorClone, 'switch', 'main') -FailureMessage 'Unable to return the mirror restore to main')
        $oldAppData = $env:APPDATA
        try {
            $env:APPDATA = ''
            $restoredLintOutput = @(& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $mirrorClone 'tools\wiki-lint.ps1') -VaultRoot $mirrorClone 2>&1)
        } finally {
            $env:APPDATA = $oldAppData
        }
        if ($LASTEXITCODE -ne 0) { throw "Restored mirror failed wiki lint:`n$($restoredLintOutput | Out-String)" }
        Add-Pass 'the independently restored mirror passed wiki lint'

        $newestBundle = @($bundles | Sort-Object Name | Select-Object -Last 1)[0]
        [void](Invoke-Git -Arguments @('clone', $newestBundle.FullName, $bundleClone) -FailureMessage 'Unable to restore the newest bundle into a temporary directory')
        $bundleRestoredHead = (Invoke-Git -Arguments @('-C', $bundleClone, 'rev-parse', 'HEAD') -FailureMessage 'Unable to resolve restored bundle HEAD').Trim()
        $bundleHeads = @(Invoke-Git -Arguments @('bundle', 'list-heads', $newestBundle.FullName) -FailureMessage 'Unable to read newest bundle HEAD')
        $expectedBundleHead = ((@($bundleHeads | Where-Object { $_ -match '^[0-9a-f]{40} HEAD$' })[0]) -split ' ', 2)[0]
        if ($bundleRestoredHead -ne $expectedBundleHead) { throw 'restored bundle HEAD differs from the bundle manifest' }
        $bundleStatus = @(Invoke-Git -Arguments @('-C', $bundleClone, 'status', '--porcelain') -FailureMessage 'Unable to inspect restored bundle status')
        if (@($bundleStatus | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) }).Count -gt 0) { throw 'restored bundle working tree is not clean' }
        Add-Pass 'the newest bundle independently restored to its declared HEAD with a clean tree'

        [void](Invoke-Git -Arguments @('-C', $mirrorClone, 'rm', '--cached', '--', 'README.md') -FailureMessage 'Unable to create a temporary dirty-index recovery test')
        $oldErrorActionPreference = $ErrorActionPreference
        try {
            $ErrorActionPreference = 'Continue'
            $archiveGuardOutput = @(& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $vault 'tools\wiki-archive.ps1') -VaultRoot $mirrorClone -ArchiveGit $guardArchive -BundleDirectory $BundleDirectory 2>&1)
            $archiveGuardExitCode = $LASTEXITCODE
        } finally {
            $ErrorActionPreference = $oldErrorActionPreference
        }
        if ($archiveGuardExitCode -eq 0 -or ($archiveGuardOutput | Out-String) -notmatch 'uncommitted changes') {
            throw 'archive dirty-tree guard did not reject a modified temporary restore'
        }
        if (Test-Path -LiteralPath $guardArchive) { throw 'archive dirty-tree guard created an archive before rejecting the modified restore' }
        [void](Invoke-Git -Arguments @('-C', $mirrorClone, 'restore', '--staged', '--', 'README.md') -FailureMessage 'Unable to clean up the temporary dirty-index recovery test')
        Add-Pass 'archive creation correctly rejected a dirty working tree before writing a backup'
    } catch {
        Add-Failure "Deep restore diagnostics failed: $($_.Exception.Message)"
    } finally {
        try { Remove-DiagnosticDirectory -Path $diagnosticRoot } catch { Add-Failure $_.Exception.Message }
    }
}

Write-Output ''
Write-Output 'MediaHedge wiki diagnostics'
Write-Output "Checks passed: $($passes.Count)"
Write-Output "Checks failed: $($failures.Count)"
if ($failures.Count -gt 0) {
    foreach ($failure in $failures) { Write-Output "ERROR: $failure" }
    exit 1
}

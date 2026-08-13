[CmdletBinding()]
param(
    [string]$VaultRoot,
    [string]$NodePath
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($VaultRoot)) {
    $VaultRoot = Split-Path -Parent $PSScriptRoot
}
$vault = (Resolve-Path -LiteralPath $VaultRoot).Path
$git = (Get-Command git.exe -ErrorAction Stop).Source
$suiteRoot = Join-Path ([IO.Path]::GetTempPath()) ("MediaHedge-Wiki-Tests-" + [Guid]::NewGuid().ToString('N'))
$testAppData = Join-Path $suiteRoot 'appdata'
$originalAppData = $env:APPDATA
$utf8NoBom = New-Object Text.UTF8Encoding($false)
$passCount = 0

function Add-TestPass {
    param([string]$Message)

    $script:passCount++
    Write-Output "PASS: $Message"
}

function Remove-TestDirectory {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) { return }
    $resolved = [IO.Path]::GetFullPath($Path).TrimEnd([char[]]'\/')
    $tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd([char[]]'\/') + [IO.Path]::DirectorySeparatorChar
    if (-not $resolved.StartsWith($tempRoot, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to remove a test directory outside the system temporary directory: $resolved"
    }
    Remove-Item -LiteralPath $resolved -Recurse -Force
}

function Copy-VaultFixture {
    param([string]$Name)

    $destination = Join-Path $script:suiteRoot $Name
    [void](New-Item -ItemType Directory -Path $destination)
    foreach ($item in Get-ChildItem -LiteralPath $script:vault -Force | Where-Object { $_.Name -ne '.git' }) {
        Copy-Item -LiteralPath $item.FullName -Destination $destination -Recurse -Force
    }
    return $destination
}

function Set-TestVaultRegistration {
    param([string]$RegisteredVault)

    $obsidianDirectory = Join-Path $script:testAppData 'obsidian'
    if (-not (Test-Path -LiteralPath $obsidianDirectory -PathType Container)) {
        [void](New-Item -ItemType Directory -Path $obsidianDirectory -Force)
    }
    $registry = @{ vaults = @{ test = @{ path = $RegisteredVault } } } | ConvertTo-Json -Depth 5
    [IO.File]::WriteAllText((Join-Path $obsidianDirectory 'obsidian.json'), $registry, $script:utf8NoBom)
}

function Invoke-PowerShellCapture {
    param(
        [string]$ScriptPath,
        [string[]]$Arguments = @()
    )

    $savedPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $output = @(& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $ScriptPath @Arguments 2>&1)
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $savedPreference
    }
    return [pscustomobject]@{ ExitCode = $exitCode; Output = $output }
}

function Invoke-TestGit {
    param(
        [string[]]$Arguments,
        [string]$FailureMessage
    )

    $savedPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $output = @(& $script:git @Arguments 2>&1)
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $savedPreference
    }
    if ($exitCode -ne 0) { throw "$FailureMessage`n$($output | Out-String)" }
    return $output
}

function Resolve-NodeExecutable {
    if (-not [string]::IsNullOrWhiteSpace($script:NodePath)) {
        return (Resolve-Path -LiteralPath $script:NodePath).Path
    }
    $command = Get-Command node.exe -ErrorAction SilentlyContinue
    if ($null -ne $command) { return $command.Source }
    $codexNode = Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe'
    if (Test-Path -LiteralPath $codexNode -PathType Leaf) { return $codexNode }
    throw 'Node.js is required for the publish.js syntax regression check.'
}

try {
    [void](New-Item -ItemType Directory -Path $suiteRoot)
    $env:APPDATA = $testAppData
    Set-TestVaultRegistration -RegisteredVault $vault

    $generator = Invoke-PowerShellCapture -ScriptPath (Join-Path $vault 'tools\generate-publish-navigation.ps1') -Arguments @('-VaultRoot', $vault, '-Check')
    if ($generator.ExitCode -ne 0) { throw "Generated navigation metadata check failed.`n$($generator.Output | Out-String)" }
    Add-TestPass 'generated reader-navigation metadata is current'

    $lint = Invoke-PowerShellCapture -ScriptPath (Join-Path $vault 'tools\wiki-lint.ps1') -Arguments @('-VaultRoot', $vault)
    if ($lint.ExitCode -ne 0) { throw "Wiki lint failed.`n$($lint.Output | Out-String)" }
    Add-TestPass 'wiki lint passed'

    $node = Resolve-NodeExecutable
    [void](Invoke-TestGit -Arguments @('--version') -FailureMessage 'Git is not available to the regression suite')
    $nodeOutput = @(& $node --check (Join-Path $vault 'publish.js') 2>&1)
    if ($LASTEXITCODE -ne 0) { throw "publish.js syntax check failed.`n$($nodeOutput | Out-String)" }
    Add-TestPass 'publish.js passed the Node.js syntax check'

    $uiAudit = Invoke-PowerShellCapture -ScriptPath (Join-Path $vault 'tools\publish-ui-fixture-audit.ps1') -Arguments @('-VaultRoot', $vault)
    if ($uiAudit.ExitCode -ne 0) { throw "Local Publish UI fixture failed.`n$($uiAudit.Output | Out-String)" }
    Add-TestPass 'local Publish UI fixture passed generated-label, accessibility and observer-scope checks'

    $driftVault = Copy-VaultFixture -Name 'navigation-drift'
    Set-TestVaultRegistration -RegisteredVault $driftVault
    $driftPage = Join-Path $driftVault 'wiki\concepts\loan-sizing.md'
    $driftContent = [IO.File]::ReadAllText($driftPage, [Text.Encoding]::UTF8)
    $changedDriftContent = [regex]::Replace($driftContent, '(?m)^title:\s*Loan Sizing\r?$', 'title: Loan Sizing Regression', 1)
    if ($changedDriftContent -eq $driftContent) { throw 'Could not prepare the generated-navigation drift fixture.' }
    [IO.File]::WriteAllText($driftPage, $changedDriftContent, $utf8NoBom)
    $driftCheck = Invoke-PowerShellCapture -ScriptPath (Join-Path $driftVault 'tools\generate-publish-navigation.ps1') -Arguments @('-VaultRoot', $driftVault, '-Check')
    if ($driftCheck.ExitCode -eq 0 -or ($driftCheck.Output -join "`n") -notmatch 'reader labels are stale') {
        throw 'Generated-navigation drift fixture did not fail safely.'
    }
    Add-TestPass 'published-title drift is rejected until publish.js is regenerated'

    $crlfVault = Copy-VaultFixture -Name 'crlf-lineage'
    Set-TestVaultRegistration -RegisteredVault $crlfVault
    foreach ($sourcePage in Get-ChildItem -LiteralPath (Join-Path $crlfVault 'wiki\sources') -File -Filter '*.md') {
        $content = [IO.File]::ReadAllText($sourcePage.FullName, [Text.Encoding]::UTF8)
        $crlf = $content.Replace("`r`n", "`n").Replace("`n", "`r`n")
        [IO.File]::WriteAllText($sourcePage.FullName, $crlf, $utf8NoBom)
    }
    $crlfLint = Invoke-PowerShellCapture -ScriptPath (Join-Path $crlfVault 'tools\wiki-lint.ps1') -Arguments @('-VaultRoot', $crlfVault)
    if ($crlfLint.ExitCode -ne 0) { throw "CRLF source-lineage fixture failed.`n$($crlfLint.Output | Out-String)" }
    Add-TestPass 'all source-lineage checks pass with CRLF working-tree files'

    $lineageVault = Copy-VaultFixture -Name 'lineage-mismatch'
    Set-TestVaultRegistration -RegisteredVault $lineageVault
    $sourcePage = Get-ChildItem -LiteralPath (Join-Path $lineageVault 'wiki\sources') -File -Filter '*.md' | Select-Object -First 1
    $sourceContent = [IO.File]::ReadAllText($sourcePage.FullName, [Text.Encoding]::UTF8)
    $changedSourceContent = [regex]::Replace(
        $sourceContent,
        '(?m)^source_hash:\s*[A-Fa-f0-9]{64}\s*$',
        ('source_hash: ' + ('0' * 64)),
        1
    )
    if ($changedSourceContent -eq $sourceContent) { throw 'Could not prepare the lineage mismatch fixture.' }
    [IO.File]::WriteAllText($sourcePage.FullName, $changedSourceContent, $utf8NoBom)
    $lineageLint = Invoke-PowerShellCapture -ScriptPath (Join-Path $lineageVault 'tools\wiki-lint.ps1') -Arguments @('-VaultRoot', $lineageVault)
    $lineageOutput = $lineageLint.Output -join "`n"
    if ($lineageLint.ExitCode -eq 0 -or
        $lineageOutput -notmatch 'Source page hash does not match its raw snapshot' -or
        $lineageOutput -notmatch 'Source page, raw snapshot and manifest hashes do not agree') {
        throw 'Exact source-lineage mismatch fixture did not produce both required failures.'
    }
    Add-TestPass 'altered source-page hashes fail raw-snapshot and manifest lineage checks'

    $archiveRoot = Join-Path $suiteRoot 'archive-additivity'
    $archiveSource = Join-Path $archiveRoot 'source'
    $archiveGit = Join-Path $archiveRoot 'archive.git'
    $archiveBundles = Join-Path $archiveRoot 'bundles'
    [void](New-Item -ItemType Directory -Path $archiveSource -Force)
    [void](Invoke-TestGit -Arguments @('-C', $archiveSource, 'init', '-b', 'main') -FailureMessage 'Unable to initialize archive source fixture')
    [void](Invoke-TestGit -Arguments @('-C', $archiveSource, 'config', 'user.name', 'MediaHedge Test') -FailureMessage 'Unable to configure archive fixture user')
    [void](Invoke-TestGit -Arguments @('-C', $archiveSource, 'config', 'user.email', 'test@example.invalid') -FailureMessage 'Unable to configure archive fixture email')
    [IO.File]::WriteAllText((Join-Path $archiveSource 'fixture.txt'), "first`n", $utf8NoBom)
    [void](Invoke-TestGit -Arguments @('-C', $archiveSource, 'add', 'fixture.txt') -FailureMessage 'Unable to stage first archive fixture')
    [void](Invoke-TestGit -Arguments @('-C', $archiveSource, 'commit', '-m', 'first') -FailureMessage 'Unable to commit first archive fixture')
    [void](Invoke-TestGit -Arguments @('-C', $archiveSource, 'tag', '-a', 'wiki-vfixture-1', '-m', 'first fixture') -FailureMessage 'Unable to tag first archive fixture')
    foreach ($iteration in 1..2) {
        $archiveUpdate = Invoke-PowerShellCapture -ScriptPath (Join-Path $vault 'tools\wiki-archive.ps1') -Arguments @('-VaultRoot', $archiveSource, '-ArchiveGit', $archiveGit, '-BundleDirectory', $archiveBundles)
        if ($archiveUpdate.ExitCode -ne 0) { throw "Archive fixture update failed.`n$($archiveUpdate.Output | Out-String)" }
        if ($iteration -eq 1) {
            [IO.File]::AppendAllText((Join-Path $archiveSource 'fixture.txt'), "second`n", $utf8NoBom)
            [void](Invoke-TestGit -Arguments @('-C', $archiveSource, 'add', 'fixture.txt') -FailureMessage 'Unable to stage second archive fixture')
            [void](Invoke-TestGit -Arguments @('-C', $archiveSource, 'commit', '-m', 'second') -FailureMessage 'Unable to commit second archive fixture')
            [void](Invoke-TestGit -Arguments @('-C', $archiveSource, 'tag', '-a', 'wiki-vfixture-2', '-m', 'second fixture') -FailureMessage 'Unable to tag second archive fixture')
        }
    }
    [void](Invoke-TestGit -Arguments @('-C', $archiveSource, 'tag', '-d', 'wiki-vfixture-1') -FailureMessage 'Unable to delete source-only archive fixture tag')
    $preservationUpdate = Invoke-PowerShellCapture -ScriptPath (Join-Path $vault 'tools\wiki-archive.ps1') -Arguments @('-VaultRoot', $archiveSource, '-ArchiveGit', $archiveGit, '-BundleDirectory', $archiveBundles)
    if ($preservationUpdate.ExitCode -ne 0 -or ($preservationUpdate.Output -join "`n") -notmatch 'Preserved archive-only refs: 1') {
        throw "Archive-only ref preservation fixture failed.`n$($preservationUpdate.Output | Out-String)"
    }
    [void](Invoke-TestGit -Arguments @("--git-dir=$archiveGit", 'rev-parse', 'refs/tags/wiki-vfixture-1') -FailureMessage 'Deleted source tag was not retained by the archive')
    Add-TestPass 'archive mirror preserves a tag deleted from the source repository'

    $credentialVault = Copy-VaultFixture -Name 'credential-redaction'
    Set-TestVaultRegistration -RegisteredVault $credentialVault
    $fakeSecret = 'gh' + 'p_' + ('A' * 24)
    [IO.File]::WriteAllText((Join-Path $credentialVault 'credential-fixture.txt'), "fixture=$fakeSecret`n", $utf8NoBom)
    [void](Invoke-TestGit -Arguments @('-C', $credentialVault, 'init', '-b', 'main') -FailureMessage 'Unable to initialize credential fixture')
    [void](Invoke-TestGit -Arguments @('-C', $credentialVault, 'config', 'user.name', 'MediaHedge Test') -FailureMessage 'Unable to configure credential fixture user')
    [void](Invoke-TestGit -Arguments @('-C', $credentialVault, 'config', 'user.email', 'test@example.invalid') -FailureMessage 'Unable to configure credential fixture email')
    [void](Invoke-TestGit -Arguments @('-C', $credentialVault, 'config', 'core.autocrlf', 'false') -FailureMessage 'Unable to configure credential fixture line endings')
    [void](Invoke-TestGit -Arguments @('-C', $credentialVault, 'add', '--all') -FailureMessage 'Unable to stage credential fixture')
    [void](Invoke-TestGit -Arguments @('-C', $credentialVault, 'commit', '-m', 'credential fixture') -FailureMessage 'Unable to commit credential fixture')
    $fixtureRemote = 'https://example.invalid/unused.git'
    [void](Invoke-TestGit -Arguments @('-C', $credentialVault, 'remote', 'add', 'origin', $fixtureRemote) -FailureMessage 'Unable to configure credential fixture remote')
    $credentialSync = Invoke-PowerShellCapture -ScriptPath (Join-Path $credentialVault 'tools\github-sync.ps1') -Arguments @('-VaultRoot', $credentialVault, '-ExpectedRemote', $fixtureRemote)
    $credentialOutput = $credentialSync.Output -join "`n"
    if ($credentialSync.ExitCode -eq 0) { throw 'Credential fixture unexpectedly passed.' }
    if ($credentialOutput.Contains($fakeSecret)) { throw 'Credential fixture exposed the detected value.' }
    if ($credentialOutput -notmatch 'Values are redacted' -or $credentialOutput -notmatch 'credential-fixture\.txt:1') {
        throw 'Credential fixture did not return its expected redacted file and line location.'
    }
    Add-TestPass 'credential findings report only redacted commit, file and line locations'

    Write-Output "MediaHedge wiki regression suite passed: $passCount checks"
} finally {
    $env:APPDATA = $originalAppData
    Remove-TestDirectory -Path $suiteRoot
}

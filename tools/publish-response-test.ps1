$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'publish-response-lib.ps1')
$asset = 'https://publish-01.obsidian.md/access/test/wiki/example.md'
$validHtml = '<html><head><meta name="robots" content="index,follow"></head><script>window.preloadPage=f("' + $asset + '");</script></html>'
$valid = @{ StatusCode = 200; ContentType = 'text/html; charset=utf-8'; RobotsHeader = ''; Html = $validHtml; ExpectedAssetUrl = $asset; Label = 'fixture' }
Assert-PublishPageResponse @valid
$cases = @(
    @{ StatusCode = 404 },
    @{ ContentType = 'application/xml' },
    @{ RobotsHeader = 'googlebot: noindex' },
    @{ Html = $validHtml.Replace('index,follow', 'noindex,follow') },
    @{ Html = $validHtml.Replace('<meta name="robots" content="index,follow">', "<meta content='none' name='googlebot'>") },
    @{ Html = $validHtml.Replace('example.md', 'example.md.md') },
    @{ Html = $validHtml.Replace('window.preloadPage', 'window.otherPage') },
    @{ Html = $validHtml + '<p>This page does not exist</p>' }
)
foreach ($case in $cases) {
    $arguments = $valid.Clone()
    foreach ($key in $case.Keys) { $arguments[$key] = $case[$key] }
    $rejected = $false
    try { Assert-PublishPageResponse @arguments } catch { $rejected = $true }
    if (-not $rejected) { throw 'Unsafe public response passed the crawler-response check.' }
}
Write-Output "Crawler response fixtures: valid HTML accepted; $($cases.Count) indexing, status, MIME, preload and soft-404 failures rejected."

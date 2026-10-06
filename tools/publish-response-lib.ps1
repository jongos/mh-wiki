function Assert-PublishPageResponse {
    param(
        [int]$StatusCode,
        [string]$ContentType,
        [string]$RobotsHeader,
        [string]$Html,
        [string]$ExpectedAssetUrl,
        [string]$Label
    )

    if ($StatusCode -ne 200 -or $ContentType -notmatch '^text/html(?:;|$)') {
        throw "Public page did not return HTTP 200 HTML: $Label"
    }
    if ($RobotsHeader -match '(?i)\b(noindex|none)\b') {
        throw "Public page has an indexing-blocking HTTP header: $Label"
    }
    foreach ($meta in [regex]::Matches($Html, '(?is)<meta\b[^>]*>')) {
        if ($meta.Value -match '(?i)\bname\s*=\s*["''](?:robots|googlebot)["'']' -and
            $meta.Value -match '(?i)\bcontent\s*=\s*["''][^"'']*\b(?:noindex|none)\b') {
            throw "Public page has an indexing-blocking meta tag: $Label"
        }
    }
    $preload = [regex]::Match($Html, 'window\.preloadPage\s*=\s*f\(["''](?<url>[^"'']+)["'']\)')
    if (-not $preload.Success -or $preload.Groups['url'].Value -cne $ExpectedAssetUrl) {
        throw "Public page has a missing or incorrect crawler preload target: $Label"
    }
    if ($Html -match '(?i)This page does not exist') {
        throw "Public page returned a soft missing-page response: $Label"
    }
}

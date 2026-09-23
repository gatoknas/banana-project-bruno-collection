#requires -Version 7
<#
.SYNOPSIS
    Checks that the Bruno collection covers every operation in the Go API's OpenAPI spec.

.DESCRIPTION
    Reads docs/swagger.json from the sibling banana-project-go-api repo, parses each root
    *.bru request for its method and URL, normalizes path parameters, and reports any spec
    operation with no matching request (MISSING) or any request not present in the spec (ORPHAN).

    Requests that use an absolute host (e.g. PROD Hello.bru) are skipped, and paths the
    collection intentionally omits (the docs/logo helpers) are ignored via -Ignore.

.EXAMPLE
    pwsh -File scripts/check-sync.ps1
#>
[CmdletBinding()]
param(
    [string]$SpecPath = (Join-Path $PSScriptRoot '..\..\banana-project-go-api\docs\swagger.json'),
    [string]$CollectionRoot = (Join-Path $PSScriptRoot '..'),
    [string[]]$Ignore = @('GET /hello/logo.png', 'GET /docs', 'GET /docs/swagger.json')
)

$ErrorActionPreference = 'Stop'
$httpMethods = @('get', 'post', 'put', 'delete', 'patch')

function ConvertTo-NormalizedPath {
    param([string]$Path)

    $p = $Path.Trim()
    $p = ($p -split '\?')[0]
    if ($p.Length -gt 1) { $p = $p.TrimEnd('/') }
    $p = [regex]::Replace($p, '\{\{[^}]*\}\}', '{}')
    $p = [regex]::Replace($p, '\{[^}]*\}', '{}')
    $p = [regex]::Replace($p, '/\d+(?=/|$)', '/{}')
    return $p
}

$specFull = [System.IO.Path]::GetFullPath($SpecPath)
if (-not (Test-Path -LiteralPath $specFull)) {
    Write-Error "Spec not found: $specFull"
    exit 2
}

$spec = Get-Content -LiteralPath $specFull -Raw | ConvertFrom-Json

$specOps = [System.Collections.Generic.HashSet[string]]::new()
foreach ($pathProp in $spec.paths.PSObject.Properties) {
    foreach ($method in $httpMethods) {
        if ($pathProp.Value.PSObject.Properties.Name -contains $method) {
            [void]$specOps.Add(("{0} {1}" -f $method.ToUpperInvariant(), (ConvertTo-NormalizedPath $pathProp.Name)))
        }
    }
}

$collectionFull = [System.IO.Path]::GetFullPath($CollectionRoot)
$bruOps = @{}
foreach ($file in (Get-ChildItem -LiteralPath $collectionFull -Filter '*.bru' -File)) {
    if ($file.Name -eq 'collection.bru') { continue }

    $method = $null
    $url = $null
    foreach ($line in (Get-Content -LiteralPath $file.FullName)) {
        if (-not $method -and $line -match '^\s*(get|post|put|delete|patch)\s*\{') {
            $method = $Matches[1].ToUpperInvariant()
            continue
        }
        if ($method -and -not $url -and $line -match '^\s*url:\s*(.+?)\s*$') {
            $url = $Matches[1]
            break
        }
    }
    if (-not $method -or -not $url) { continue }
    if ($url -notmatch '^\{\{base_url\}\}') { continue }

    $path = $url -replace '^\{\{base_url\}\}', ''
    $key = "{0} {1}" -f $method, (ConvertTo-NormalizedPath $path)
    if (-not $bruOps.ContainsKey($key)) { $bruOps[$key] = @() }
    $bruOps[$key] += $file.Name
}

$expected = @($specOps | Where-Object { $Ignore -notcontains $_ })
$ignoredInSpec = @($specOps | Where-Object { $Ignore -contains $_ })
$missing = @($expected | Where-Object { -not $bruOps.ContainsKey($_) } | Sort-Object)
$orphan = @($bruOps.Keys | Where-Object { -not $specOps.Contains($_) } | Sort-Object)

Write-Host ("Spec operations:       {0} ({1} ignored)" -f $specOps.Count, $ignoredInSpec.Count)
Write-Host ("Collection operations: {0}" -f $bruOps.Count)
Write-Host ''

if ($missing.Count -gt 0) {
    Write-Host 'MISSING (in spec, no matching request):' -ForegroundColor Red
    foreach ($op in $missing) { Write-Host ("  - {0}" -f $op) }
}
if ($orphan.Count -gt 0) {
    Write-Host 'ORPHAN (request, not in spec):' -ForegroundColor Yellow
    foreach ($op in $orphan) {
        Write-Host ("  - {0}  [{1}]" -f $op, (($bruOps[$op] | Sort-Object) -join ', '))
    }
}

if ($missing.Count -gt 0 -or $orphan.Count -gt 0) {
    Write-Host ''
    Write-Host 'FAIL: Bruno collection is out of sync with the spec.' -ForegroundColor Red
    exit 1
}

Write-Host ("OK: {0}/{0} operations covered." -f $expected.Count) -ForegroundColor Green
exit 0

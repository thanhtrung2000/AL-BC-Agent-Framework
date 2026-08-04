<#
.SYNOPSIS
    Returns the next free AL object ID within the extension's declared idRanges.

.DESCRIPTION
    Reads idRanges from app.json, scans all .al files for used object IDs, and
    returns the lowest free ID in range. Fails loudly if app.json is missing,
    idRanges is absent, or the range is exhausted. Never guesses.

.EXAMPLE
    pwsh ./next-object-id.ps1 -Type Table
    pwsh ./next-object-id.ps1 -Type Codeunit -Count 3
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet('Table','TableExtension','Page','PageExtension','Codeunit','Report',
                 'ReportExtension','Enum','EnumExtension','Interface','Query',
                 'XmlPort','PermissionSet','Profile')]
    [string]$Type = 'Table',

    [Parameter()]
    [ValidateRange(1,100)]
    [int]$Count = 1,

    [Parameter()]
    [string]$Root = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'

$appJsonPath = Join-Path $Root 'app.json'
if (-not (Test-Path $appJsonPath)) {
    Write-Error "app.json not found at '$appJsonPath'. Run from the extension root, or pass -Root."
    exit 1
}

$app = Get-Content $appJsonPath -Raw | ConvertFrom-Json

$ranges = @()
if ($app.PSObject.Properties.Name -contains 'idRanges' -and $app.idRanges) {
    $ranges = $app.idRanges | ForEach-Object {
        [pscustomobject]@{ From = [int]$_.from; To = [int]$_.to }
    }
}
elseif ($app.PSObject.Properties.Name -contains 'idRange' -and $app.idRange) {
    $ranges = @([pscustomobject]@{ From = [int]$app.idRange.from; To = [int]$app.idRange.to })
}

if (-not $ranges -or $ranges.Count -eq 0) {
    Write-Error "No idRanges declared in app.json. Add an idRanges entry before allocating object IDs."
    exit 1
}

$objectPattern = '(?im)^\s*(tableextension|pageextension|reportextension|enumextension|permissionsetextension|table|page|codeunit|report|enum|interface|query|xmlport|permissionset|profile|controladdin|entitlement)\s+(\d+)\s'

$used = New-Object System.Collections.Generic.HashSet[int]

Get-ChildItem -Path $Root -Filter '*.al' -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '[\\/](\.alpackages|\.altemplates|\.vscode|node_modules)[\\/]' } |
    ForEach-Object {
        $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
        if ($content) {
            foreach ($m in [regex]::Matches($content, $objectPattern)) {
                [void]$used.Add([int]$m.Groups[2].Value)
            }
        }
    }

$free = @()
foreach ($r in $ranges) {
    for ($id = $r.From; $id -le $r.To; $id++) {
        if (-not $used.Contains($id)) {
            $free += $id
            if ($free.Count -ge $Count) { break }
        }
    }
    if ($free.Count -ge $Count) { break }
}

$rangeText = ($ranges | ForEach-Object { "$($_.From)..$($_.To)" }) -join ', '

if ($free.Count -lt $Count) {
    Write-Error "Only $($free.Count) free ID(s) available in range(s) $rangeText. Requested $Count. Extend idRanges in app.json."
    exit 1
}

Write-Host ""
Write-Host "Extension  : $($app.name) v$($app.version)"
Write-Host "Ranges     : $rangeText"
Write-Host "IDs in use : $($used.Count)"
Write-Host "Object type: $Type"
Write-Host ""
Write-Host "NEXT FREE ID$(if ($Count -gt 1) { 'S' }): $($free -join ', ')" -ForegroundColor Green
Write-Host ""

Write-Output ("ALLOCATED_IDS=" + ($free -join ','))

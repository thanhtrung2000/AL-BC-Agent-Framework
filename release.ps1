<#
.SYNOPSIS
    Releases a new version. Bumps plugin.json AND marketplace.json atomically.

.DESCRIPTION
    Bumping only one of the two files is the most common distribution bug -
    there is no error, teammates silently stay on the old version forever.

    Also detects instruction-template changes, which do NOT propagate via
    plugin update; teammates must re-run the setup skill.

.EXAMPLE
    pwsh ./release.ps1 -Version 2.1.0
    pwsh ./release.ps1 -Version 2.1.0 -Push -Message "Add al-events-builder"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)] [ValidatePattern('^\d+\.\d+\.\d+$')] [string]$Version,
    [Parameter()] [string]$Path = (Get-Location).Path,
    [Parameter()] [switch]$Push,
    [Parameter()] [string]$Message
)

$ErrorActionPreference = 'Stop'
function Ok  { param([string]$m,[string]$d='') Write-Host "[ OK ] $m" -ForegroundColor Green; if($d){Write-Host "       $d" -ForegroundColor DarkGray} }
function Bad { param([string]$m,[string]$d='') Write-Host "[FAIL] $m" -ForegroundColor Red;   if($d){Write-Host "       $d" -ForegroundColor White} }
function Warn{ param([string]$m,[string]$d='') Write-Host "[WARN] $m" -ForegroundColor Yellow;if($d){Write-Host "       $d" -ForegroundColor DarkGray} }

Write-Host ""
Write-Host "=== Release v$Version ===" -ForegroundColor Cyan
Write-Host ""

$pluginPath = Join-Path $Path 'plugin.json'
$marketPath = Join-Path $Path 'marketplace.json'

if (-not (Test-Path $pluginPath)) { Bad "plugin.json not found"; exit 1 }

$pj = Get-Content $pluginPath -Raw | ConvertFrom-Json
$oldVersion = $pj.version
Ok "plugin.json" "current: $oldVersion"

$hasMarket = Test-Path $marketPath
if ($hasMarket) {
    $mj = Get-Content $marketPath -Raw | ConvertFrom-Json
    $entry = $mj.plugins | Where-Object { $_.name -eq $pj.name } | Select-Object -First 1
    if (-not $entry) { Bad "marketplace.json has no entry for '$($pj.name)'"; exit 1 }
    Ok "marketplace.json" "current: $($entry.version)"
    if ($entry.version -ne $oldVersion) { Warn "versions were out of sync" "fixing now" }
} else { Warn "no marketplace.json" "Install-From-Source only" }

$o = $oldVersion -split '\.' | ForEach-Object { [int]$_ }
$n = $Version    -split '\.' | ForEach-Object { [int]$_ }
$isNewer = $false
for ($i=0; $i -lt 3; $i++) {
    if ($n[$i] -gt $o[$i]) { $isNewer = $true; break }
    if ($n[$i] -lt $o[$i]) { break }
}
if (-not $isNewer) { Bad "v$Version is not newer than v$oldVersion" "A same-or-lower version never installs."; exit 1 }
Ok "version is newer" "$oldVersion -> $Version"

# Instruction template changes do NOT propagate via plugin update
Write-Host ""
Write-Host "--- Checking instruction templates ---" -ForegroundColor Cyan
$instrChanged = $false
$gitOk = ($null -ne (Get-Command git -EA SilentlyContinue)) -and (Test-Path (Join-Path $Path '.git'))
if ($gitOk) {
    Push-Location $Path
    try {
        $lastTag = git describe --tags --abbrev=0 2>$null
        if ($LASTEXITCODE -eq 0 -and $lastTag) {
            $changed = git diff --name-only "$lastTag..HEAD" -- 'instructions-template/' 2>$null
            if ($changed) {
                $instrChanged = $true
                Warn "instruction templates changed since $lastTag"
                $changed | ForEach-Object { Write-Host "         $_" -ForegroundColor Yellow }
            } else { Ok "no instruction template changes since $lastTag" }
        } else { Warn "no previous tag" "cannot diff instruction templates" }
    } finally { Pop-Location }
} else { Warn "git unavailable" "skipping instruction change detection" }

Write-Host ""
Write-Host "--- Bumping versions ---" -ForegroundColor Cyan
$pj.version = $Version
$pj | ConvertTo-Json -Depth 10 | Set-Content $pluginPath -Encoding UTF8
Ok "plugin.json" "-> $Version"
if ($hasMarket) {
    foreach ($p in $mj.plugins) { if ($p.name -eq $pj.name) { $p.version = $Version } }
    $mj | ConvertTo-Json -Depth 10 | Set-Content $marketPath -Encoding UTF8
    Ok "marketplace.json" "-> $Version"
}

$checker = Join-Path $Path 'check-plugin-ready.ps1'
if (Test-Path $checker) {
    Write-Host ""
    Write-Host "--- Readiness check ---" -ForegroundColor Cyan
    & $checker -Path $Path | Out-Null
    if ($LASTEXITCODE -ne 0) { Bad "readiness check failed" "Versions bumped. Fix, then re-run."; exit 1 }
    Ok "readiness check passed"
}

if ($Push) {
    if (-not $gitOk) { Bad "git unavailable" "Versions bumped - commit manually."; exit 1 }
    if (-not $Message) { $Message = "Release v$Version" }
    Write-Host ""
    Write-Host "--- Publishing ---" -ForegroundColor Cyan
    Push-Location $Path
    try {
        git add . 2>&1 | Out-Null
        git commit -m $Message 2>&1 | Out-Null; Ok "committed" $Message
        git tag "v$Version" 2>&1 | Out-Null;    Ok "tagged" "v$Version"
        git push 2>&1 | Out-Null
        git push --tags 2>&1 | Out-Null;        Ok "pushed to origin"
    } catch { Bad "git operation failed" $_.Exception.Message; exit 1 }
    finally { Pop-Location }
}

Write-Host ""
Write-Host "=== Released v$Version ===" -ForegroundColor Cyan
Write-Host ""
if (-not $Push) {
    Write-Host "Bumped but NOT pushed. To publish:" -ForegroundColor Yellow
    Write-Host "  git add . && git commit -m `"Release v$Version`"" -ForegroundColor Gray
    Write-Host "  git tag v$Version && git push && git push --tags" -ForegroundColor Gray
    Write-Host ""
}
Write-Host "Tell your team:" -ForegroundColor White
Write-Host ""
Write-Host "  AL Framework v$Version is out." -ForegroundColor Gray
Write-Host "  Update: Ctrl/Cmd+Shift+P -> Extensions: Check for Extension Updates" -ForegroundColor Gray
Write-Host "          click Update on al-bc-framework, then reload." -ForegroundColor Gray
if ($instrChanged) {
    Write-Host ""
    Write-Host "  !! Instruction templates changed." -ForegroundColor Yellow
    Write-Host "     After updating, ALSO run in each BC repo:" -ForegroundColor Yellow
    Write-Host "       /al-bc-framework:al-framework-setup -Force" -ForegroundColor Yellow
    Write-Host "     Plugin updates do NOT touch .github/instructions/." -ForegroundColor Yellow
}
Write-Host ""
Write-Output "RELEASE_STATUS=OK"

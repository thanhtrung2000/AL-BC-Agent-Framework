<#
.SYNOPSIS
    Install and verify the AL Copilot Framework instruction files (v2.2.0).

.DESCRIPTION
    Plugins distribute agents/skills/commands - NOT instruction files. This
    script copies them into the BC repo's .github/ folder. Zero AI credits.

    v2.2.0 split: project settings live in a SEPARATE .github/al-setup.md that
    this script NEVER overwrites. copilot-instructions.md is pure conventions
    (framework-owned) and is copied/overwritten freely.

    Run in the terminal (not chat).

.PARAMETER Root
    The BC repo to install into. Defaults to the current directory.

.PARAMETER Force
    Overwrite the framework-owned files. al-setup.md is still protected.

.PARAMETER VerifyOnly
    Do not copy - only check that files exist and al-setup.md is filled in.

.EXAMPLE
    pwsh <plugin-root>/skills/al-framework-setup/scripts/install-instructions.ps1
    pwsh .../install-instructions.ps1 -VerifyOnly
#>

[CmdletBinding()]
param(
  [string]$Root = (Get-Location).Path,
  [switch]$Force,
  [switch]$VerifyOnly
)

$ErrorActionPreference = 'Stop'
$problems = @()

# --- Locate the plugin root ROBUSTLY --------------------------------------
# Walk UP from this script until we find the folder that contains
# instructions-template. This cannot miscount folder levels the way a fixed
# chain of Split-Path can (that was the v-earlier bug).
$pr = Split-Path -Parent $PSCommandPath
while ($pr -and -not (Test-Path (Join-Path $pr 'instructions-template'))) {
  $pr = Split-Path -Parent $pr
}
if (-not $pr) {
  Write-Error "Could not locate the plugin root (no 'instructions-template' folder found above this script). Is the plugin installed correctly?"
  exit 1
}

$tpl = Join-Path $pr 'instructions-template'
$gh = Join-Path $Root '.github'
$ins = Join-Path $gh 'instructions'

Write-Host ""
Write-Host "=== AL Copilot Framework Setup (v2.2.0) ===" -ForegroundColor Cyan
Write-Host "Repository : $Root"
Write-Host "Plugin     : $pr"
Write-Host ""

# --- Framework-owned files (safe to overwrite) ----------------------------
$owned = @(
  @{ S = 'copilot-instructions.md'; D = (Join-Path $gh  'copilot-instructions.md') }
  @{ S = 'instructions/al-tables.instructions.md'; D = (Join-Path $ins 'al-tables.instructions.md') }
  @{ S = 'instructions/al-pages.instructions.md'; D = (Join-Path $ins 'al-pages.instructions.md') }
  @{ S = 'instructions/al-codeunits.instructions.md'; D = (Join-Path $ins 'al-codeunits.instructions.md') }
  @{ S = 'instructions/al-reports.instructions.md'; D = (Join-Path $ins 'al-reports.instructions.md') }
  @{ S = 'instructions/al-integration.instructions.md'; D = (Join-Path $ins 'al-integration.instructions.md') }
  @{ S = 'instructions/al-plan-handoff.instructions.md'; D = (Join-Path $ins 'al-plan-handoff.instructions.md') }
)

# --- Team-owned settings file (NEVER overwritten) -------------------------
$setupSrc = Join-Path $tpl 'al-setup.md'
$setupDst = Join-Path $gh  'al-setup.md'

if (-not $VerifyOnly) {
  New-Item -ItemType Directory -Path $gh  -Force | Out-Null
  New-Item -ItemType Directory -Path $ins -Force | Out-Null

  Write-Host "--- Framework-owned files ---" -ForegroundColor Cyan
  foreach ($f in $owned) {
    $s = Join-Path $tpl $f.S
    $d = $f.D
    $n = Split-Path $d -Leaf
    if (-not (Test-Path $s)) {
      Write-Host "[FAIL] $n  (template missing at $s)" -ForegroundColor Red
      $problems += $n
      continue
    }
    Copy-Item $s $d -Force
    Write-Host "[ OK ] $n" -ForegroundColor Green
  }

  Write-Host ""
  Write-Host "--- Team-owned settings ---" -ForegroundColor Cyan
  if (Test-Path $setupDst) {
    Write-Host "[KEEP] al-setup.md exists - NOT overwritten (your settings are safe)" -ForegroundColor Cyan
  }
  elseif (-not (Test-Path $setupSrc)) {
    Write-Host "[FAIL] al-setup.md template missing at $setupSrc" -ForegroundColor Red
    $problems += 'al-setup.md'
  }
  else {
    Copy-Item $setupSrc $setupDst -Force
    Write-Host "[ NEW] al-setup.md created - fill in the 5 values next" -ForegroundColor Yellow
  }
  Write-Host ""
}

# --- Detected values from app.json (help the developer) -------------------
$appJson = Join-Path $Root 'app.json'
if (Test-Path $appJson) {
  try {
    $a = Get-Content $appJson -Raw | ConvertFrom-Json
    $rt = if ($a.idRanges) { ($a.idRanges | ForEach-Object { "$($_.from)..$($_.to)" }) -join ', ' }
    elseif ($a.idRange) { "$($a.idRange.from)..$($a.idRange.to)" }
    else { 'not declared' }
    Write-Host "--- Detected from app.json ---" -ForegroundColor Cyan
    Write-Host "  PRODUCTION ID RANGE : $rt"
    Write-Host "  TARGET BC VERSION   : $($a.application)"
    Write-Host "  PUBLISHER           : $($a.publisher)"
    Write-Host "  Copy these into .github/al-setup.md (choose AFFIX and TEST ID RANGE yourself)."
    Write-Host ""
  }
  catch {
    Write-Host "[WARN] app.json exists but could not be parsed." -ForegroundColor Yellow
    Write-Host ""
  }
}
else {
  Write-Host "[WARN] app.json not found at $appJson - run from the extension root, or pass -Root." -ForegroundColor Yellow
  Write-Host ""
  $problems += 'app.json'
}

# --- Verify files exist ---------------------------------------------------
Write-Host "--- Verifying files ---" -ForegroundColor Cyan
foreach ($f in $owned) {
  $n = Split-Path $f.D -Leaf
  if (Test-Path $f.D) { Write-Host "[ OK ] $n" -ForegroundColor Green }
  else { Write-Host "[FAIL] $n (missing)" -ForegroundColor Red; $problems += $n }
}
if (Test-Path $setupDst) { Write-Host "[ OK ] al-setup.md" -ForegroundColor Green }
else { Write-Host "[FAIL] al-setup.md (missing)" -ForegroundColor Red; $problems += 'al-setup.md' }

# --- Verify al-setup.md is filled in (no <...> placeholders) --------------
Write-Host ""
Write-Host "--- Verifying al-setup.md values ---" -ForegroundColor Cyan
if (Test-Path $setupDst) {
  $t = Get-Content $setupDst -Raw
  foreach ($k in 'AFFIX / PREFIX', 'PRODUCTION ID RANGE', 'TEST ID RANGE', 'TARGET BC VERSION', 'PUBLISHER') {
    $m = [regex]::Match($t, [regex]::Escape($k) + '\s*:\s*(.+)')
    if (-not $m.Success) {
      Write-Host "[FAIL] $k not found" -ForegroundColor Red
      $problems += "SETUP:$k"
    }
    else {
      $v = $m.Groups[1].Value.Trim()
      if ($v -match '^<.*>$' -or $v -eq '') {
        Write-Host "[FAIL] $k still a placeholder: $v" -ForegroundColor Red
        $problems += "SETUP:$k"
      }
      else {
        Write-Host "[ OK ] $k = $v" -ForegroundColor Green
      }
    }
  }
}

# --- Summary --------------------------------------------------------------
Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
if ($problems.Count -eq 0) {
  Write-Host ""
  Write-Host "Setup complete. The framework is ready." -ForegroundColor Green
  Write-Host "Next: /al-bc-framework:al-feature in the Chat view." -ForegroundColor Green
  Write-Host ""
  Write-Output "SETUP_STATUS=OK"
  exit 0
}

Write-Host ""
Write-Host "$($problems.Count) item(s) need attention:" -ForegroundColor Red
foreach ($p in ($problems | Select-Object -Unique)) { Write-Host "  - $p" -ForegroundColor White }
Write-Host ""
Write-Output "SETUP_STATUS=INCOMPLETE"
exit 1

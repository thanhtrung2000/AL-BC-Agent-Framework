<#
.SYNOPSIS
    Installs and verifies the AL Copilot Framework instruction files.

.DESCRIPTION
    Agent plugins distribute agents, skills, and commands - but NOT instruction
    files. This script copies the framework's instruction templates into the
    repository's .github/ folder so they apply to every request.

    Never silently overwrites. Existing files are skipped unless -Force, in
    which case they are backed up to .bak first.

    Exit codes: 0 = ready, 1 = something missing or incomplete.

.EXAMPLE
    pwsh ./install-instructions.ps1
    pwsh ./install-instructions.ps1 -Force
    pwsh ./install-instructions.ps1 -VerifyOnly
#>

[CmdletBinding()]
param(
    [Parameter()] [string]$Root = (Get-Location).Path,
    [Parameter()] [switch]$Force,
    [Parameter()] [switch]$VerifyOnly
)

$ErrorActionPreference = 'Stop'
$script:Problems = @()

function Add-Problem { param([string]$Item,[string]$Fix)
    $script:Problems += [pscustomobject]@{ Item=$Item; Fix=$Fix } }
function Write-Check { param([string]$Name,[bool]$Ok,[string]$Detail='')
    $mark  = if ($Ok) { '[ OK ]' } else { '[FAIL]' }
    $color = if ($Ok) { 'Green' } else { 'Red' }
    Write-Host ("{0} {1}" -f $mark,$Name) -ForegroundColor $color
    if ($Detail) { Write-Host ("       {0}" -f $Detail) -ForegroundColor DarkGray } }

# Script lives at <plugin-root>/skills/al-framework-setup/scripts/
$pluginRoot   = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSCommandPath))
$templateRoot = Join-Path $pluginRoot 'instructions-template'
$targetGithub = Join-Path $Root '.github'
$targetInstr  = Join-Path $targetGithub 'instructions'

Write-Host ""
Write-Host "=== AL Copilot Framework Setup ===" -ForegroundColor Cyan
Write-Host "Repository : $Root"
Write-Host "Plugin     : $pluginRoot"
Write-Host ""

$files = @(
    @{ Src='copilot-instructions.md';                     Dst=Join-Path $targetGithub 'copilot-instructions.md' }
    @{ Src='instructions/al-tables.instructions.md';      Dst=Join-Path $targetInstr  'al-tables.instructions.md' }
    @{ Src='instructions/al-pages.instructions.md';       Dst=Join-Path $targetInstr  'al-pages.instructions.md' }
    @{ Src='instructions/al-codeunits.instructions.md';   Dst=Join-Path $targetInstr  'al-codeunits.instructions.md' }
    @{ Src='instructions/al-reports.instructions.md';     Dst=Join-Path $targetInstr  'al-reports.instructions.md' }
    @{ Src='instructions/al-integration.instructions.md'; Dst=Join-Path $targetInstr  'al-integration.instructions.md' }
)

if (-not $VerifyOnly) {
    if (-not (Test-Path $templateRoot)) {
        Write-Error "Template folder not found: $templateRoot. Is the plugin installed correctly?"
        exit 1
    }

    New-Item -ItemType Directory -Path $targetGithub -Force | Out-Null
    New-Item -ItemType Directory -Path $targetInstr  -Force | Out-Null

    Write-Host "--- Installing instruction files ---" -ForegroundColor Cyan
    $copied = 0; $skipped = 0

    foreach ($f in $files) {
        $src = Join-Path $templateRoot $f.Src
        $dst = $f.Dst
        $name = Split-Path $dst -Leaf

        if (-not (Test-Path $src)) {
            Write-Check $name $false "Template missing: $src"
            Add-Problem $name "Reinstall the plugin - template file is missing."
            continue
        }
        if ((Test-Path $dst) -and -not $Force) {
            Write-Host "[SKIP] $name" -ForegroundColor Yellow
            Write-Host "       Already exists. Use -Force to overwrite (a .bak is kept)." -ForegroundColor DarkGray
            $skipped++; continue
        }
        if ((Test-Path $dst) -and $Force) {
            Copy-Item $dst "$dst.bak" -Force
            Write-Host "       Backed up existing file to $name.bak" -ForegroundColor DarkGray
        }
        Copy-Item $src $dst -Force
        Write-Check $name $true
        $copied++
    }
    Write-Host ""
    Write-Host "Copied: $copied   Skipped: $skipped" -ForegroundColor Cyan
    Write-Host ""
}

# --- Detected values from app.json ----------------------------------------
$appJsonPath = Join-Path $Root 'app.json'
if (Test-Path $appJsonPath) {
    try {
        $app = Get-Content $appJsonPath -Raw | ConvertFrom-Json
        $rangeText = 'not declared'
        if ($app.PSObject.Properties.Name -contains 'idRanges' -and $app.idRanges) {
            $rangeText = ($app.idRanges | ForEach-Object { "$($_.from)..$($_.to)" }) -join ', '
        } elseif ($app.PSObject.Properties.Name -contains 'idRange' -and $app.idRange) {
            $rangeText = "$($app.idRange.from)..$($app.idRange.to)"
        }
        Write-Host "--- Detected from app.json ---" -ForegroundColor Cyan
        Write-Host "  PRODUCTION ID RANGE : $rangeText"
        Write-Host "  TARGET BC VERSION   : $($app.application)"
        Write-Host "  PUBLISHER           : $($app.publisher)"
        Write-Host ""
        Write-Host "  Copy these into the SETUP block in .github/copilot-instructions.md" -ForegroundColor White
        Write-Host "  You still choose AFFIX and TEST ID RANGE yourself." -ForegroundColor White
        Write-Host ""
    } catch {
        Write-Host "[WARN] app.json exists but could not be parsed." -ForegroundColor Yellow
        Write-Host ""
    }
} else {
    Write-Host "[WARN] app.json not found at $appJsonPath" -ForegroundColor Yellow
    Write-Host "       Run from the extension root, or pass -Root <path>." -ForegroundColor DarkGray
    Write-Host ""
    Add-Problem "app.json" "Run from the extension root, or pass -Root <path>."
}

# --- Verify files ----------------------------------------------------------
Write-Host "--- Verifying installation ---" -ForegroundColor Cyan
foreach ($f in $files) {
    $dst = $f.Dst; $name = Split-Path $dst -Leaf
    $ok = Test-Path $dst
    Write-Check $name $ok
    if (-not $ok) { Add-Problem $name "Run this script without -VerifyOnly to install it."; continue }

    if ($name -like '*.instructions.md') {
        $content = Get-Content $dst -Raw
        if ($content -notmatch '(?m)^applyTo:') {
            Write-Host "       Missing applyTo - this file will never apply automatically." -ForegroundColor Red
            Add-Problem "$name applyTo" "Add an applyTo glob to the YAML frontmatter."
        }
    }
}

# --- SETUP block -----------------------------------------------------------
Write-Host ""
Write-Host "--- Verifying SETUP block ---" -ForegroundColor Cyan
$mainPath = Join-Path $targetGithub 'copilot-instructions.md'
if (Test-Path $mainPath) {
    $main = Get-Content $mainPath -Raw
    $setupKeys = @(
        @{ Label='AFFIX / PREFIX';      Pattern='AFFIX / PREFIX\s*:\s*(.+)' }
        @{ Label='PRODUCTION ID RANGE'; Pattern='PRODUCTION ID RANGE\s*:\s*(.+)' }
        @{ Label='TEST ID RANGE';       Pattern='TEST ID RANGE\s*:\s*(.+)' }
        @{ Label='TARGET BC VERSION';   Pattern='TARGET BC VERSION\s*:\s*(.+)' }
        @{ Label='PUBLISHER';           Pattern='PUBLISHER\s*:\s*(.+)' }
    )
    foreach ($k in $setupKeys) {
        $m = [regex]::Match($main, $k.Pattern)
        if (-not $m.Success) {
            Write-Check $k.Label $false "Not found in the SETUP block"
            Add-Problem $k.Label "Add it to the SETUP block in .github/copilot-instructions.md"
            continue
        }
        $value = $m.Groups[1].Value.Trim()
        $isPlaceholder = $value -match '^<.*>$' -or $value -eq ''
        Write-Check $k.Label (-not $isPlaceholder) $(if ($isPlaceholder) { "Still a placeholder: $value" } else { $value })
        if ($isPlaceholder) { Add-Problem $k.Label "Replace the placeholder in .github/copilot-instructions.md" }
    }
} else {
    Write-Check "SETUP block" $false "copilot-instructions.md not installed"
}

# --- AL analyzers ----------------------------------------------------------
Write-Host ""
Write-Host "--- Verifying AL analyzers ---" -ForegroundColor Cyan
$vsSettings = Join-Path $Root '.vscode/settings.json'
if (Test-Path $vsSettings) {
    $settingsText = Get-Content $vsSettings -Raw
    $missing = @('CodeCop','UICop','AppSourceCop','PerTenantExtensionCop') |
               Where-Object { $settingsText -notmatch $_ }
    if ($missing.Count -eq 0) { Write-Check "al.codeAnalyzers" $true "all four enabled" }
    else {
        Write-Check "al.codeAnalyzers" $false ("missing: " + ($missing -join ', '))
        Add-Problem "AL analyzers" 'Add CodeCop, UICop, AppSourceCop, PerTenantExtensionCop to al.codeAnalyzers in .vscode/settings.json'
    }
} else {
    Write-Check "al.codeAnalyzers" $false ".vscode/settings.json not found"
    Add-Problem "AL analyzers" 'Create .vscode/settings.json with al.codeAnalyzers set to all four analyzers.'
}

# --- Summary ---------------------------------------------------------------
Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
if ($script:Problems.Count -eq 0) {
    Write-Host ""
    Write-Host "Setup complete. The framework is ready." -ForegroundColor Green
    Write-Host "Next: run /al-bc-framework:al-feature in the Chat view." -ForegroundColor Green
    Write-Host ""
    Write-Output "SETUP_STATUS=OK"
    exit 0
}
Write-Host ""
Write-Host "$($script:Problems.Count) item(s) require attention:" -ForegroundColor Red
Write-Host ""
$i = 1
foreach ($p in $script:Problems) {
    Write-Host ("{0}. {1}" -f $i, $p.Item) -ForegroundColor Red
    Write-Host ("   Fix: {0}" -f $p.Fix) -ForegroundColor White
    Write-Host ""
    $i++
}
Write-Output "SETUP_STATUS=INCOMPLETE"
foreach ($p in $script:Problems) { Write-Output ("PROBLEM={0}|{1}" -f $p.Item, $p.Fix) }
exit 1

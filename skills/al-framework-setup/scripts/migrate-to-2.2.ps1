<#
.SYNOPSIS
    Migrate a v2.1.x repo to the v2.2.0 SETUP split, preserving the team's values.
.DESCRIPTION
    In v2.1.x the SETUP block lived inside copilot-instructions.md. In v2.2.0 it
    lives in a separate .github/al-setup.md that the framework never overwrites.
    This script:
      1. Reads the 5 SETUP values from the OLD copilot-instructions.md.
      2. Writes them into a new .github/al-setup.md.
      3. Replaces copilot-instructions.md with the pure v2.2.0 conventions.
    Your values are preserved - no re-typing. Zero AI credits.
.EXAMPLE
    pwsh ./migrate-to-2.2.ps1 -Source <plugin-root>/instructions-template
#>
[CmdletBinding()] param([Parameter(Mandatory=$true)][string]$Source,[string]$Repo=(Get-Location).Path)
$ErrorActionPreference='Stop'
$gh=Join-Path $Repo '.github'; $main=Join-Path $gh 'copilot-instructions.md'; $setup=Join-Path $gh 'al-setup.md'
if(-not(Test-Path $main)){Write-Host "No copilot-instructions.md - run install-instructions.ps1 for a fresh v2.2.0 setup." -ForegroundColor Yellow; exit 0}
$old=Get-Content $main -Raw
if($old -notmatch 'AFFIX / PREFIX'){Write-Host "copilot-instructions.md has no SETUP block - already v2.2.0. Nothing to migrate." -ForegroundColor Green; exit 0}
# 1. extract values
$keys='AFFIX / PREFIX','PRODUCTION ID RANGE','TEST ID RANGE','TARGET BC VERSION','PUBLISHER'
$vals=@{}
foreach($k in $keys){$m=[regex]::Match($old,[regex]::Escape($k)+'\s*:\s*(.+)'); if($m.Success){$v=$m.Groups[1].Value.Trim(); if($v -and $v -notmatch '^<.*>$'){$vals[$k]=$v}}}
Write-Host "Extracted from the old file:" -ForegroundColor Cyan
foreach($k in $keys){ if($vals.ContainsKey($k)){Write-Host "  $k = $($vals[$k])" -ForegroundColor DarkGray} }
# 2. build al-setup.md from template, inject values
if(Test-Path $setup){Write-Host "[KEEP] al-setup.md already exists - not overwriting." -ForegroundColor Cyan}
else{
  $tmpl=Get-Content (Join-Path $Source 'al-setup.md') -Raw
  foreach($k in $vals.Keys){$tmpl=[regex]::Replace($tmpl,[regex]::Escape($k)+'(\s*:\s*).+',{param($mm)"$k$($mm.Groups[1].Value)$($vals[$k])"})}
  Set-Content $setup $tmpl -Encoding UTF8 -NoNewline
  Write-Host "[ NEW] .github/al-setup.md created with your preserved values" -ForegroundColor Green
}
# 3. replace conventions file with pure v2.2.0
Copy-Item (Join-Path $Source 'copilot-instructions.md') $main -Force
Write-Host "[ OK ] copilot-instructions.md replaced with pure v2.2.0 conventions" -ForegroundColor Green
Write-Host ""
Write-Host "Migration complete. Review: git diff .github/  then commit." -ForegroundColor Green
Write-Output "MIGRATE_STATUS=OK"

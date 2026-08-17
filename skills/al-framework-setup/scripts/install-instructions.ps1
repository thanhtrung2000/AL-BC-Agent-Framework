[CmdletBinding()] param([string]$Root=(Get-Location).Path,[switch]$Force,[switch]$VerifyOnly)
$ErrorActionPreference='Stop'; $problems=@()
$pr=Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSCommandPath))
$tpl=Join-Path $pr 'instructions-template'; $gh=Join-Path $Root '.github'; $ins=Join-Path $gh 'instructions'
# framework-owned files (safe to overwrite)
$owned=@(
 @{S='copilot-instructions.md';D=Join-Path $gh 'copilot-instructions.md'}
 @{S='instructions/al-tables.instructions.md';D=Join-Path $ins 'al-tables.instructions.md'}
 @{S='instructions/al-pages.instructions.md';D=Join-Path $ins 'al-pages.instructions.md'}
 @{S='instructions/al-codeunits.instructions.md';D=Join-Path $ins 'al-codeunits.instructions.md'}
 @{S='instructions/al-reports.instructions.md';D=Join-Path $ins 'al-reports.instructions.md'}
 @{S='instructions/al-integration.instructions.md';D=Join-Path $ins 'al-integration.instructions.md'}
 @{S='instructions/al-plan-handoff.instructions.md';D=Join-Path $ins 'al-plan-handoff.instructions.md'}
)
$setupDst=Join-Path $gh 'al-setup.md'; $setupSrc=Join-Path $tpl 'al-setup.md'
if(-not $VerifyOnly){
  New-Item -ItemType Directory -Path $gh -Force|Out-Null; New-Item -ItemType Directory -Path $ins -Force|Out-Null
  foreach($f in $owned){$s=Join-Path $tpl $f.S; $d=$f.D; $n=Split-Path $d -Leaf
    if(-not(Test-Path $s)){Write-Host "[FAIL] $n missing";$problems+=$n;continue}
    Copy-Item $s $d -Force; Write-Host "[ OK ] $n (framework-owned)"}
  # al-setup.md: copy ONLY IF ABSENT - never overwrite the team's values
  if(Test-Path $setupDst){Write-Host "[KEEP] al-setup.md exists - NOT overwritten (your settings are safe)" -ForegroundColor Cyan}
  else{Copy-Item $setupSrc $setupDst -Force; Write-Host "[ NEW] al-setup.md created - fill in the 5 values" -ForegroundColor Yellow}
}
if(Test-Path (Join-Path $Root 'app.json')){$a=Get-Content (Join-Path $Root 'app.json') -Raw|ConvertFrom-Json
  $rt=if($a.idRanges){($a.idRanges|%{"$($_.from)..$($_.to)"}) -join ', '}else{'n/a'}
  Write-Host "Detected: ID $rt | app $($a.application) | publisher $($a.publisher)"}
# verify al-setup.md is filled
if(Test-Path $setupDst){$t=Get-Content $setupDst -Raw
  foreach($k in 'AFFIX / PREFIX','PRODUCTION ID RANGE','TEST ID RANGE','TARGET BC VERSION','PUBLISHER'){
    $m=[regex]::Match($t,[regex]::Escape($k)+'\s*:\s*(.+)'); if($m.Success -and ($m.Groups[1].Value.Trim() -match '^<.*>$' -or $m.Groups[1].Value.Trim() -eq '')){$problems+="SETUP:$k"}}}
else{$problems+="al-setup.md missing"}
if($problems.Count -eq 0){Write-Host "Setup complete." -ForegroundColor Green;Write-Output "SETUP_STATUS=OK";exit 0}
Write-Host "$($problems.Count) item(s): $($problems -join ', ')" -ForegroundColor Red;Write-Output "SETUP_STATUS=INCOMPLETE";exit 1

[CmdletBinding()] param([string]$Root=(Get-Location).Path,[switch]$Force,[switch]$VerifyOnly)
$ErrorActionPreference='Stop'; $problems=@()
# ROBUST: walk up until we find instructions-template (cannot miscount folder levels)
$pr=Split-Path -Parent $PSCommandPath
while($pr -and -not (Test-Path (Join-Path $pr 'instructions-template'))){ $pr=Split-Path -Parent $pr }
if(-not $pr){ Write-Error "Could not locate the plugin root (no 'instructions-template' folder above this script)."; exit 1 }
$tpl=Join-Path $pr 'instructions-template'; $gh=Join-Path $Root '.github'; $ins=Join-Path $gh 'instructions'
$owned=@(
 @{S='copilot-instructions.md';D=Join-Path $gh 'copilot-instructions.md'}
 @{S='instructions/al-language-fundamentals.instructions.md';D=Join-Path $ins 'al-language-fundamentals.instructions.md'}
 @{S='instructions/al-tables.instructions.md';D=Join-Path $ins 'al-tables.instructions.md'}
 @{S='instructions/al-pages.instructions.md';D=Join-Path $ins 'al-pages.instructions.md'}
 @{S='instructions/al-codeunits.instructions.md';D=Join-Path $ins 'al-codeunits.instructions.md'}
 @{S='instructions/al-reports.instructions.md';D=Join-Path $ins 'al-reports.instructions.md'}
 @{S='instructions/al-integration.instructions.md';D=Join-Path $ins 'al-integration.instructions.md'}
 @{S='instructions/al-plan-handoff.instructions.md';D=Join-Path $ins 'al-plan-handoff.instructions.md'}
)
$setupSrc=Join-Path $tpl 'al-setup.md'; $setupDst=Join-Path $gh 'al-setup.md'
Write-Host "Plugin: $pr" -ForegroundColor Cyan
if(-not $VerifyOnly){
  New-Item -ItemType Directory -Path $gh -Force|Out-Null; New-Item -ItemType Directory -Path $ins -Force|Out-Null
  foreach($f in $owned){$s=Join-Path $tpl $f.S; $d=$f.D; $n=Split-Path $d -Leaf
    if(-not(Test-Path $s)){Write-Host "[FAIL] $n (template missing)" -ForegroundColor Red;$problems+=$n;continue}
    Copy-Item $s $d -Force; Write-Host "[ OK ] $n" -ForegroundColor Green}
  if(Test-Path $setupDst){Write-Host "[KEEP] al-setup.md exists - NOT overwritten" -ForegroundColor Cyan}
  elseif(-not(Test-Path $setupSrc)){Write-Host "[FAIL] al-setup.md template missing" -ForegroundColor Red;$problems+='al-setup.md'}
  else{Copy-Item $setupSrc $setupDst -Force; Write-Host "[ NEW] al-setup.md created - fill in the 5 values" -ForegroundColor Yellow}
}
if(Test-Path (Join-Path $Root 'app.json')){$a=Get-Content (Join-Path $Root 'app.json') -Raw|ConvertFrom-Json
  $rt=if($a.idRanges){($a.idRanges|%{"$($_.from)..$($_.to)"}) -join ', '}else{'n/a'}
  Write-Host "Detected: ID $rt | app $($a.application) | publisher $($a.publisher)"}
if(Test-Path $setupDst){$t=Get-Content $setupDst -Raw
  foreach($k in 'AFFIX / PREFIX','PRODUCTION ID RANGE','TEST ID RANGE','TARGET BC VERSION','PUBLISHER'){
    $m=[regex]::Match($t,[regex]::Escape($k)+'\s*:\s*(.+)'); if($m.Success -and ($m.Groups[1].Value.Trim() -match '^<.*>$' -or $m.Groups[1].Value.Trim() -eq '')){$problems+="SETUP:$k"}}}
else{$problems+='al-setup.md'}
if($problems.Count -eq 0){Write-Host "Setup complete." -ForegroundColor Green;Write-Output "SETUP_STATUS=OK";exit 0}
Write-Host "$($problems.Count) item(s): $(( $problems|Select -Unique) -join ', ')" -ForegroundColor Red;Write-Output "SETUP_STATUS=INCOMPLETE";exit 1

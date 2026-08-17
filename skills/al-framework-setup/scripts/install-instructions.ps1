[CmdletBinding()] param([string]$Root=(Get-Location).Path,[switch]$Force,[switch]$VerifyOnly)
$ErrorActionPreference='Stop'; $problems=@()
$pr=Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSCommandPath))
$tpl=Join-Path $pr 'instructions-template'; $gh=Join-Path $Root '.github'; $ins=Join-Path $gh 'instructions'
$files=@(
 @{S='copilot-instructions.md';D=Join-Path $gh 'copilot-instructions.md'}
 @{S='instructions/al-tables.instructions.md';D=Join-Path $ins 'al-tables.instructions.md'}
 @{S='instructions/al-pages.instructions.md';D=Join-Path $ins 'al-pages.instructions.md'}
 @{S='instructions/al-codeunits.instructions.md';D=Join-Path $ins 'al-codeunits.instructions.md'}
 @{S='instructions/al-reports.instructions.md';D=Join-Path $ins 'al-reports.instructions.md'}
 @{S='instructions/al-integration.instructions.md';D=Join-Path $ins 'al-integration.instructions.md'}
 @{S='instructions/al-plan-handoff.instructions.md';D=Join-Path $ins 'al-plan-handoff.instructions.md'}
)
if(-not $VerifyOnly){
  New-Item -ItemType Directory -Path $gh -Force|Out-Null; New-Item -ItemType Directory -Path $ins -Force|Out-Null
  foreach($f in $files){$s=Join-Path $tpl $f.S; $d=$f.D; $n=Split-Path $d -Leaf
    if(-not(Test-Path $s)){Write-Host "[FAIL] $n missing";$problems+=$n;continue}
    if((Test-Path $d) -and -not $Force){Write-Host "[SKIP] $n";continue}
    if((Test-Path $d) -and $Force){Copy-Item $d "$d.bak" -Force}
    Copy-Item $s $d -Force; Write-Host "[ OK ] $n"}
}
if(Test-Path (Join-Path $Root 'app.json')){$a=Get-Content (Join-Path $Root 'app.json') -Raw|ConvertFrom-Json
  $rt=if($a.idRanges){($a.idRanges|%{"$($_.from)..$($_.to)"}) -join ', '}else{'n/a'}
  Write-Host "Detected: ID $rt | app $($a.application) | publisher $($a.publisher)"}
$main=Join-Path $gh 'copilot-instructions.md'
if(Test-Path $main){$t=Get-Content $main -Raw
  foreach($k in 'AFFIX','PRODUCTION ID RANGE','TEST ID RANGE','TARGET BC VERSION','PUBLISHER'){
    $m=[regex]::Match($t,[regex]::Escape($k)+'\s*:\s*(.+)')
    if($m.Success -and ($m.Groups[1].Value.Trim() -match '^<.*>$' -or $m.Groups[1].Value.Trim() -eq '')){$problems+="SETUP:$k"}}}
if($problems.Count -eq 0){Write-Host "Setup complete." -ForegroundColor Green;Write-Output "SETUP_STATUS=OK";exit 0}
Write-Host "$($problems.Count) item(s): $($problems -join ', ')" -ForegroundColor Red;Write-Output "SETUP_STATUS=INCOMPLETE";exit 1

[CmdletBinding()] param([string]$Root=(Get-Location).Path,[switch]$Force,[switch]$VerifyOnly)
$ErrorActionPreference='Stop'; $problems=@()
$pr=Split-Path -Parent $PSCommandPath
while($pr -and -not (Test-Path (Join-Path $pr 'instructions-template'))){ $pr=Split-Path -Parent $pr }
if(-not $pr){ Write-Error "Could not locate the plugin root."; exit 1 }
$tpl=Join-Path $pr 'instructions-template'; $gh=Join-Path $Root '.github'; $ins=Join-Path $gh 'instructions'
$owned=@('copilot-instructions.md','instructions/al-language-fundamentals.instructions.md','instructions/al-tables.instructions.md','instructions/al-pages.instructions.md','instructions/al-codeunits.instructions.md','instructions/al-reports.instructions.md','instructions/al-integration.instructions.md','instructions/al-plan-handoff.instructions.md')
$setupSrc=Join-Path $tpl 'al-setup.md'; $setupDst=Join-Path $gh 'al-setup.md'
Write-Host "Plugin: $pr" -ForegroundColor Cyan
if(-not $VerifyOnly){
  New-Item -ItemType Directory -Path $ins -Force|Out-Null
  foreach($rel in $owned){$s=Join-Path $tpl $rel; $d=Join-Path $gh $rel; $n=Split-Path $d -Leaf
    if(-not(Test-Path $s)){Write-Host "[FAIL] $n" -ForegroundColor Red;$problems+=$n;continue}
    New-Item -ItemType Directory -Path (Split-Path $d -Parent) -Force|Out-Null
    Copy-Item $s $d -Force; Write-Host "[ OK ] $n" -ForegroundColor Green}
  if(Test-Path $setupDst){Write-Host "[KEEP] al-setup.md exists - NOT overwritten" -ForegroundColor Cyan}
  elseif(-not(Test-Path $setupSrc)){Write-Host "[FAIL] al-setup.md template missing" -ForegroundColor Red;$problems+='al-setup.md'}
  else{Copy-Item $setupSrc $setupDst -Force; Write-Host "[ NEW] al-setup.md created - fill in the 5 values" -ForegroundColor Yellow}
}
if(Test-Path $setupDst){$t=Get-Content $setupDst -Raw
  foreach($k in 'AFFIX / PREFIX','PRODUCTION ID RANGE','TEST ID RANGE','TARGET BC VERSION','PUBLISHER'){
    $m=[regex]::Match($t,[regex]::Escape($k)+'\s*:\s*(.+)'); if($m.Success -and ($m.Groups[1].Value.Trim() -match '^<.*>$' -or $m.Groups[1].Value.Trim() -eq '')){$problems+="SETUP:$k"}}}
else{$problems+='al-setup.md'}
if($problems.Count -eq 0){Write-Host "Setup complete." -ForegroundColor Green;Write-Output "SETUP_STATUS=OK";exit 0}
Write-Host "$($problems.Count) item(s): $(($problems|Select -Unique) -join ', ')" -ForegroundColor Red;Write-Output "SETUP_STATUS=INCOMPLETE";exit 1

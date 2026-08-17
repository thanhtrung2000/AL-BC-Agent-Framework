[CmdletBinding()] param([string]$Path=(Get-Location).Path)
$ErrorActionPreference='Stop'; $fail=0
function Ok($m){Write-Host "[ OK ] $m" -ForegroundColor Green}
function Bad($m){Write-Host "[FAIL] $m" -ForegroundColor Red; $script:fail++}
$mani=$null; foreach($c in '.plugin/plugin.json','plugin.json','.github/plugin/plugin.json','.claude-plugin/plugin.json'){if(Test-Path (Join-Path $Path $c)){$mani=$c;break}}
if(-not $mani){Bad 'plugin.json not found';exit 1}; Ok "plugin.json: $mani"
$pj=Get-Content (Join-Path $Path $mani) -Raw|ConvertFrom-Json
if($pj.name -cnotmatch '^[a-z0-9-]+$'){Bad "illegal name $($pj.name)"}else{Ok "name $($pj.name)"}
if($pj.version){Ok "version $($pj.version)"}else{Bad 'no version'}
foreach($k in 'agents','skills','commands'){$p=Join-Path $Path ($pj.$k); if(Test-Path $p){Ok "$k -> $($pj.$k)"}else{Bad "$k path missing"}}
Get-ChildItem (Join-Path $Path 'skills') -Directory|%{
  $sk=Join-Path $_.FullName 'SKILL.md'
  if(-not(Test-Path $sk)){Bad "$($_.Name) no SKILL.md";return}
  $nm=((Get-Content $sk -TotalCount 10|?{$_ -match '^name:'})[0] -replace '^name:\s*','').Trim().Trim("'").Trim('"')
  if($nm -ne $_.Name){Bad "$($_.Name): name '$nm' != folder"}elseif($nm -cnotmatch '^[a-z0-9-]+$'){Bad "$($_.Name) illegal name"}else{Ok $nm}}
Get-ChildItem (Join-Path $Path 'agents') -Filter *.md|%{
  $t=Get-Content $_.FullName -Raw
  if($t -match '(?m)^agents:'){if((Get-Content $_.FullName|?{$_ -match '^tools:'})[0] -match "'agent'"){Ok "$($_.Name) has agent tool"}else{Bad "$($_.Name) declares agents: but no agent tool"}}}
$mp=Join-Path $Path 'marketplace.json'
if(Test-Path $mp){$mj=Get-Content $mp -Raw|ConvertFrom-Json; $e=$mj.plugins|?{$_.name -eq $pj.name}|Select -First 1
  if($e.version -eq $pj.version){Ok "versions match $($pj.version)"}else{Bad "version mismatch plugin=$($pj.version) market=$($e.version)"}}
if($fail -eq 0){Write-Host "Ready to push." -ForegroundColor Green;Write-Output 'PLUGIN_READY=OK';exit 0}
Write-Host "$fail problem(s)." -ForegroundColor Red;Write-Output 'PLUGIN_READY=FAIL';exit 1

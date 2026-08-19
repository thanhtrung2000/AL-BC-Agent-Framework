[CmdletBinding()] param([string]$Path=(Get-Location).Path)
$ErrorActionPreference='Stop'; $fail=0
function Ok($m){Write-Host "[ OK ] $m" -ForegroundColor Green}
function Bad($m){Write-Host "[FAIL] $m" -ForegroundColor Red; $script:fail++}
$pj=Get-Content (Join-Path $Path 'plugin.json') -Raw|ConvertFrom-Json
if($pj.name -cnotmatch '^[a-z0-9-]+$'){Bad "illegal name"}else{Ok "name $($pj.name)"}
Ok "version $($pj.version)"
foreach($k in 'agents','skills','commands'){if(Test-Path (Join-Path $Path $pj.$k)){Ok "$k"}else{Bad "$k path"}}
Get-ChildItem (Join-Path $Path 'skills') -Directory|%{$sk=Join-Path $_.FullName 'SKILL.md'
  if(-not(Test-Path $sk)){Bad "$($_.Name) no SKILL.md";return}
  $nm=((Get-Content $sk -TotalCount 8|?{$_ -match '^name:'})[0] -replace '^name:\s*','').Trim()
  if($nm -ne $_.Name){Bad "$($_.Name): name != folder"}else{Ok $nm}}
Get-ChildItem (Join-Path $Path 'agents') -Filter *.md|%{$x=Get-Content $_.FullName -Raw
  if($x -match '(?m)^agents:'){if((Get-Content $_.FullName|?{$_ -match '^tools:'})[0] -match "'agent'"){Ok "$($_.Name) agent tool"}else{Bad "$($_.Name) no agent tool"}}}
$mj=Get-Content (Join-Path $Path 'marketplace.json') -Raw|ConvertFrom-Json
if(($mj.plugins|?{$_.name -eq $pj.name}).version -eq $pj.version){Ok "versions match"}else{Bad "version mismatch"}
if($fail -eq 0){Write-Host "Ready to push." -ForegroundColor Green;Write-Output 'PLUGIN_READY=OK';exit 0}
Write-Host "$fail problem(s)." -ForegroundColor Red;Write-Output 'PLUGIN_READY=FAIL';exit 1

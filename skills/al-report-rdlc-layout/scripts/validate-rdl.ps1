[CmdletBinding()] param([Parameter(Mandatory=$true)][string]$RdlPath,[string]$ReportAlPath)
$ErrorActionPreference='Stop'; $problems=New-Object System.Collections.Generic.List[object]
function AP($c,$d){$problems.Add([pscustomobject]@{check=$c;detail=$d})}
if(-not(Test-Path $RdlPath)){Write-Output (@{rdl_status='FAIL'}|ConvertTo-Json);exit 1}
$t=Get-Content $RdlPath -Raw
try{[xml]$rdl=$t}catch{AP 'schema' "not well-formed"}
foreach($m in [regex]::Matches($t,'FILL_[A-Za-z0-9]+')){AP 'schema' "Unfilled slot: $($m.Value)"}
$used=@{};foreach($m in [regex]::Matches($t,'Fields!([A-Za-z0-9_]+)\.Value')){$used[$m.Groups[1].Value]=$true}
if($ReportAlPath -and (Test-Path $ReportAlPath)){$al=Get-Content $ReportAlPath -Raw;$cols=@{}
  foreach($m in [regex]::Matches($al,'(?im)^\s*column\s*\(\s*([A-Za-z0-9_]+)\s*;')){$cols[$m.Groups[1].Value]=$true}
  foreach($f in $used.Keys){if(-not $cols.ContainsKey($f)){AP 'bindings' "Fields!$f.Value has NO dataset column '$f' - RUNTIME FAIL"}}}
$wl=@('^=Fields!\w+\.Value$','^=Sum\(Fields!\w+\.Value\)$','^=Today\(\)$','^=Globals!PageNumber$','^="Page " & Globals!PageNumber & " of " & Globals!TotalPages$')
foreach($e in [regex]::Matches($t,'<Value>\s*(=[^<]*)</Value>')){$raw=$e.Groups[1].Value;$x=($raw -replace '&amp;','&').Trim()
  if($raw -match 'Code\.' -or $raw -match "`n"){AP 'expression' "unsafe: $x";continue}
  $m=$false;foreach($w in $wl){if($x -match $w){$m=$true;break}}; if(-not $m){AP 'expression' "not whitelisted: $x"}}
Write-Output (@{rdl_status=if($problems.Count -eq 0){'OK'}else{'PROBLEMS'};total=$problems.Count;problems=$problems}|ConvertTo-Json -Depth 5)
if($problems.Count -eq 0){Write-Host "RDL_STATUS=OK" -ForegroundColor Green;exit 0}
Write-Host "RDL_STATUS=PROBLEMS - $($problems.Count)" -ForegroundColor Red;exit 1

[CmdletBinding()] param([Parameter(Mandatory=$true)][string]$RdlPath,[string]$ReportAlPath,[string]$XsdPath)
$ErrorActionPreference='Stop'; $problems=New-Object System.Collections.Generic.List[object]
function AP($c,$d){$problems.Add([pscustomobject]@{check=$c;detail=$d})}
if(-not(Test-Path $RdlPath)){Write-Output (@{rdl_status='FAIL';error="not found"}|ConvertTo-Json);exit 1}
$t=Get-Content $RdlPath -Raw
try{[xml]$rdl=$t}catch{AP 'schema' "not well-formed: $($_.Exception.Message)"}
foreach($m in [regex]::Matches($t,'FILL_[A-Za-z0-9]+')){AP 'schema' "Unfilled slot: $($m.Value)"}
$used=@{};foreach($m in [regex]::Matches($t,'Fields!([A-Za-z0-9_]+)\.Value')){$used[$m.Groups[1].Value]=$true}
$decl=@{};foreach($m in [regex]::Matches($t,'<Field\s+Name="([A-Za-z0-9_]+)"')){$decl[$m.Groups[1].Value]=$true}
if($ReportAlPath -and (Test-Path $ReportAlPath)){$al=Get-Content $ReportAlPath -Raw;$cols=@{}
  foreach($m in [regex]::Matches($al,'(?im)^\s*column\s*\(\s*([A-Za-z0-9_]+)\s*;')){$cols[$m.Groups[1].Value]=$true}
  foreach($f in $used.Keys){if(-not $cols.ContainsKey($f)){AP 'bindings' "Fields!$f.Value has NO dataset column '$f' - RUNTIME FAIL"}}
  foreach($f in $used.Keys){if(-not $decl.ContainsKey($f)){AP 'bindings' "Fields!$f.Value not declared in <Fields>"}}}
else{AP 'bindings' "No -ReportAlPath (check skipped)"}
$wl=@('^=Fields!\w+\.Value$','^=Sum\(Fields!\w+\.Value\)$','^=CountRows\(\)$','^=Today\(\)$','^=Globals!PageNumber$','^="Page " & Globals!PageNumber & " of " & Globals!TotalPages$')
foreach($e in [regex]::Matches($t,'<Value>\s*(=[^<]*)</Value>')){$raw=$e.Groups[1].Value;$x=($raw -replace '&amp;','&').Trim()
  if($raw -match "`n" -or $raw -match 'Chr\(1[0-3]\)'){AP 'expression' "multi-line rejected: $x";continue}
  if($raw -match 'Code\.'){AP 'expression' "Code. rejected: $x";continue}
  $m=$false;foreach($w in $wl){if($x -match $w){$m=$true;break}}; if(-not $m){AP 'expression' "not whitelisted: $x"}}
$sum=@{rdl_status=if($problems.Count -eq 0){'OK'}else{'PROBLEMS'};total_issues=$problems.Count;problems=$problems}
Write-Output ($sum|ConvertTo-Json -Depth 5)
if($problems.Count -eq 0){Write-Host "RDL_STATUS=OK" -ForegroundColor Green;exit 0}
Write-Host "RDL_STATUS=PROBLEMS - $($problems.Count)" -ForegroundColor Red;exit 1

[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$RdlPath,[string]$ReportAlPath,[string]$XsdPath)
$ErrorActionPreference='Stop'
$problems=New-Object System.Collections.Generic.List[object]
function AP($c,$d){$problems.Add([pscustomobject]@{check=$c;detail=$d})}
if(-not(Test-Path $RdlPath)){Write-Output (@{rdl_status='FAIL';error="not found: $RdlPath"}|ConvertTo-Json);exit 1}
$t=Get-Content $RdlPath -Raw
# 1 schema
$ok=$true; try{[xml]$rdl=$t}catch{AP 'schema' "not well-formed: $($_.Exception.Message)";$ok=$false}
if($ok){
  if($XsdPath -and (Test-Path $XsdPath)){
    try{$s=New-Object System.Xml.XmlReaderSettings;$s.ValidationType=[System.Xml.ValidationType]::Schema;[void]$s.Schemas.Add($null,$XsdPath)
      $script:xe=@();$s.add_ValidationEventHandler([System.Xml.Schema.ValidationEventHandler]{param($a,$e)$script:xe+=$e.Message})
      $r=[System.Xml.XmlReader]::Create($RdlPath,$s);while($r.Read()){};$r.Close();foreach($m in $script:xe){AP 'schema' $m}}
    catch{AP 'schema' "XSD error: $($_.Exception.Message)"}
  } else {
    if($null -eq $rdl.Report){AP 'schema' "Missing <Report>"}
    foreach($q in 'DataSets','ReportSections'){if(-not $rdl.SelectSingleNode("//*[local-name()='$q']")){AP 'schema' "Missing <$q>"}}
    foreach($m in [regex]::Matches($t,'FILL_[A-Za-z0-9]+')){AP 'schema' "Unfilled slot: $($m.Value)"}
    if($t -match '<!--\s*FILL:'){AP 'schema' "FILL: block left in"}
  }
}
$used=@{};foreach($m in [regex]::Matches($t,'Fields!([A-Za-z0-9_]+)\.Value')){$used[$m.Groups[1].Value]=$true}
$decl=@{};foreach($m in [regex]::Matches($t,'<Field\s+Name="([A-Za-z0-9_]+)"')){$decl[$m.Groups[1].Value]=$true}
# 2 bindings
if($ReportAlPath){
  if(-not(Test-Path $ReportAlPath)){AP 'bindings' "Report AL not found (check skipped)"}
  else{$al=Get-Content $ReportAlPath -Raw;$cols=@{}
    foreach($m in [regex]::Matches($al,'(?im)^\s*column\s*\(\s*([A-Za-z0-9_]+)\s*;')){$cols[$m.Groups[1].Value]=$true}
    if($cols.Count -eq 0){AP 'bindings' "No column(...) - wrong .Report.al?"}
    foreach($f in $used.Keys){if(-not $cols.ContainsKey($f)){AP 'bindings' "Fields!$f.Value has NO dataset column '$f' - RUNTIME FAIL"}}
    foreach($f in $used.Keys){if(-not $decl.ContainsKey($f)){AP 'bindings' "Fields!$f.Value not declared in <Fields>"}}
  }
} else {AP 'bindings' "No -ReportAlPath (check skipped; recommend supplying it)"}
# 3 expression whitelist
$wl=@('^=Fields!\w+\.Value$','^=Sum\(Fields!\w+\.Value\)$','^=CountRows\(\)$','^=Today\(\)$','^=Globals!PageNumber$','^="Page " & Globals!PageNumber & " of " & Globals!TotalPages$','^=Fields!\w+\.Value( & " [^"]*" & Fields!\w+\.Value)+$')
foreach($e in [regex]::Matches($t,'<Value>\s*(=[^<]*)</Value>')){
  $raw=$e.Groups[1].Value;$x=($raw -replace '&amp;','&').Trim()
  if($raw -match "`n" -or $raw -match "`r" -or $raw -match 'Chr\(1[0-3]\)'){AP 'expression' "multi-line rejected: $x";continue}
  if($raw -match 'Code\.'){AP 'expression' "Code. rejected: $x";continue}
  $m=$false;foreach($w in $wl){if($x -match $w){$m=$true;break}}
  if(-not $m){AP 'expression' "not whitelisted: $x"}
}
$sum=@{rdl_status=if($problems.Count -eq 0){'OK'}else{'PROBLEMS'};rdl=$RdlPath;fields_used=@($used.Keys);total_issues=$problems.Count;problems=$problems}
Write-Output ($sum|ConvertTo-Json -Depth 5)
if($problems.Count -eq 0){Write-Host "RDL_STATUS=OK - preview once with Ctrl+F5." -ForegroundColor Green;exit 0}
Write-Host "RDL_STATUS=PROBLEMS - $($problems.Count) issue(s)." -ForegroundColor Red;exit 1

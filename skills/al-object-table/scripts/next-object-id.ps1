[CmdletBinding()] param([string]$Type='Table',[int]$Count=1,[string]$Root=(Get-Location).Path)
$ErrorActionPreference='Stop'
$app=Join-Path $Root 'app.json'; if(-not(Test-Path $app)){Write-Error "app.json not found";exit 1}
$j=Get-Content $app -Raw|ConvertFrom-Json
$ranges=@(); if($j.idRanges){$ranges=$j.idRanges|%{[pscustomobject]@{From=[int]$_.from;To=[int]$_.to}}}elseif($j.idRange){$ranges=@([pscustomobject]@{From=[int]$j.idRange.from;To=[int]$j.idRange.to})}
if(-not $ranges){Write-Error "No idRanges in app.json.";exit 1}
$pat='(?im)^\s*(tableextension|pageextension|reportextension|enumextension|permissionsetextension|table|page|codeunit|report|enum|interface|query|xmlport|permissionset|profile|entitlement)\s+(\d+)\s'
$used=New-Object System.Collections.Generic.HashSet[int]
Get-ChildItem $Root -Filter *.al -Recurse -File -EA SilentlyContinue|?{$_.FullName -notmatch '[\\/](\.alpackages|node_modules)[\\/]'}|%{$c=Get-Content $_.FullName -Raw -EA SilentlyContinue; if($c){foreach($m in [regex]::Matches($c,$pat)){[void]$used.Add([int]$m.Groups[2].Value)}}}
$free=@(); foreach($r in $ranges){for($id=$r.From;$id -le $r.To;$id++){if(-not $used.Contains($id)){$free+=$id;if($free.Count -ge $Count){break}}};if($free.Count -ge $Count){break}}
$rt=($ranges|%{"$($_.From)..$($_.To)"}) -join ', '
if($free.Count -lt $Count){Write-Error "Only $($free.Count) free ID(s) in $rt.";exit 1}
Write-Host "Ranges: $rt | in use: $($used.Count) | NEXT: $($free -join ', ')" -ForegroundColor Green
Write-Output ("ALLOCATED_IDS="+($free -join ','))

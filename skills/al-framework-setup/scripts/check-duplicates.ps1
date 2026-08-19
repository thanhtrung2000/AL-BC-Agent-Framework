[CmdletBinding()] param([string]$Root=(Join-Path (Get-Location).Path 'src'))
$ErrorActionPreference='Stop'; if(-not(Test-Path $Root)){ $Root=(Get-Location).Path }
$pat='(?im)^\s*(tableextension|pageextension|reportextension|enumextension|permissionsetextension|table|page|codeunit|report|enum|interface|query|xmlport|permissionset|profile|entitlement)\s+(\d+)\s+"([^"]+)"'
$decls=@()
Get-ChildItem $Root -Filter *.al -Recurse -File -EA SilentlyContinue | ForEach-Object {
    $file=$_.FullName; $c=Get-Content $file -Raw; $inFile=@()
    foreach($m in [regex]::Matches($c,$pat)){ $o=[pscustomobject]@{Type=$m.Groups[1].Value.ToLower();Id=[int]$m.Groups[2].Value;Name=$m.Groups[3].Value;File=$file}; $decls+=$o; $inFile+=$o }
    if($inFile.Count -gt 1){ Write-Host "[DUP] $([IO.Path]::GetFileName($file)) contains $($inFile.Count) objects (should be 1):" -ForegroundColor Red; $inFile|%{Write-Host "        $($_.Type) $($_.Id) `"$($_.Name)`"" -ForegroundColor White} }
}
$problems=0
$decls | Group-Object { "$($_.Type)|$($_.Id)" } | ? Count -gt 1 | %{ $problems++; $f=$_.Group[0]; Write-Host "[AL0264] $($f.Type) $($f.Id) declared $($_.Count) times" -ForegroundColor Red }
$decls | Group-Object { "$($_.Type)|$($_.Name)" } | ? Count -gt 1 | %{ $problems++; $f=$_.Group[0]; Write-Host "[AL0139] $($f.Type) `"$($f.Name)`" declared $($_.Count) times" -ForegroundColor Red }
$decls | Group-Object File | ? Count -gt 1 | %{ $problems++ }
Write-Host ""
if($problems -eq 0){ Write-Host "DUPLICATES: none. $($decls.Count) object(s), one-per-file." -ForegroundColor Green; Write-Output "DUP_STATUS=OK"; exit 0 }
Write-Host "DUPLICATES FOUND: rewrite the file(s) so each has ONE object. Do NOT append." -ForegroundColor Red
Write-Output "DUP_STATUS=FAIL"; exit 1

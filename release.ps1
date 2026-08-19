[CmdletBinding()] param([Parameter(Mandatory)][ValidatePattern('^\d+\.\d+\.\d+$')][string]$Version,[string]$Path=(Get-Location).Path,[switch]$Push,[string]$Message)
$ErrorActionPreference='Stop'
$pj=Get-Content (Join-Path $Path 'plugin.json') -Raw|ConvertFrom-Json; $old=$pj.version; $pj.version=$Version
$pj|ConvertTo-Json -Depth 10|Set-Content (Join-Path $Path 'plugin.json') -Encoding UTF8
$mp=Join-Path $Path 'marketplace.json'; if(Test-Path $mp){$mj=Get-Content $mp -Raw|ConvertFrom-Json; foreach($p in $mj.plugins){if($p.name -eq $pj.name){$p.version=$Version}}; $mj|ConvertTo-Json -Depth 10|Set-Content $mp -Encoding UTF8}
Write-Host "Bumped $old -> $Version" -ForegroundColor Green
$chk=Join-Path $Path 'check-plugin-ready.ps1'; if(Test-Path $chk){& $chk -Path $Path|Out-Null; if($LASTEXITCODE -ne 0){exit 1}}
Write-Output "RELEASE_STATUS=OK"

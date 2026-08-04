<#
.SYNOPSIS
    Verifies this repository is ready to install as a VS Code agent plugin.

.DESCRIPTION
    Run BEFORE pushing. Every failure mode checked here is SILENT at install
    time - VS Code shows no error, the component simply never appears.

.EXAMPLE
    pwsh ./check-plugin-ready.ps1
#>

[CmdletBinding()]
param([Parameter()] [string]$Path = (Get-Location).Path)

$ErrorActionPreference = 'Stop'
$script:Fail = 0

function Ok   { param([string]$m,[string]$d='') Write-Host "[ OK ] $m" -ForegroundColor Green; if($d){Write-Host "       $d" -ForegroundColor DarkGray} }
function Bad  { param([string]$m,[string]$d='') Write-Host "[FAIL] $m" -ForegroundColor Red;   if($d){Write-Host "       $d" -ForegroundColor White}; $script:Fail++ }
function Warn { param([string]$m,[string]$d='') Write-Host "[WARN] $m" -ForegroundColor Yellow;if($d){Write-Host "       $d" -ForegroundColor DarkGray} }

Write-Host ""
Write-Host "=== Plugin readiness check ===" -ForegroundColor Cyan
Write-Host "Repo: $Path"
Write-Host ""

# 1. Locate plugin.json - VS Code checks these in order
$candidates = @('.plugin/plugin.json','plugin.json','.github/plugin/plugin.json','.claude-plugin/plugin.json')
$manifestRel = $null
foreach ($c in $candidates) { if (Test-Path (Join-Path $Path $c)) { $manifestRel = $c; break } }

if (-not $manifestRel) {
    Bad "plugin.json not found" "Put it at the repo root."
    exit 1
}
Ok "plugin.json found" $manifestRel

$manifestPath = Join-Path $Path $manifestRel
try { $pj = Get-Content $manifestPath -Raw | ConvertFrom-Json; Ok "plugin.json is valid JSON" }
catch { Bad "plugin.json is not valid JSON" $_.Exception.Message; exit 1 }

if (-not $pj.name) { Bad "plugin.json has no 'name'" }
elseif ($pj.name -cnotmatch '^[a-z0-9-]+$') {
    Bad "plugin name '$($pj.name)' is illegal" "Lowercase, numbers, hyphens only. Illegal names fail SILENTLY."
}
elseif ($pj.name.Length -gt 64) { Bad "plugin name exceeds 64 characters" }
else { Ok "plugin name" $pj.name }

if (-not $pj.version) { Warn "no 'version' field" "You cannot ship updates without one." }
else { Ok "version" $pj.version }

# 2. Declared paths
Write-Host ""
Write-Host "--- Declared component paths ---" -ForegroundColor Cyan
$pathFields = @{
    agents   = if ($pj.agents)   { $pj.agents }   else { 'agents/' }
    skills   = if ($pj.skills)   { $pj.skills }   else { 'skills/' }
    commands = if ($pj.commands) { $pj.commands } else { 'commands/' }
}
$resolved = @{}
foreach ($k in $pathFields.Keys) {
    $rel = $pathFields[$k]; $abs = Join-Path $Path $rel
    if (Test-Path $abs) {
        $n = (Get-ChildItem $abs -File -Recurse -ErrorAction SilentlyContinue).Count
        Ok "$k -> $rel" "$n file(s)"; $resolved[$k] = $abs
    } else { Bad "$k -> $rel" "Declared but does not exist." }
}

# 3. Skills
Write-Host ""
Write-Host "--- Skills ---" -ForegroundColor Cyan
$skillNames = @()
if ($resolved.ContainsKey('skills')) {
    foreach ($d in (Get-ChildItem $resolved['skills'] -Directory -EA SilentlyContinue)) {
        $sk = Join-Path $d.FullName 'SKILL.md'
        if (-not (Test-Path $sk)) { Bad "$($d.Name)" "no SKILL.md - directory ignored"; continue }

        $head = Get-Content $sk -TotalCount 20
        $nm = ($head | Where-Object { $_ -match '^name:' } | Select-Object -First 1) -replace '^name:\s*',''
        $nm = $nm.Trim().Trim('"').Trim("'")

        if (-not $nm) { Bad "$($d.Name)" "SKILL.md has no 'name:'" }
        elseif ($nm -ne $d.Name) { Bad "$($d.Name)" "name '$nm' != directory. SILENT load failure." }
        elseif ($nm -cnotmatch '^[a-z0-9-]+$') { Bad "$($d.Name)" "illegal characters or namespace prefix" }
        else { Ok "$nm"; $skillNames += $nm }

        if (-not ($head | Where-Object { $_ -match '^description:' })) {
            Warn "$($d.Name)" "no description - the agent cannot decide when to load it"
        }
    }
}

# 4. Commands
Write-Host ""
Write-Host "--- Commands ---" -ForegroundColor Cyan
$cmdNames = @()
if ($resolved.ContainsKey('commands')) {
    foreach ($f in (Get-ChildItem $resolved['commands'] -Filter '*.md' -File -EA SilentlyContinue)) {
        $head = Get-Content $f.FullName -TotalCount 20
        $nm = ($head | Where-Object { $_ -match '^name:' } | Select-Object -First 1) -replace '^name:\s*',''
        $nm = $nm.Trim().Trim('"').Trim("'")
        if (-not $nm) { $nm = [IO.Path]::GetFileNameWithoutExtension($f.Name) }
        if ($nm -cnotmatch '^[a-z0-9-]+$') { Bad "$($f.Name)" "name '$nm' has illegal characters" }
        else { Ok "$nm"; $cmdNames += $nm }
    }
}

# 5. Collisions - skills and commands share the / namespace
$all = @($skillNames) + @($cmdNames)
$dupes = $all | Group-Object | Where-Object Count -gt 1
Write-Host ""
if ($dupes) {
    foreach ($d in $dupes) { Bad "name collision: '$($d.Name)'" "Both become /$($pj.name):$($d.Name)." }
} else { Ok "no skill/command name collisions" "$($all.Count) unique names" }

# 6. Agents
Write-Host ""
Write-Host "--- Agents ---" -ForegroundColor Cyan
if ($resolved.ContainsKey('agents')) {
    $visible = 0
    foreach ($f in (Get-ChildItem $resolved['agents'] -Filter '*.md' -File -EA SilentlyContinue)) {
        $txt = Get-Content $f.FullName -Raw
        if ($txt -notmatch '(?s)^---\s*\r?\n.*?\r?\n---') { Bad "$($f.Name)" "missing/malformed frontmatter"; continue }

        $head = Get-Content $f.FullName -TotalCount 30
        $nm = ($head | Where-Object { $_ -match '^name:' } | Select-Object -First 1) -replace '^name:\s*',''
        $nm = $nm.Trim().Trim('"').Trim("'")

        $hidden = $txt -match 'user-invocable:\s*false'
        if (-not $hidden) { $visible++ }
        Ok "$nm" $(if ($hidden) { 'subagent' } else { 'in dropdown' })

        if ($txt -match '(?m)^agents:') {
            $toolsLine = ($head | Where-Object { $_ -match '^tools:' } | Select-Object -First 1)
            if ($toolsLine -notmatch "'agent'") {
                Bad "$nm" "declares 'agents:' but 'agent' missing from tools. Delegation silently does nothing."
            }
        }
    }
    Write-Host ""
    Ok "agents visible in dropdown" "$visible"
}

# 7. Skill -> template/script link integrity
Write-Host ""
Write-Host "--- Skill resource links ---" -ForegroundColor Cyan
$broken = 0
if ($resolved.ContainsKey('skills')) {
    foreach ($sk in (Get-ChildItem $resolved['skills'] -Filter 'SKILL.md' -Recurse -File)) {
        $dir = Split-Path $sk.FullName -Parent
        $txt = Get-Content $sk.FullName -Raw
        foreach ($m in [regex]::Matches($txt, '\]\((\./[^)]+)\)')) {
            $rel = $m.Groups[1].Value
            if (-not (Test-Path (Join-Path $dir $rel))) {
                Bad "$(Split-Path $dir -Leaf)" "broken link: $rel"; $broken++
            }
        }
    }
}
if ($broken -eq 0) { Ok "all skill resource links resolve" }

# 8. marketplace.json version match
Write-Host ""
Write-Host "--- Marketplace ---" -ForegroundColor Cyan
$mp = Join-Path $Path 'marketplace.json'
if (Test-Path $mp) {
    try {
        $mj = Get-Content $mp -Raw | ConvertFrom-Json
        Ok "marketplace.json is valid JSON"
        $entry = $mj.plugins | Where-Object { $_.name -eq $pj.name } | Select-Object -First 1
        if (-not $entry) { Bad "marketplace.json has no entry for '$($pj.name)'" }
        elseif ($entry.version -ne $pj.version) {
            Bad "version mismatch" "plugin.json=$($pj.version) marketplace.json=$($entry.version). Updates will NOT reach your team."
        } else { Ok "versions match" $pj.version }
    } catch { Bad "marketplace.json is not valid JSON" $_.Exception.Message }
} else { Warn "no marketplace.json" "Fine for Install-From-Source only." }

# Summary
Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host ""
if ($script:Fail -eq 0) {
    Write-Host "Ready to push." -ForegroundColor Green
    Write-Host ""
    Write-Host "Commands will appear as:" -ForegroundColor Green
    foreach ($c in $cmdNames) { Write-Host "  /$($pj.name):$c" -ForegroundColor Gray }
    Write-Host ""
    Write-Output "PLUGIN_READY=OK"
    exit 0
}
Write-Host "$($script:Fail) problem(s). Every one fails SILENTLY at install time." -ForegroundColor Red
Write-Host ""
Write-Output "PLUGIN_READY=FAIL"
exit 1

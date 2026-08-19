[CmdletBinding()] param(
    [Parameter(Mandatory = $true)][string]$RdlPath,
    [string]$ReportAlPath
)
$ErrorActionPreference = 'Stop'
$problems = New-Object System.Collections.Generic.List[object]
function AP($c, $d) { $problems.Add([pscustomobject]@{ check = $c; detail = $d }) }

# ---------------------------------------------------------------------------
# BUILD-FIRST RDLC validator for al-report-rdlc-layout.
# The BUILD owns the schema (<DataSet>/<Fields>/<DataField>); this skill only
# fills the body Tablix. So we assert the file WAS build-generated, and that
# every field binding points at a field the build actually declared.
# Cloud-only: pure PowerShell, no container, no BC required.
# ---------------------------------------------------------------------------

if (-not (Test-Path $RdlPath)) {
    Write-Output (@{ rdl_status = 'FAIL'; reason = 'file not found'; RdlPath = $RdlPath } | ConvertTo-Json)
    Write-Host "RDL_STATUS=FAIL - file not found: $RdlPath" -ForegroundColor Red
    exit 1
}
$t = Get-Content $RdlPath -Raw

# 1) Well-formed XML
try { [xml]$rdl = $t } catch { AP 'schema' "not well-formed XML: $($_.Exception.Message)" }

# 2) BUILD-FIRST proof: exactly one <Report> root, exactly one <DataSet>, and a
#    real <Fields> block. If the schema is missing, the file was hand-authored
#    (or blank) -> the classic DataField failure. Reject it.
$reportRoots = [regex]::Matches($t, '<Report[\s>]').Count
if ($reportRoots -eq 0) { AP 'buildfirst' 'no <Report> root - not a real .rdl (generate it from the build first)' }
if ($reportRoots -gt 1) { AP 'buildfirst' "$reportRoots <Report> roots - a second report/layout was pasted in (must be exactly 1)" }

$dataSetCount = [regex]::Matches($t, '<DataSet\s+Name=').Count
if ($dataSetCount -eq 0) {
    AP 'buildfirst' 'no <DataSet> - NOT build-first. Compile (Ctrl+Shift+B) then "AL: Generate report layout" so the build writes the schema, then re-run.'
}
elseif ($dataSetCount -gt 1) {
    AP 'buildfirst' "$dataSetCount <DataSet> blocks - the skill must never add a DataSet. The build owns exactly one."
}

# Collect the build-generated field names from <DataField>...</DataField>
$genFields = @{}
foreach ($m in [regex]::Matches($t, '<DataField>\s*([A-Za-z0-9_]+)\s*</DataField>')) {
    $genFields[$m.Groups[1].Value] = $true
}
# Fallback: some generators use <Field Name="X"> without an explicit <DataField>
foreach ($m in [regex]::Matches($t, '<Field\s+Name="([A-Za-z0-9_]+)"')) {
    if (-not $genFields.ContainsKey($m.Groups[1].Value)) { $genFields[$m.Groups[1].Value] = $true }
}
if ($genFields.Count -eq 0) {
    AP 'buildfirst' 'no <DataField>/<Field> found - the build-generated <Fields> block is missing. Do not author it; generate from the build.'
}

# 3) Detect the OLD hand-authored template signature (single placeholder field).
if ($t -match 'FILL_FieldName') {
    AP 'buildfirst' 'found FILL_FieldName - this is the old author-from-scratch template. Use the build-generated .rdl + ReportTablix fragment instead.'
}

# 4) No unfilled slots left anywhere
foreach ($m in [regex]::Matches($t, 'FILL_[A-Za-z0-9]+')) {
    AP 'schema' "Unfilled slot remains: $($m.Value)"
}

# 5) Binding check (THE blocker-#6 guard): every =Fields!X.Value must exist in
#    the build-generated field set.
$used = @{}
foreach ($m in [regex]::Matches($t, 'Fields!([A-Za-z0-9_]+)\.Value')) { $used[$m.Groups[1].Value] = $true }
foreach ($f in $used.Keys) {
    if ($genFields.Count -gt 0 -and -not $genFields.ContainsKey($f)) {
        AP 'bindings' "Fields!$f.Value has NO build-generated dataset field '$f' - RUNTIME 'DataField' FAIL. Bind only to columns the report declares."
    }
}

# 6) Cross-check against the report's column() list, if the .al was provided.
#    Also flags a hand-added <Field> that the report never declared.
if ($ReportAlPath -and (Test-Path $ReportAlPath)) {
    $al = Get-Content $ReportAlPath -Raw
    $cols = @{}
    foreach ($m in [regex]::Matches($al, '(?im)^\s*column\s*\(\s*([A-Za-z0-9_]+)\s*;')) { $cols[$m.Groups[1].Value] = $true }
    foreach ($f in $used.Keys) {
        if ($cols.Count -gt 0 -and -not $cols.ContainsKey($f)) {
            AP 'bindings' "Fields!$f.Value is not a column() in the report .al - fix the binding or add the column in report-builder (never in the .rdl)."
        }
    }
    foreach ($f in $genFields.Keys) {
        if ($cols.Count -gt 0 -and -not $cols.ContainsKey($f)) {
            AP 'schema' "Field '$f' exists in the .rdl but not as a column() in the report - a field was hand-added to the schema. Regenerate the layout from the build."
        }
    }
    # DataSetName on the Tablix must be the build's dataset name.
    foreach ($m in [regex]::Matches($t, '<DataSetName>\s*([^<]+?)\s*</DataSetName>')) {
        if ($m.Groups[1].Value -ne 'DataSet_Result') {
            AP 'bindings' "Tablix DataSetName='$($m.Groups[1].Value)' - BC's build dataset is 'DataSet_Result'."
        }
    }
}

# 7) Whitelisted expressions only
$wl = @(
    '^=Fields!\w+\.Value$',
    '^=Sum\(Fields!\w+\.Value\)$',
    '^=Today\(\)$',
    '^=Globals!PageNumber$',
    '^="Page " & Globals!PageNumber & " of " & Globals!TotalPages$'
)
foreach ($e in [regex]::Matches($t, '<Value>\s*(=[^<]*)</Value>')) {
    $raw = $e.Groups[1].Value
    $x = ($raw -replace '&amp;', '&').Trim()
    if ($raw -match 'Code\.' -or $raw -match "`n") { AP 'expression' "unsafe (multi-line/Code): $x"; continue }
    $m = $false; foreach ($w in $wl) { if ($x -match $w) { $m = $true; break } }
    if (-not $m) { AP 'expression' "not whitelisted: $x" }
}

$status = if ($problems.Count -eq 0) { 'OK' } else { 'PROBLEMS' }
Write-Output (@{ rdl_status = $status; total = $problems.Count; build_fields = @($genFields.Keys); bound_fields = @($used.Keys); problems = $problems } | ConvertTo-Json -Depth 5)
if ($problems.Count -eq 0) { Write-Host "RDL_STATUS=OK - build-first, $($genFields.Count) build field(s), all bindings valid." -ForegroundColor Green; exit 0 }
Write-Host "RDL_STATUS=PROBLEMS - $($problems.Count) issue(s). Fix before Ctrl+F5." -ForegroundColor Red
exit 1

<#
.SYNOPSIS
    Offline validation for a Business Central RDLC layout (.rdl).

.DESCRIPTION
    Runs BEFORE the developer previews the report in the cloud sandbox. It cannot
    test-RUN the report (no container in a cloud-only setup), but it catches the
    three failure classes checkable offline, so the single manual preview passes
    on the first try nearly every time:
      1. XSD schema        - well-formed and structurally valid RDL.
      2. Field bindings    - every Fields!X.Value matches a column(X; ...) in the AL dataset.
      3. Expression whitelist - no multi-line/unsafe expressions that pass XSD but
                             fail the RDL expression compiler at run time.
    Prints a JSON verdict. Exit 0 = RDL_STATUS=OK.

.PARAMETER RdlPath      Path to the .rdl layout.
.PARAMETER ReportAlPath Path to the *.Report.al (dataset columns). Recommended.
.PARAMETER XsdPath      Optional RDL 2016 XSD. Omitted -> well-formedness + required-element fallback.

.EXAMPLE
    pwsh ./validate-rdl.ps1 -RdlPath ./src/Report/VendorSpend.rdl -ReportAlPath ./src/Report/VendorSpend.Report.al
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string]$RdlPath,
    [Parameter()] [string]$ReportAlPath,
    [Parameter()] [string]$XsdPath
)

$ErrorActionPreference = 'Stop'
$problems = New-Object System.Collections.Generic.List[object]
function Add-Problem { param([string]$Check, [string]$Detail)
    $problems.Add([pscustomobject]@{ check = $Check; detail = $Detail }) }

if (-not (Test-Path $RdlPath)) {
    Write-Output (@{ rdl_status = 'FAIL'; error = "RDL not found: $RdlPath" } | ConvertTo-Json)
    exit 1
}
$rdlText = Get-Content $RdlPath -Raw

# --- CHECK 1: schema / structure ------------------------------------------
$xmlOk = $true
try { [xml]$rdl = $rdlText }
catch { Add-Problem 'schema' "Not well-formed XML: $($_.Exception.Message)"; $xmlOk = $false }

if ($xmlOk) {
    if ($XsdPath -and (Test-Path $XsdPath)) {
        try {
            $settings = New-Object System.Xml.XmlReaderSettings
            $settings.ValidationType = [System.Xml.ValidationType]::Schema
            [void]$settings.Schemas.Add($null, $XsdPath)
            $script:xsdErrors = @()
            $handler = [System.Xml.Schema.ValidationEventHandler]{ param($s, $e) $script:xsdErrors += $e.Message }
            $settings.add_ValidationEventHandler($handler)
            $reader = [System.Xml.XmlReader]::Create($RdlPath, $settings)
            while ($reader.Read()) { }
            $reader.Close()
            foreach ($m in $script:xsdErrors) { Add-Problem 'schema' $m }
        }
        catch { Add-Problem 'schema' "XSD validation error: $($_.Exception.Message)" }
    }
    else {
        if ($null -eq $rdl.Report) { Add-Problem 'schema' "Missing root <Report> element" }
        foreach ($req in 'DataSets', 'ReportSections') {
            if (-not $rdl.SelectSingleNode("//*[local-name()='$req']")) {
                Add-Problem 'schema' "Missing required <$req> section"
            }
        }
        foreach ($m in [regex]::Matches($rdlText, 'FILL_[A-Za-z0-9]+')) {
            Add-Problem 'schema' "Unfilled template slot: $($m.Value)"
        }
        if ($rdlText -match '<!--\s*FILL:') {
            Add-Problem 'schema' "A FILL: instruction block was left in - complete or remove it"
        }
    }
}

# --- collect fields --------------------------------------------------------
$usedFields = @{}
foreach ($m in [regex]::Matches($rdlText, 'Fields!([A-Za-z0-9_]+)\.Value')) { $usedFields[$m.Groups[1].Value] = $true }
$declaredFields = @{}
foreach ($m in [regex]::Matches($rdlText, '<Field\s+Name="([A-Za-z0-9_]+)"')) { $declaredFields[$m.Groups[1].Value] = $true }

# --- CHECK 2: bindings vs the AL dataset -----------------------------------
if ($ReportAlPath) {
    if (-not (Test-Path $ReportAlPath)) {
        Add-Problem 'bindings' "Report AL not found: $ReportAlPath (binding check skipped)"
    }
    else {
        $al = Get-Content $ReportAlPath -Raw
        $datasetCols = @{}
        foreach ($m in [regex]::Matches($al, '(?im)^\s*column\s*\(\s*([A-Za-z0-9_]+)\s*;')) { $datasetCols[$m.Groups[1].Value] = $true }
        if ($datasetCols.Count -eq 0) { Add-Problem 'bindings' "No column(...) found - is this the right .Report.al?" }
        foreach ($f in $usedFields.Keys) {
            if (-not $datasetCols.ContainsKey($f)) { Add-Problem 'bindings' "Fields!$f.Value has NO dataset column '$f' - THIS FAILS AT RUN TIME" }
        }
        foreach ($f in $usedFields.Keys) {
            if (-not $declaredFields.ContainsKey($f)) { Add-Problem 'bindings' "Fields!$f.Value used but not declared in <Fields> - add <Field Name=`"$f`">" }
        }
        foreach ($f in $declaredFields.Keys) {
            if ($f -ne 'FILL_FieldName' -and -not $datasetCols.ContainsKey($f)) { Add-Problem 'bindings' "<Field Name=`"$f`"> declared but no dataset column '$f'" }
        }
    }
}
else { Add-Problem 'bindings' "No -ReportAlPath supplied - binding check skipped (recommend supplying it)" }

# --- CHECK 3: expression whitelist ----------------------------------------
$whitelist = @(
    '^=Fields!\w+\.Value$'
    '^=Sum\(Fields!\w+\.Value\)$'
    '^=CountRows\(\)$'
    '^=Today\(\)$'
    '^=Globals!PageNumber$'
    '^="Page " & Globals!PageNumber & " of " & Globals!TotalPages$'
    '^=Fields!\w+\.Value( & " [^"]*" & Fields!\w+\.Value)+$'
)
foreach ($e in [regex]::Matches($rdlText, '<Value>\s*(=[^<]*)</Value>')) {
    $raw = $e.Groups[1].Value
    $expr = ($raw -replace '&amp;', '&').Trim()
    if ($raw -match "`n" -or $raw -match "`r" -or $raw -match 'Chr\(1[0-3]\)') {
        Add-Problem 'expression' "Multi-line/linebreak expression rejected: $expr"; continue
    }
    if ($raw -match 'Code\.') { Add-Problem 'expression' "Custom-assembly (Code.) expression rejected: $expr"; continue }
    $matched = $false
    foreach ($w in $whitelist) { if ($expr -match $w) { $matched = $true; break } }
    if (-not $matched) { Add-Problem 'expression' "Expression not on the safe whitelist - simplify or verify it compiles: $expr" }
}

# --- verdict ---------------------------------------------------------------
$byCheck = $problems | Group-Object check | ForEach-Object { "$($_.Name):$($_.Count)" }
$summary = @{
    rdl_status   = if ($problems.Count -eq 0) { 'OK' } else { 'PROBLEMS' }
    rdl          = $RdlPath
    fields_used  = @($usedFields.Keys)
    total_issues = $problems.Count
    by_check     = ($byCheck -join ', ')
    problems     = $problems
}
Write-Output ($summary | ConvertTo-Json -Depth 5)

if ($problems.Count -eq 0) {
    Write-Host ""
    Write-Host "RDL_STATUS=OK - offline checks passed. Preview once with Ctrl+F5." -ForegroundColor Green
    exit 0
}
Write-Host ""
Write-Host "RDL_STATUS=PROBLEMS - $($problems.Count) issue(s). Fix and re-run before previewing." -ForegroundColor Red
exit 1

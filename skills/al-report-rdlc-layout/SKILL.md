---
name: al-report-rdlc-layout
description: Generate a Business Central RDLC report layout (.rdl) from a picture or an Excel mock-up, then validate it offline so the one manual preview in the cloud sandbox passes on the first try. Fills field bindings and captions into a validated template - never hand-writes RDL structure. Loads after the dataset exists.
argument-hint: [picture path OR excel path] [report name]
---

# Generate an RDLC Layout - offline-validated

Turn a **picture** (primary) or an **Excel mock-up** into a BC RDLC layout (.rdl).
Do NOT hand-write RDL XML. Fill bindings/captions into a validated template, then
run three offline checks so the developer's single cloud-sandbox preview passes.

## Honest boundary
Cloud-only cannot test-RUN the report. Offline you: (1) emit from a validated
template, (2) XSD-validate, (3) cross-check every Fields!X.Value vs the dataset,
(4) restrict expressions to a whitelist. Then hand back PREVIEW_REQUIRED for one
Ctrl+F5. Never claim the layout is final.

## Step 0 - Preconditions
Report object + dataset exist. Extract every column(<Name>;...) from *.Report.al.
Have a picture or Excel. RDLCLayout points at a .rdl (rename .rdlc→.rdl if needed).

## Step 1 - Read the target into a layout map
Picture: header (title, logo, doc fields), table (columns L→R + captions),
grouping/totals, footer. Excel: header row→captions, types→alignment, SUM rows→totals.
```
HEADER: title=..., logo=left
TABLE (L->R): Vendor No. | Vendor Name | Total Amount(right,sum)
GROUP: by Vendor No.
FOOTER: page-of-total, print date
```

## Step 2 - Map every column to a dataset field
"Vendor No." -> Fields!VendorNo.Value. A picture column with NO dataset field →
NEEDS_INPUT (never invent a binding).

## Step 3 - Fill the validated template
Start from [ReportLayout.rdl.template](./templates/ReportLayout.rdl.template). Fill
ONLY header values, Tablix headers, detail =Fields!X.Value, the group total, footer
page boxes. Do NOT touch Report/namespaces/DataSets/Tablix structure/page setup.

## Step 4 - Whitelisted expressions only
=Fields!X.Value · =Sum(Fields!X.Value) · =CountRows() · =Today() · =Globals!PageNumber ·
="Page " & Globals!PageNumber & " of " & Globals!TotalPages · simple concat.
Never emit multi-line, Code., or line-break expressions (they pass XSD, fail the compiler).

## Step 5 - Validate offline (mandatory)
`pwsh <plugin-root>/skills/al-report-rdlc-layout/scripts/validate-rdl.ps1 -RdlPath ./src/Report/<Name>.rdl -ReportAlPath ./src/Report/<Name>.Report.al`
Checks: XSD schema, field bindings vs dataset, expression whitelist. Fix and re-run
until RDL_STATUS=OK. Do not return before that.

## Step 6 - Hand back
STATUS: PREVIEW_REQUIRED · LAYOUT: <Name>.rdl offline-validated · FINAL STEP: Ctrl+F5 once.
If it errors, paste the BC error back for a fix + re-validate.

## Prevents
| Symptom in BC | Prevented by |
|---|---|
| "field not found" | mapping + validator check 2 |
| malformed RDL | template + check 1 |
| expression fails compiler | whitelist + check 3 |

## Upgrade path
Add a local BC container (validation only) later to enable a headless run-and-capture
step, turning PREVIEW_REQUIRED into VERIFIED. Steps 1-4 unchanged.

---
name: al-report-rdlc-layout
description: Generate a Business Central RDLC report layout (.rdl) from a picture or an Excel mock-up, then validate it offline so the one manual preview in the cloud sandbox passes on the first try. Fills field bindings and captions into a validated template - never hand-writes RDL structure. Loads after the dataset exists.
argument-hint: [picture path OR excel path] [report name]
---

# Generate an RDLC Layout - offline-validated

You turn a **picture** (primary) or an **Excel mock-up** into a Business Central
RDLC layout (`.rdl`). You do NOT hand-write RDL XML from scratch. You fill field
bindings and captions into a **validated template**, then run three offline
checks so the developer's single cloud-sandbox preview passes the first time.

## The honest boundary (read first)

Cloud-only means there is no container to test-RUN the report, so you CANNOT
guarantee zero runtime error alone. What you CAN do offline:

1. Emit from a validated template - structure correct by construction.
2. XSD-validate against the RDL schema - catch structural errors.
3. Cross-check every `Fields!X.Value` against the dataset - catch "field not found".
4. Restrict expressions to a safe whitelist - avoid the ones that fail to compile.

Then hand back `STATUS: PREVIEW_REQUIRED` with a one-step instruction: `Ctrl + F5`
in VS Code to publish + render once in the cloud sandbox. Because 1-4 passed, that
preview succeeds nearly every time. **Never claim the layout is final** - claim it
is offline-validated and ready for one preview.

## Step 0 - Preconditions
- The report object and dataset exist. Extract every `column(<Name>; ...)` from the
  `*.Report.al`. If the column list is not in your prompt, read the file.
- You have a picture (PNG/JPG) or an Excel file.
- `RDLCLayout` points at a `.rdl` (not `.rdlc` - Report Builder and the schema want
  `.rdl`). If it says `.rdlc`, change the property and filename to `.rdl` and note it.

## Step 1 - Read the target structure

### From a picture (the common case)
Extract, in order: header band (title, logo position, doc fields), the table (column
order L->R + each caption), grouping/totals, footer (page number, print date).
Produce an explicit layout map before generating:
```
HEADER: title="Vendor Spend", logo=left, date=right
TABLE (L->R): Vendor No. | Vendor Name | Period | Total Amount(right,sum)
GROUP: by Vendor No., subtotal Total Amount
FOOTER: page-of-total left, print date right
```

### From an Excel mock-up
Header row -> captions in order; column types -> alignment/format; SUM/subtotal rows ->
group totals; merged/bold rows -> bands. Produce the same layout map.

## Step 2 - Map every element to a DATASET field
For each table column, bind to an exact dataset column:
```
"Vendor No."   -> Fields!VendorNo.Value
"Total Amount" -> Fields!TotalAmount.Value   (Sum in the group footer)
```
A picture column with NO matching dataset field -> STOP. Return `NEEDS_INPUT` listing
the unmapped columns and asking whether to add them to the dataset (al-report-builder's
job) or drop them. Never invent a binding.

## Step 3 - Fill the validated template
Start from [ReportLayout.rdl.template](./templates/ReportLayout.rdl.template). It is a
schema-correct RDL skeleton (2016 namespace) with header, Tablix, group, footer already
structured. Fill ONLY: header textbox values; Tablix column headers (captions); Tablix
detail cells (`=Fields!X.Value`); the group total (`=Sum(...)`); footer page-number boxes.
Do NOT touch: the `<Report>` element, namespaces, `<DataSets>`, the Tablix structure, page
setup, or element ordering. Structure is fixed so it cannot be malformed.

## Step 4 - Use ONLY whitelisted expressions
| Need | Expression |
|---|---|
| Field value | `=Fields!VendorNo.Value` |
| Group / grand total | `=Sum(Fields!TotalAmount.Value)` |
| Count | `=CountRows()` |
| Today | `=Today()` |
| Page number | `=Globals!PageNumber` |
| Page of total | `="Page " & Globals!PageNumber & " of " & Globals!TotalPages` |
| Simple concat | `=Fields!No.Value & " - " & Fields!Name.Value` |

**Never** emit multi-line expressions, `Code.` custom-assembly calls, the GetData/SetData
pattern, or anything with a line break. Those pass XSD and then fail the RDL compiler.

## Step 5 - Validate offline (mandatory)
Run [validate-rdl.ps1](./scripts/validate-rdl.ps1):
```powershell
pwsh <plugin-root>/skills/al-report-rdlc-layout/scripts/validate-rdl.ps1 `
    -RdlPath ./src/Report/<Name>.rdl -ReportAlPath ./src/Report/<Name>.Report.al
```
Checks: (1) XSD schema, (2) field bindings vs the dataset, (3) expression whitelist. Fix
and re-run until it prints `RDL_STATUS=OK`. Do not return before that.

## Step 6 - Hand back for the single preview
```
STATUS: PREVIEW_REQUIRED
LAYOUT: <Name>.rdl - offline-validated (XSD + bindings + expressions)
FINAL STEP (developer): Ctrl + F5 in VS Code to publish + render once in the cloud sandbox.
IF IT ERRORS: paste the BC error back and I will fix and re-validate.
```

## Common failures this prevents
| Symptom in BC | Prevented by |
|---|---|
| "value expression refers to a field not found" | Step 2 + validator check 2 |
| Layout fails to load, malformed RDL | Template + validator check 1 |
| Expression compiles nowhere / 'ds' is not defined | Whitelist + validator check 3 |
| Wrong column order or missing header | Layout map reviewed before generation |

## What this skill does NOT do
- It does not test-RUN the report (no container in a cloud-only setup).
- It does not do pixel-perfect polish - fonts/spacing are faster to nudge in Report
  Builder after the preview. This skill gets structure, bindings, and safe expressions right.
- It does not fabricate a dataset field. Unmapped columns -> NEEDS_INPUT.

## Upgrade path (optional, later)
If you add a local BC Docker container JUST for validation (cloud dev workflow unchanged),
a Step 5b can publish + headless-run via bccontainerhelper and capture the real error,
turning PREVIEW_REQUIRED into VERIFIED. Steps 1-4 do not change.

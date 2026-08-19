---
name: al-report-rdlc-layout
description: Generate a BC RDLC layout (.rdl) for an EXISTING report from a picture or Excel mock-up, offline-validated. Only runs when the developer provides a picture or a description. Reads the layout name the report object already declares and fills THAT exact file.
argument-hint: [picture path OR excel path] [report name]
---

# Generate an RDLC Layout — for the report's ALREADY-DEFINED layout

You fill the layout the report object ALREADY declares. You do NOT invent a new
layout name — you read the exact name/path from the report and fill that file, so
the report and its layout are always linked.

## Precondition — only run when there is a source
Run ONLY if the developer provided a PICTURE (screenshot) or a text DESCRIPTION of
the layout. If neither was provided, do NOT run — the report keeps its defined-but-
empty layout reference for manual design. (The report-builder enforces this gate.)

## Step 0 — Read the report's declared layout (link, don't invent)
1. Open the report object (`*.Report.al`). Find its declared layout:
   - `rendering { layout("<Name>") { Type = RDLC; LayoutFile = './src/Report/<File>.rdl'; } }`
   - or `RDLCLayout = './src/Report/<File>.rdl';`
2. Extract the EXACT layout name and the EXACT `.rdl` file path.
3. **Check if that .rdl file already exists in the source:**
   - **It EXISTS** -> the report already has a layout. Do NOT create a second file.
     If the developer wants changes, OVERWRITE that same file (one report = one layout file).
   - **It does NOT exist** -> generate a NEW .rdl at EXACTLY that path/name, so it
     matches what the report declares.
4. If the report declares NO layout reference at all, STOP and return NEEDS_INPUT:
   "The report has no layout reference. Have report-builder define the layout
   name/path first, then re-run." (Never guess a name that the report doesn't point at.)

## Step 1 — Read the target into a layout map
From the picture: header (title, logo, doc fields), table columns L->R + captions,
grouping/totals, footer. From Excel/description: same map.

## Step 2 — Map every column to a DATASET field
Read the report's `column(<Name>; ...)` list. Bind each layout column to an exact
dataset column. A layout column with NO dataset field -> NEEDS_INPUT (never invent).

## Step 3 — Fill the validated template AT THE REPORT'S PATH
Start from [ReportLayout.rdl.template](./templates/ReportLayout.rdl.template). Fill the
FILL_ slots (title, headers, =Fields!X.Value bindings, footer). Write the result to
the EXACT `.rdl` path the report declared in Step 0 — not a new name.

## Step 4 — Whitelisted expressions only
=Fields!X.Value · =Sum(Fields!X.Value) · =Today() · =Globals!PageNumber ·
="Page " & Globals!PageNumber & " of " & Globals!TotalPages. Never multi-line/Code.

## Step 5 — Validate offline (mandatory)
`pwsh <plugin-root>/skills/al-report-rdlc-layout/scripts/validate-rdl.ps1 -RdlPath <the report's .rdl path> -ReportAlPath <the report's .al>`
Fix until RDL_STATUS=OK. Do not return before that.

## Step 6 — Hand back
STATUS: PREVIEW_REQUIRED · LAYOUT: <exact name>.rdl (matches the report) — offline-validated
FINAL STEP (developer): Ctrl+F5 to publish + render once. If it errors, paste it back.

## Common failures this prevents
| Symptom | Prevented by |
|---|---|
| Layout not linked to the report | Step 0 reads the report's declared name/path |
| Two layout files for one report | Step 0 overwrites the existing file, never a 2nd |
| "field not found" at run time | Step 2 binding check + validator |
| Layout generated with no source | Precondition gate (only runs with a picture/description) |

---
name: al-report-rdlc-layout
description: Fill the TABLIX of a Business Central RDLC layout (.rdl) that the AL BUILD generated for an EXISTING report, from a picture or Excel mock-up, offline-validated. BUILD-FIRST — the build owns the schema (DataSet/Fields/DataField); this skill only fills the visible table cells. Never authors a .rdl from scratch. Runs only when the developer provides a picture or a description. Reads the layout name the report object already declares and fills THAT exact file. Prefer Word layouts for simple/document reports.
argument-hint: [picture path OR excel path] [report name]
---

# Fill an RDLC Layout — BUILD-FIRST, Tablix only

You **fill the Tablix** of the .rdl the report object ALREADY declares. You do **NOT**
invent a new layout name and you do **NOT** author a .rdl from scratch. The AL build
generates the schema-correct file (the `<DataSet>`, `<Fields>`, `<DataField>` block);
you only fill the visible table cells that bind to those fields. This is the fix for
"No declaration found for element DataField": the schema always comes from the build,
never from this skill.

> ⭐ **THE ONE RULE:** never write `<Report>`, namespaces/`xmlns`, `<DataSources>`,
> `<DataSets>`, `<DataSet>`, `<Fields>`, `<Field>`, or `<DataField>`. Those belong to
> the build. You only add/fill a `<Tablix>` (and title/footer textboxes) inside the
> report **body**, binding to `=Fields!<Column>.Value` where `<Column>` already exists
> in the build-generated `<Fields>`.

### Prefer Word first
For simple or document-style reports, recommend a **Word layout** (DefaultLayout = Word)
instead of RDLC — no XML, no DataField risk. Use RDLC only when a true tabular grid /
matrix is required (statistical, list). If the report is document-style, return
`OUT_OF_SCOPE: use Word layout` and let report-builder set `DefaultLayout = Word`.

### Precondition — only run when there is a source
Run ONLY if the developer provided a PICTURE (screenshot) or a text DESCRIPTION of the
layout. If neither was provided, do NOT run — the report keeps its defined-but-empty
layout reference for manual design. (report-builder enforces this gate.)

---

## Step 0 — Read the report's declared layout (link, don't invent)
Open the report object (`*.Report.al`). Find its declared layout:
- `rendering { layout("<Name>") { Type = RDLC; LayoutFile = './src/Report/<File>.rdl'; } }`
- or legacy `RDLCLayout = './src/Report/<File>.rdl';`

Extract the EXACT layout name and EXACT `.rdl` path. If the report declares **no** layout
reference, STOP → `NEEDS_INPUT`: "The report has no layout reference. Have report-builder
define the layout name/path first, then re-run." Never guess a name the report doesn't point at.

## Step 1 — BUILD-FIRST: make the schema-correct .rdl exist (never hand-author it)
Check whether the declared `.rdl` file exists on disk **and already contains a build-generated
`<DataSet>` with a `<Fields>` block**.

- **It is missing, empty, or has no `<Fields>` block** → do **NOT** create it yourself.
  Tell the developer to let the build generate the schema, cloud-only (no container):
  1. Ensure the report object compiles: **Ctrl+Shift+B** (download symbols first if needed).
  2. Generate the schema-correct RDLC scaffold at the declared path — Command Palette →
     **"AL: Open the report layout(s)"** / **"AL: Generate report layout"** for that report
     (VS Code writes a `.rdl` whose `<DataSet>/<Fields>/<DataField>` mirror the report's
     `column()` list exactly).
  3. Re-run this skill. Now the schema is guaranteed correct and owned by the build.

  Return `NEEDS_BUILD` with those three steps and stop. Do not fabricate the file.

- **It exists WITH a build-generated `<Fields>` block** → proceed. You will fill/overwrite
  only the **body Tablix** of THIS file (one report = one layout file). Leave every
  `<DataSet>/<Fields>/<DataField>` byte untouched.

## Step 2 — Map every picture column to an EXISTING build-generated field
Read the `<DataField>` names from the file's build-generated `<Fields>` block (these mirror
the report's `column(<Name>; ...)` list). Bind each layout column to one of THESE exact
names. A layout column with no matching build field → `NEEDS_INPUT` (never add a `<Field>`
to make it fit — that is exactly what caused the DataField error).

## Step 3 — Fill ONLY the body Tablix
Start from [ReportTablix.rdl.template](./templates/ReportTablix.rdl.template). It is a
`<Tablix>` **fragment** (no `<Report>`, no namespaces, no `<Fields>`). Paste it inside the
build-generated report's `<Body><ReportItems>` and replace the `FILL_` slots:
- `FILL_Header1..n` → the visible column captions from the picture.
- `=Fields!FILL_FieldN.Value` → bind to the exact build-generated field names from Step 2.
- Title/footer textboxes: fill the title text; keep the whitelisted page/date expressions.
Delete any `FILL_` columns you don't use. Do not touch anything outside the body Tablix
and title/footer textboxes.

## Step 4 — Whitelisted expressions only
`=Fields!X.Value` · `=Sum(Fields!X.Value)` · `=Today()` · `=Globals!PageNumber` ·
`="Page " & Globals!PageNumber & " of " & Globals!TotalPages`.
Never multi-line, never `Code.` custom code.

## Step 5 — Validate offline (mandatory, build-first aware)
```
pwsh <plugin-root>/skills/al-report-rdlc-layout/scripts/validate-rdl.ps1 -RdlPath <report's .rdl> -ReportAlPath <report's .al>
```
The validator now FAILS if the file is not build-generated (no `<Fields>`), if any
`=Fields!X.Value` binds to a field the build did not generate, if a second `<DataSet>` or a
`<Report>` root was introduced, if a forbidden hand-authored `<Field>/<DataField>` was added,
or if any `FILL_` slot / non-whitelisted expression remains. Fix until `RDL_STATUS=OK`.

## Step 6 — Hand back
```
STATUS: PREVIEW_REQUIRED
LAYOUT: <file>.rdl (Tablix filled; schema untouched, build-owned) — offline-validated
FINAL STEP (developer): Ctrl+F5 to publish + render once. If it errors, paste it back.
```

---

## What this prevents

| Symptom | Prevented by |
|---|---|
| "No declaration found for element DataField" | Schema is build-generated; Step 2 binds only to existing fields; validator rejects unknown bindings |
| Layout authored from scratch / wrong schema | Step 1 build-first gate + validator rejects a file with no build `<Fields>` |
| Layout not linked to the report | Step 0 reads the report's declared name/path |
| Two layout files for one report | Step 1 overwrites the existing file, never a 2nd |
| Layout generated with no source | Precondition gate (only runs with a picture/description) |
| Needless RDLC risk on simple reports | "Prefer Word first" → OUT_OF_SCOPE to Word layout |

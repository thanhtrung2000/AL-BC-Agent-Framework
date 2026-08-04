---
name: al-report-extension
description: Extend base application report objects in Business Central — add dataset columns, add new layouts, or add request page fields to reports this extension does not own, such as Sales - Invoice. Use instead of duplicating a base report.
argument-hint: [base report name] [what to add]
---

# Report Extension

For adding to a **base or third-party report**.

Start from [ReportExt.al.template](./templates/ReportExt.al.template).

## Never duplicate a base report

Copying `Sales - Invoice` into your own object works on day one, then diverges
permanently from every Microsoft update. Extend it instead.

If the change genuinely cannot be expressed as an extension — the dataset shape
itself must change — say so explicitly in NOTES and return the decision to the
developer. Do not silently duplicate.

## What you can and cannot do

| Action | Supported |
|---|---|
| Add a column to an existing DataItem | ✅ `add(<DataItem>)` |
| Add a new layout | ✅ `rendering` |
| Add request page fields | ✅ `addlast` into the request page |
| Change an existing column's source | ❌ |
| Remove a base column | ❌ |
| Change the DataItem tree | ❌ — needs a new report |

## Anchoring stability

`add(<DataItemName>)` targets a DataItem by its **name in the base report**.
Microsoft renames these occasionally.

Prefer top-level DataItems (`Header`, `Line`) over deeply nested loop items,
which are more volatile. **Name the DataItem you anchored to in your output**
so it can be re-checked after each BC upgrade.

## Layouts

Adding a layout does **not** replace the base layout — it appears alongside it.
Users pick one, or an administrator sets the default via
`Report Layout Selection`.

Making yours the company default is a setup step, not an AL property. Say so in
NOTES rather than trying to force it.

## Affix

Every added column, layout, and request page field carries the affix.
AppSourceCop enforces it and it prevents collisions with other ISVs extending
the same base report.

## Common failures

| Symptom | Cause |
|---|---|
| Compile break after a BC update | Anchored to a renamed or removed DataItem |
| Added layout never appears | User has a different default selected |
| AppSourceCop affix error | Added column missing the prefix |
| Wanted to change the dataset shape | Not possible in an extension — needs a new report |

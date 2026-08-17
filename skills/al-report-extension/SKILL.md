---
name: al-report-extension
description: Extend base report objects - add columns, layouts, request page fields. Use instead of duplicating.
---

# Report Extension
Start from [ReportExt.al.template](./templates/ReportExt.al.template).
Never duplicate a base report. Add columns/layouts/request fields; cannot change a column source, remove a base column, or alter the tree. Anchor to top-level DataItems; name it. Affix everything.
| Symptom | Cause |
|---|---|
| Compile break after update | Anchored to a renamed DataItem |

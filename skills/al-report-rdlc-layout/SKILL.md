---
name: al-report-rdlc-layout
description: Generate a BC RDLC layout (.rdl) from a picture or Excel mock-up, offline-validated so the one cloud preview passes first try.
---

# Generate an RDLC Layout - offline-validated
Turn a picture (primary) or Excel into a .rdl. Fill the validated [ReportLayout.rdl.template](./templates/ReportLayout.rdl.template) — never hand-write RDL. Steps: read into a layout map → bind each column to a dataset field (unmapped → NEEDS_INPUT) → fill FILL_ slots → whitelisted expressions only (=Fields!X.Value, =Sum(...), =Today(), page-of-total) → run [validate-rdl.ps1](./scripts/validate-rdl.ps1) until RDL_STATUS=OK → return PREVIEW_REQUIRED with the Ctrl+F5 step. Cloud-only: you cannot test-run; the offline checks (XSD + bindings + expression whitelist) make the single preview pass.

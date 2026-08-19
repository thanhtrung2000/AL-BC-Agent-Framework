---
name: al-report-rdlc-layout
description: Generate a BC RDLC layout (.rdl) from a picture or Excel, offline-validated.
---

# Generate an RDLC Layout
Fill the validated [ReportLayout.rdl.template](./templates/ReportLayout.rdl.template) — never hand-write RDL. Read into a layout map → bind each column to a dataset field (unmapped → NEEDS_INPUT) → whitelisted expressions only → run [validate-rdl.ps1](./scripts/validate-rdl.ps1) until RDL_STATUS=OK → return PREVIEW_REQUIRED with the Ctrl+F5 step.

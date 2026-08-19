---
name: al-report-layout
description: Generate an RDLC layout from a picture or Excel, offline-validated.
agent: al-implementer
---
Generate an RDLC layout for an existing report.
**Layout source:** ${input:source:path to a picture or Excel}
**Report:** ${input:report:the report object}
Route to al-report-builder (al-report-rdlc-layout). Fills the validated template, runs validate-rdl.ps1, returns PREVIEW_REQUIRED. Then Ctrl+F5.

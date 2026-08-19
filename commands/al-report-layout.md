---
name: al-report-layout
description: Generate an RDLC layout from a picture or Excel, offline-validated for a first-try preview.
agent: al-implementer
---
Generate an RDLC layout for an existing report.
**Layout source:** ${input:source:path to a picture or Excel mock-up}
**Report:** ${input:report:the report object whose dataset the layout binds to}
Route to al-report-builder (al-report-rdlc-layout). Reads the picture into a layout map, binds columns, fills the validated template, runs validate-rdl.ps1, returns PREVIEW_REQUIRED. Then Ctrl+F5 once.

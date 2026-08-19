---
name: al-report-layout
description: Generate an RDLC layout from a picture or Excel for a report's already-defined layout.
agent: al-implementer
---
Generate the RDLC layout for an existing report.
**Layout source:** ${input:source:path to a picture or Excel}
**Report:** ${input:report:the report object}
Route to al-report-builder (al-report-rdlc-layout). Reads the report's declared layout name/path, fills that exact file, runs validate-rdl.ps1, returns PREVIEW_REQUIRED. Then Ctrl+F5.

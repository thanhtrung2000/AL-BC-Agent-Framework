---
name: al-report-layout
description: Generate an RDLC layout (.rdl) from a picture or Excel mock-up, offline-validated for a first-try preview.
argument-hint: [picture or excel path] [report name]
agent: al-implementer
---
Generate an RDLC layout for an existing report.
**Layout source:** ${input:source:path to a picture (PNG/JPG) or an Excel mock-up}
**Report:** ${input:report:the report object whose dataset the layout binds to}
Route to al-report-builder (loads al-report-rdlc-layout). It reads the picture/Excel into a layout map, binds columns to dataset fields, fills the validated template, runs validate-rdl.ps1, returns PREVIEW_REQUIRED. Then I run Ctrl+F5 once.

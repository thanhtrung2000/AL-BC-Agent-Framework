---
name: 'al-reports'
applyTo: '**/*.Report.al,**/*.ReportExt.al'
---

# AL Report Conventions (all types)
- Design the DataItem tree first. Filter in AL, never the layout. SetLoadFields. SetCurrentKey matches the filter.
- ApplicationArea + Caption + ToolTip on request-page controls. Totals in the dataset. DataAccessIntent=ReadOnly where no write.
- Documents set CurrReport.Language per record. Periods from Accounting Period. Object skills never fabricate .rdlc/.docx.

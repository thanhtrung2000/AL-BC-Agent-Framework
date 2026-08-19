---
name: 'al-reports'
applyTo: '**/*.Report.al,**/*.ReportExt.al'
---
# AL Report Conventions
- Filter in AL, never the layout. SetLoadFields. SetCurrentKey matches the filter. Totals in the dataset. Documents set CurrReport.Language per record. Periods from Accounting Period.
- DEFINE the layout reference with a deterministic name (<AFFIX><ReportName>Layout -> ./src/Report/<AFFIX><ReportName>.rdl); generate the dataset only; ask for a picture/description before designing the layout. Never fabricate .rdlc/.docx content.

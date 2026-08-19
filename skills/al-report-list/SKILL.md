---
name: al-report-list
description: Build list/register/ledger reports.
---

# List Report
Start from [ListReport.al.template](./templates/ListReport.al.template). RequestFilterFields. SetCurrentKey matches the filter. Totals in the dataset.

## Always DEFINE the layout reference (deterministic name), then ASK for a picture
When you build this report OBJECT, declare its layout reference up front with a
deterministic name derived from the report name: layout `<AFFIX><ReportName>Layout`,
file `./src/Report/<AFFIX><ReportName>.rdl`. Generate the dataset + request page; do NOT
generate the .rdl file. Then end NOTES with:
"Layout is DEFINED as <AFFIX><ReportName>Layout (./src/Report/<AFFIX><ReportName>.rdl). To
 generate it now, provide a PICTURE or DESCRIPTION. If you don't, I'll leave it empty for you
 to design in Report Builder — the reference is in place."
The layout FILE is filled by al-report-rdlc-layout ONLY if a picture/description is provided;
it reads this exact declared name/path and fills that file (never a new name).

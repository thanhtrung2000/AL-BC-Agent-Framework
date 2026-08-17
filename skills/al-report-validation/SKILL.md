---
name: al-report-validation
description: Build validation / pre-posting check reports that list problems without fixing them.
---

# Validation Report
Start from [ValidationReport.al.template](./templates/ValidationReport.al.template).
DataAccessIntent=ReadOnly - **never modifies data**. Temp error buffer with RecordId for drill-through, grouped by severity. Share the scan as a codeunit procedure.
| Symptom | Cause |
|---|---|
| Report changes data | Built as validation but writes |

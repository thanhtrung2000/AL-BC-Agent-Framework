---
name: al-report-validation
description: Build validation / pre-posting check reports that list problems without fixing them.
---

# Validation Report
Start from [ValidationReport.al.template](./templates/ValidationReport.al.template). DataAccessIntent=ReadOnly - **never modifies data**. Temp error buffer with RecordId, grouped by severity.

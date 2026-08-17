---
name: al-report-statistical
description: Build statistical/analysis reports - totals by entity and period, KPIs.
---

# Statistical Report
Start from [StatisticalReport.al.template](./templates/StatisticalReport.al.template).
Aggregate **once** into a temp buffer; never nest DataItems re-scanning per group. Periods from Accounting Period, not calendar. Restate expected values.
| Symptom | Cause |
|---|---|
| Wrong Q1 for some companies | Calendar quarters |

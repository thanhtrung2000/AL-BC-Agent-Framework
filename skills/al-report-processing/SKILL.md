---
name: al-report-processing
description: Build processing-only batch reports that modify data - mass updates, recalculations.
---

# Processing-Only Report
Start from [ProcessingReport.al.template](./templates/ProcessingReport.al.template).
ProcessingOnly=true. The only report type that writes. Confirm with count; preview mode (UpdateRecords defaults false); progress dialog; end summary. ModifyAll where possible. Never DeleteAll customer data.
| Symptom | Cause |
|---|---|
| Cannot tell if it worked | No summary message |

---
name: al-stat-report
description: Generate a statistical report grouped by an entity and a period.
agent: al-implementer
---
Create a statistical report.
**Source:** ${input:source:e.g. Posted Purchase Invoices}
**Group by:** ${input:groupBy:e.g. vendor}
Route to al-report-builder. Aggregate once into a temp buffer; periods from Accounting Period; build to zero errors.

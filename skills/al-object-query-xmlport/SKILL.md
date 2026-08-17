---
name: al-object-query-xmlport
description: Create new AL queries and XMLports - read-only joins with aggregation, and CSV/XML import/export.
---

# Create a Query or XMLport
Start from [QueryXmlPort.al.template](./templates/QueryXmlPort.al.template).
- Query: QueryType=Normal (API is integration). DataAccessIntent=ReadOnly. **Every non-aggregated column joins the implicit GROUP BY.** SqlJoinType deliberately.
- XMLport: set FieldSeparator explicitly for CSV; validate before insert; culture-invariant parsing.
| Symptom | Cause |
|---|---|
| Numbers silently wrong | Extra column changed GROUP BY |

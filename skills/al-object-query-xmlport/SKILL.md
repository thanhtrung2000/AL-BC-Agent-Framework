---
name: al-object-query-xmlport
description: Create new AL queries and XMLports - read-only joins with aggregation, CSV/XML import/export.
---

# Create a Query or XMLport
Start from [QueryXmlPort.al.template](./templates/QueryXmlPort.al.template).
- Query: QueryType=Normal; DataAccessIntent=ReadOnly. **Every non-aggregated column joins the implicit GROUP BY.** XMLport: FieldSeparator explicit; validate before insert; culture-invariant parsing.

Full AL grammar (loads on demand): [query-xmlport-syntax.md](./reference/query-xmlport-syntax.md)

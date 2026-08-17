---
name: al-integration-api-query
description: Build inbound API queries for read-only joined/aggregated data over OData.
---

# Inbound API Query
Start from [ApiQuery.al.template](./templates/ApiQuery.al.template).
QueryType=API, DataAccessIntent=ReadOnly. The URL is a permanent contract. **Every non-aggregated column forms the implicit GROUP BY.** Not writable - a writable need is a separate API page.
| Symptom | Cause |
|---|---|
| Numbers silently wrong | Extra column changed GROUP BY |

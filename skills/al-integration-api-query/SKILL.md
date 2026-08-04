---
name: al-integration-api-query
description: Build inbound API queries in Business Central for read-only joined datasets exposed over OData — analytics feeds, Power BI datasets, reporting extracts. Use when an external consumer needs joined or aggregated data rather than single-table CRUD.
argument-hint: [dataset purpose]
---

# Inbound API Query

For read-only, joined, or aggregated data exposed to an external consumer.

Start from [ApiQuery.al.template](./templates/ApiQuery.al.template).

## API page or API query?

| Need | Use |
|---|---|
| External system creates/updates records | **API page** |
| External system reads one table | API page (simpler for consumers) |
| External system reads **joined** data | **API query** |
| Aggregated totals for analytics | **API query** |

A query pushes the join and aggregation to SQL. Doing the same work through
nested API page calls means one HTTP round trip per parent row.

## Required properties

```al
QueryType = API;
APIPublisher = 'contoso';
APIGroup = 'spend';
APIVersion = 'v1.0';
EntityName = 'vendorSpend';
EntitySetName = 'vendorSpends';
DataAccessIntent = ReadOnly;
```

Same permanence rule as API pages: **the URL is a contract**.

## Query structure

- Order `dataitem` blocks outer to inner; each inner one needs a `DataItemLink`.
- `SqlJoinType` deliberately: `InnerJoin` drops unmatched rows,
  `LeftOuterJoin` keeps them.
- Aggregating columns need `Method = Sum` (or `Count`, `Average`, `Min`, `Max`).

⚠️ **Columns that are not aggregated form the implicit GROUP BY.** Adding one
extra non-aggregated column silently changes the grouping and therefore the
numbers. Nothing warns you — verify against known values.

## Read-only means read-only

Queries cannot be written to. If the consumer needs to push data back, that is a
separate API **page**. Say so rather than compromising the query.

## Performance

- Apply `DataItemTableFilter` for fixed filters so SQL does the work.
- Ensure a key exists supporting the join and filter, or SQL scans.
- `DataAccessIntent = ReadOnly` routes to the read replica.

## Common failures

| Symptom | Cause |
|---|---|
| Numbers silently wrong | An extra column changed the implicit GROUP BY |
| Fewer rows than expected | `InnerJoin` where `LeftOuterJoin` was needed |
| Consumer wants to write | Query used where an API page was needed |
| Slow under load | No supporting key, or filtering done consumer-side |

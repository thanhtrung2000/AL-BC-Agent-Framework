---
name: al-object-query-xmlport
description: Create new AL queries and XMLports owned by this extension in Business Central — read-only joined datasets with aggregation for queries, and structured file import or export for XMLports. Use for efficient multi-table reads or for CSV/XML data exchange.
argument-hint: [query or xmlport] [purpose]
---

# Create a Query or XMLport

Both are **structured data access** objects, which is why they share a skill.

Start from [QueryXmlPort.al.template](./templates/QueryXmlPort.al.template).

## Queries

### When to use one

- Joining two or more tables efficiently in a single SQL statement
- Aggregating with `Sum`, `Count`, `Average`, `Min`, `Max` at the database level
- Feeding a statistical report's buffer without nested `FindSet` loops

A query pushes work to SQL. A record loop pulls rows into AL and processes them
one at a time. For aggregation over large tables the difference is minutes
versus seconds.

### Rules

- `QueryType = Normal`. `QueryType = API` belongs to `al-integration-builder`.
- Set `DataAccessIntent = ReadOnly` — queries never write.
- Order `dataitem` blocks outer to inner; each inner one needs a
  `DataItemLink`.
- Use `SqlJoinType` deliberately: `InnerJoin` drops unmatched rows,
  `LeftOuterJoin` keeps them.
- Apply `DataItemTableFilter` for fixed filters; use `SetFilter` on the query
  variable for runtime ones.
- Aggregating columns need `Method = Sum` and a `MethodType`.
- Columns not aggregated become the implicit GROUP BY — every extra column
  changes the grouping.

```al
query 50000 "<AFFIX> Vendor Spend"
{
    QueryType = Normal;
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(PurchInvHeader; "Purch. Inv. Header")
        {
            column(VendorNo; "Buy-from Vendor No.") { }
            column(TotalAmount; "Amount Including VAT")
            {
                Method = Sum;
            }
        }
    }
}
```

⚠️ Adding a non-aggregated column silently changes the grouping and therefore
the numbers. Nothing warns you.

## XMLports

### When to use one

- Importing CSV or fixed-width files from a bank, payroll, or partner system
- Exporting structured data on a schedule
- Any file format that maps to a record hierarchy

For a one-off JSON payload, use `JsonObject` in a codeunit instead — XMLports
are for repeating record structures.

### Rules

- `Format = VariableText` for CSV, `Format = Xml` for XML, `Format = FixedText`
  for fixed-width.
- Set `FieldDelimiter` and `FieldSeparator` explicitly for CSV. Defaults differ
  from what most partners send.
- `Direction = Import`, `Export`, or `Both` — set it deliberately.
- Use `textelement` / `fieldelement` for XML, `textattribute` for attributes.
- Validate in `OnAfterAssignField` or `OnBeforeInsertRecord`. Never trust a file.
- **Culture matters.** Decimal separators and date formats in a partner file do
  not follow the user's regional settings. Parse invariantly.
- Add a `RequestPage` for user-selected filters on export.

## Common failures

| Symptom | Cause |
|---|---|
| Query numbers silently wrong | An extra column changed the implicit GROUP BY |
| Query returns fewer rows than expected | `InnerJoin` where `LeftOuterJoin` was needed |
| Import breaks on a partner file | `FieldSeparator` left at the default |
| Amounts wrong after import | Culture-dependent decimal parsing |
| Import corrupts data | No validation before insert |

---
name: al-stat-report
description: Generate a statistical report grouped by an entity and a period, using the temp-buffer aggregation pattern.
argument-hint: [source table] [group by]
agent: al-implementer
---

Create a statistical report for Business Central.

**Source:** ${input:source:e.g. Posted Purchase Invoices}
**Group by:** ${input:groupBy:e.g. vendor}
**Period:** ${input:period:quarter | year | both (user-selectable)}
**Expected values (optional):** ${input:expected:Known figures I can verify against, or "none"}

Route to `al-report-builder`. It will classify this as a **statistical** report
and load the matching skill. Require it to:

- Aggregate **once** into a temporary buffer table, then feed the layout a flat
  pre-summed dataset. Do not nest DataItems that re-scan the source per group.
- Filter in AL via `OnPreDataItem`, never in the layout.
- Resolve period boundaries from `Accounting Period`, not calendar arithmetic,
  and state which convention it used.
- Parameterise the request page: date range, grouping dimension, entity filter.
- Set `DataAccessIntent = ReadOnly`.
- Restate the expected values in its output so I can verify the result.

If the buffer table does not exist yet, route that packet to
`al-object-builder` first and pass its exact field names forward.

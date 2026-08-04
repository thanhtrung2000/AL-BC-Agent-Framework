---
name: al-report-list
description: Build list, register, and ledger reports in Business Central — flat listings of entries or records with user filters and sorting, such as item lists, G/L registers, customer ledger listings, and trial balances. Use when the output shows rows of records rather than aggregated totals.
argument-hint: [source table] [what to list]
---

# List / Register Report

For flat listings: item lists, G/L registers, ledger listings, trial balances.

**Not for aggregation.** Totals grouped by entity or period →
`al-report-statistical`.

Start from [ListReport.al.template](./templates/ListReport.al.template).

## Dataset shape

Usually one DataItem. Two only for a genuine parent/child listing.

## Required elements

- **`RequestFilterFields`** — this is what gives users the standard filter pane.
  Choose the two or three fields people actually filter on.
- **`SetCurrentKey`** in `OnPreDataItem` matching the intended sort, using a key
  that exists on the table.
- Column headers repeated across pages.
- A total row where data is numeric, computed in the **dataset**.

## Sorting and filtering

```al
trigger OnPreDataItem()
begin
    SetCurrentKey("G/L Account No.", "Posting Date");
    SetLoadFields("Entry No.", "Posting Date", "G/L Account No.", Amount);
end;
```

Never sort in the layout. Layout sorting re-reads the dataset in memory and
breaks page-level totals.

## Registers specifically

A register lists entries by entry-number range, not by date:

- Filter `"Entry No."` between the register's `From Entry No.` and
  `To Entry No.`
- Show source document and posting date per row

## Layout

- RDLC, or Excel when users will pivot the output.
- `MaximumDatasetSize` where an unfiltered run could return millions of rows.

## Common failures

| Symptom | Cause |
|---|---|
| No filter pane for the user | `RequestFilterFields` missing |
| Report scans instead of seeks | `SetCurrentKey` does not match the filter |
| Runs for minutes on real data | No `SetLoadFields` or `MaximumDatasetSize` |
| Page totals wrong | Totalling done in layout |

---
name: al-report-statistical
description: Build statistical and analysis reports in Business Central — totals grouped by entity and period, KPIs, spend analysis, sales summaries. Use when the output is aggregated figures rather than individual records, such as posted purchase invoices by vendor and quarter.
argument-hint: [source] [group by]
---

# Statistical / Analysis Report

For aggregated output: vendor spend by quarter, sales by category, GL movement
by period.

**Not for listings.** Individual records → `al-report-list`.

Start from [StatisticalReport.al.template](./templates/StatisticalReport.al.template).

## The core pattern: aggregate once into a temp buffer

Never nest DataItems that re-scan the source per group.

```
OnPreReport -> BuildBuffer()  -> one FindSet over the source
                              -> accumulate into a temp buffer
dataset     -> dataitem over the temp buffer only
```

| Scenario | Approach |
|---|---|
| Grouped totals, moderate volume | DataItem + `SumIndexFields` on a matching key |
| Entity x period breakdown | **Temp buffer**, filled once |
| Cross-table aggregation | `Query` object, then a temp buffer |

## Period logic — the silent defect ⭐

Quarter and fiscal-year boundaries come from `Accounting Period`, **not**
calendar arithmetic, unless the plan explicitly says calendar.

```al
AccountingPeriod.SetRange("New Fiscal Year", true);
AccountingPeriod.SetFilter("Starting Date", '<=%1', PostingDate);
if AccountingPeriod.FindLast() then
    PeriodStart := AccountingPeriod."Starting Date";
```

A company with a July fiscal year start gets wrong "Q1" labels from
`CalcDate('<-CQ>')`. Nothing catches this unless a test asserts actual values.

**State which convention you used in your output.**

## Request page

Parameterise everything — date range, grouping dimension, entity filter,
include/exclude toggles. `SaveValues = true`; these get re-run constantly.

## Hand expected values forward

If the plan states expected figures, restate them. A report that runs without
error but produces wrong numbers is a failure, not a pass.

## Common failures

| Symptom | Cause |
|---|---|
| Times out on real data | Nested DataItems re-scanning per group |
| "Q1" wrong for some companies | Calendar quarters instead of accounting periods |
| Totals wrong at group boundaries | Aggregation in layout instead of dataset |
| Numbers plausible but wrong | No expected-value verification |

---
name: al-report-processing
description: Build processing-only batch reports in Business Central that modify data without printing — mass updates, recalculations, data cleanup, bulk field changes driven by a request page. Use when the report changes records rather than producing a printed layout.
argument-hint: [what to update]
---

# Processing-Only Report

For batch jobs that **change data**: mass price updates, recalculations,
cleanup routines, bulk status changes.

```al
ProcessingOnly = true;
UseRequestPage = true;
```

Start from [ProcessingReport.al.template](./templates/ProcessingReport.al.template).

## This is the only report type that writes

Every other type is read-only. That makes this the highest-risk report to
build, and it needs guards the others do not.

## Mandatory safety elements

1. **Confirm before running**, stating how many records will change.

```al
if not Confirm(ConfirmUpdateQst, false, RecordCount) then
    CurrReport.Quit();
```

2. **A preview mode.** An `Update Records` boolean defaulting to **false**.
   When false, count and report without writing.

3. **Progress dialog** for anything over a few hundred records.

4. **Summary message at the end** — examined, changed, skipped. Silence after a
   batch job is unacceptable.

5. **Never `DeleteAll` customer data.** Flag or archive instead, and say so.

## Performance

- `ModifyAll` where the logic allows — far faster than a record loop.
- Commit in controlled batches for very large volumes; state the batch size.
- Never call HTTP inside the loop.

## Layout

There is none. If the user needs a log of what changed, write to a temp buffer
and open a page, or build a separate List report. Do not bolt a layout onto a
processing report.

## Common failures

| Symptom | Cause |
|---|---|
| User cannot tell if it worked | No summary message |
| Accidental mass change | No confirmation or preview mode |
| Appears frozen | No progress dialog |
| Times out on a large tenant | Record loop instead of `ModifyAll`, no batching |
| Data loss | `DeleteAll` instead of flag-and-archive |

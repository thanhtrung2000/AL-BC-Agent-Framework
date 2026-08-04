---
name: al-report-validation
description: Build validation and pre-posting check reports in Business Central that list problems without fixing them — missing dimensions, blocked accounts, unbalanced entries, incomplete master data. Use when the output tells the user what is wrong before they run a posting routine.
argument-hint: [what to validate]
---

# Validation / Pre-Posting Check Report

For reports that **find problems and report them**: pre-posting checks, master
data completeness, dimension validation, blocked-record detection.

Start from [ValidationReport.al.template](./templates/ValidationReport.al.template).

## The defining rule: never modify data

```al
ProcessingOnly = false;
DataAccessIntent = ReadOnly;
```

If it fixes anything, it is a Processing-only report and belongs in
`al-report-processing`.

Users run these to decide whether posting is safe. A report that silently
"helpfully" corrects data destroys that trust and hides the real problem.

## Structure: scan into a temp error buffer

```
OnPreReport -> scan source records
            -> for each problem, insert into a temp error buffer
dataset     -> dataitem over the temp buffer
```

## Error buffer shape

| Field | Purpose |
|---|---|
| `Entry No.` | Sequence for stable ordering |
| `Source Record ID` | `RecordId` so the user can navigate to the record |
| `Severity` | Error / Warning / Information |
| `Message` | What is wrong, in the user's language |
| `Suggested Fix` | What to do about it |

## Severity discipline

- **Error** — posting will fail or produce wrong data. Blocks the process.
- **Warning** — posting succeeds but something is questionable.
- **Information** — advisory only.

Group by severity, errors first. Show a count per severity at the top so the
user sees the scale immediately.

## Messages

```al
MissingDimensionErr: Label 'Line %1 on document %2 is missing dimension %3.',
    Comment = '%1 = line no, %2 = document no, %3 = dimension code';
```

State what is wrong **and** what to do next. "Validation failed" is not a
message.

## Reuse in posting routines

Expose the scan as a public procedure on a codeunit so posting code calls the
same checks:

```al
procedure CheckDocument(DocumentNo: Code[20]; var ErrorBuffer: Record "<AFFIX> Check Buffer" temporary): Boolean
```

The report becomes a thin wrapper. This stops two implementations of the same
rules drifting apart. If that codeunit does not exist, list it in
`REFERENCES REQUIRED` — it belongs to `al-object-builder`.

## Common failures

| Symptom | Cause |
|---|---|
| Report changes data | Built as validation but writes — wrong type |
| Users ignore the output | No severity grouping, no counts |
| Rules drift from posting code | Checks duplicated instead of shared via codeunit |
| Cannot find the bad record | No `RecordId` in the buffer |

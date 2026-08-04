---
name: 'AL Report Conventions'
description: 'Shared conventions for every AL report type in Business Central — dataset design, filtering, request pages, layouts, and performance'
applyTo: '**/*.Report.al,**/*.ReportExt.al'
---

# AL Report Conventions — shared across ALL report types

These hold for document, list, statistical, processing-only, validation, and
extension reports alike. Type-specific skills add to them; nothing overrides
them.

## Dataset design

- Design the DataItem tree **before** writing anything. A wrong dataset shape
  cannot be rescued in the layout.
- **Filter in AL, never in the layout.** Apply `DataItemTableFilter` and
  `SetRange`/`SetFilter` in `OnPreDataItem`. Streaming a full table and letting
  the layout discard rows is the single largest report performance defect in BC.
- `SetLoadFields` on wide source tables.
- `SetCurrentKey` must match the filter pattern, or SQL scans instead of seeks.

## Request page

- `RequestFilterFields` on the primary DataItem so users get the standard
  filter pane. Choose the two or three fields people actually filter on.
- `ApplicationArea` on **every** control, or it does not render.
- `Caption` and `ToolTip` on every field and group. ToolTips start with
  "Specifies ".
- Parameterise rather than hardcode: date ranges, filters, toggles.
- `SaveValues = true` where re-running with the same options is common.

## Layouts

- Set `DefaultRenderingLayout`.
- Caption and translate every column header and label.
- Repeat column headers across pages; align totals with their group.
- Compute totals in the **dataset**, never in the layout — layout totals break
  at page boundaries.
- **Never fabricate `.rdlc` or `.docx` binary content.** Produce the AL, define
  the dataset completely, and report the layout artifact as outstanding.
  Hand-written RDLC that has never been opened in Report Builder produces a file
  that fails at runtime, and the failure only surfaces when a user runs it.

## Performance

| Property | When |
|---|---|
| `DataAccessIntent = ReadOnly` | Any report that does not write |
| `MaximumDatasetSize` | Where an unfiltered run could return millions of rows |
| `ProcessingOnly = true` | Batch jobs with no printed output |
| `UseRequestPage` | Set deliberately, not by default |

- Never call `CalcFields` inside a loop — add a FlowField column instead.
- Never call HTTP inside a report loop.

## Language and localisation

- Documents set `CurrReport.Language` **per record**, in the header's
  `OnAfterGetRecord`, using `Language.GetLanguageIdOrDefault`.
- Never concatenate addresses manually — use the `Format Address` codeunit.
- Period logic uses `Accounting Period`, not calendar arithmetic, unless the
  requirement explicitly says calendar. A company with a non-January fiscal
  year start gets silently wrong quarter labels otherwise.

## Text

- Every user-facing string is a `Label` with a `Comment` when parameterised.
- Messages state what happened and what to do next.

## Report extensions

- Extend base reports; never duplicate them. A copied base report diverges from
  Microsoft updates permanently.
- Affix every added column, layout, and request page field.
- Anchor to top-level DataItems where possible — nested loop items are renamed
  more often.
- You cannot change an existing column's source, remove a base column, or alter
  the DataItem tree. If the dataset shape must change, a new report is required.

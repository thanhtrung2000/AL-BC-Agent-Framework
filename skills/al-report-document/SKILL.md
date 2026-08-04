---
name: al-report-document
description: Build printed business document reports in Business Central — sales invoices, purchase orders, shipments, statements, reminders, credit memos. Use when the output is a document sent to a customer or vendor, with header/line structure, company branding, and per-document language handling.
argument-hint: [document type]
---

# Document Report

For anything a customer or vendor receives.

Start from [DocumentReport.al.template](./templates/DocumentReport.al.template).

## Dataset shape

Always header → line, linked by document number.

```al
dataitem(Header; "Sales Invoice Header")
  dataitem(Line; "Sales Invoice Line")
    DataItemLink = "Document No." = field("No.");
    DataItemLinkReference = Header;
```

Add a `CopyLoop` integer DataItem when users must print multiple copies.

## Required elements

| Element | Why |
|---|---|
| `Company Information` record | Logo, address, VAT reg. no. on every page |
| Bill-to **and** ship-to address arrays | Use `Format Address` codeunit — never concatenate |
| `Language Code` handling | Per document, before lines render |
| Totals block | Subtotal, VAT breakdown by group, discount, total |
| `No. Printed` increment | Via the standard codeunit |

## Language — the silent defect

Set the language **per document**, in the header's `OnAfterGetRecord`:

```al
CurrReport.Language := Language.GetLanguageIdOrDefault("Language Code");
CurrReport.FormatRegion := Language.GetFormatRegionOrDefault("Format Region");
```

Miss this and a Vietnamese customer receives an English invoice with US date
formats. Nothing in the compiler catches it.

## Layout

- **Word layout** is the norm — business users expect to edit them.
- Set `DefaultRenderingLayout` and `WordMergeDataItem`.
- Header repeats on every page; totals appear only on the last.
- Never fabricate the `.docx`. Produce the AL and dataset, return `NEEDS_INPUT`
  for the layout file.

## Performance

- `SetLoadFields` on the header for fields the layout binds.
- `DataAccessIntent = ReadOnly`.
- Avoid `CalcFields` inside the line loop — add FlowField columns instead.

## Common failures

| Symptom | Cause |
|---|---|
| Wrong language on the printed document | `CurrReport.Language` not set per header |
| Address lines collapse or duplicate | Manual concatenation instead of `Format Address` |
| Logo missing | `Company Information` not read, or `Picture` not calculated |
| Totals wrong on multi-page | Totalling done in layout instead of dataset |

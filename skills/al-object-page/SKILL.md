---
name: al-object-page
description: Create new AL pages owned by this extension - list, card, document, worksheet, part, role centre.
---

# Create a Page
Start from [Page.al.template](./templates/Page.al.template).
- Correct PageType; UsageCategory or not searchable. ApplicationArea on **every** control or it does not render.
- ToolTip "Specifies ". Actions delegate to a codeunit. API pages are al-integration-builder.
| Symptom | Cause |
|---|---|
| Field invisible at runtime | ApplicationArea missing |

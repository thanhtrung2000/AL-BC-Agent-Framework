---
name: al-extend-page
description: Create page extensions that add fields, actions, groups, parts to base pages, with stable anchor selection.
---

# Extend a Page
Start from [PageExt.al.template](./templates/PageExt.al.template).
- Anchor addlast(long-lived group) > addafter(control). Long-lived: General, Lines, Invoicing, Shipping, factboxes. Name the anchor.
- ApplicationArea + Caption + ToolTip on added controls. modify() for tweaks; never remove a base control.
| Symptom | Cause |
|---|---|
| Compile break after update | Anchored to a moved control |

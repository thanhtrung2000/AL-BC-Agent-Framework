---
name: al-extend-page
description: Create page extensions adding fields/actions to base pages, with stable anchors.
---

# Extend a Page
Start from [PageExt.al.template](./templates/PageExt.al.template).
- Anchor addlast(long-lived group) > addafter(control). Name the anchor. ApplicationArea+Caption+ToolTip on added controls. Never remove a base control.
| Symptom | Cause |
|---|---|
| Compile break after update | Anchored to a moved control |

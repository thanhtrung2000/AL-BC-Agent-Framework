---
name: 'al-pages'
applyTo: '**/*.Page.al,**/*.PageExt.al'
---

# AL Page Conventions
- Caption, correct PageType, UsageCategory (or not searchable), ApplicationArea on the page AND every field/action.
- ToolTip "Specifies ". Every action needs ApplicationArea/Caption/ToolTip/Image and delegates to a codeunit.
- Extensions: anchor addlast(<stable group>); name the anchor; never remove a base control. No UsageCategory on API pages.

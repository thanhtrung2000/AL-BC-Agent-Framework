---
name: 'AL Page Conventions'
description: 'Conventions for AL page and page extension objects in Business Central'
applyTo: '**/*.Page.al,**/*.PageExt.al'
---
# AL Page Conventions
- Caption, correct PageType, UsageCategory (or not searchable), ApplicationArea on the page AND every field/action.
- ToolTip "Specifies ". Every action needs ApplicationArea/Caption/ToolTip/Image and delegates to a codeunit.
- Extensions: anchor addlast(<stable group>); name the anchor; modify() for tweaks; never remove a base control; affix everything.
- No UsageCategory on an API page.

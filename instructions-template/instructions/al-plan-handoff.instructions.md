---
name: 'AL Plan Handoff'
description: 'Applies when planning an implementation plan for a Business Central AL feature. Makes the built-in Plan agent emit the work-packet routing table that al-implementer needs.'
applyTo: '**/*.al,**/app.json'
---
# Planning an AL feature — output format for handoff
## Setup gate
Read .github/al-setup.md. If it still has <...> placeholders, stop and tell the developer to fill it in.
## The plan MUST end with a work-packet table
```markdown
## Work packets
| # | Packet | Expert | Files | Depends on |
| P1 | <intent> | al-object-builder | src/... | none |
```
## Routing
| Work | Expert |
|---|---|
| New table/page/codeunit/enum/interface/query/XMLport | al-object-builder |
| Extend a base object OR subscribe to a base event | al-extension-builder |
| Any report type/extension, OR an RDLC layout from a picture/Excel | al-report-builder |
| API page/query, outbound HTTP, OAuth | al-integration-builder |
| Permission set, entitlement | al-permission-builder |

Edge cases: API page/query -> integration; report extension -> report; codeunit wrapping HTTP -> integration; business-logic codeunit -> object; base-table field -> extension; own-table field -> object; subscriber -> extension (logic stays object; split); "design the layout" -> report (RDLC layout).
Do NOT pick a sub-type or skill — each expert classifies its own.
## Handing off
Do not write AL. On approval the developer selects al-implementer at Start Implementation.

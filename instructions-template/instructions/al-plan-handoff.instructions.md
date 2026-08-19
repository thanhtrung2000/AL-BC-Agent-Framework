---
name: 'al-plan-handoff'
applyTo: '**/*.al,**/app.json'
---
# Planning an AL feature — handoff format
## Setup gate
Read .github/al-setup.md. If <...> placeholders remain, stop and tell the developer to fill it in.
## The plan MUST end with a work-packet table
| # | Packet | Expert | Files | NEW/EDIT | Depends on |
## Routing
New object→al-object-builder; extend a base object or subscribe→al-extension-builder; any report/RDLC layout→al-report-builder; API/HTTP/OAuth→al-integration-builder; permission set/entitlement→al-permission-builder. Edge cases: API page/query→integration; report ext→report; base-table field→extension; own-table field→object; subscriber→extension (split). Mark each packet NEW/EDIT. Each expert classifies its own sub-type.

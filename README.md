# AL Copilot Framework v2.1.1 — Agent Plugin
Plan → Implement automation for Business Central AL development. A read-only planner drafts a
work-packet plan; an orchestrator routes each packet to a domain expert; each expert classifies
the sub-type first, then loads one focused skill.

**7 agents · 23 skills · 22 templates · 4 commands · 7 instruction files**

## What's new in v2.1.1
`al-report-rdlc-layout` — generate an RDLC layout (.rdl) from a **picture** or **Excel mock-up**,
validated offline (XSD schema + field bindings + expression whitelist) so your single cloud-sandbox
preview passes on the first try. It fills a validated template — never hand-writes RDL structure —
and returns PREVIEW_REQUIRED, never "final". Report skills 6 → 7; total skills 22 → 23.

## Architecture
```
/al-feature OR built-in /plan
  → al-planner (read-only) → [approve] → al-implementer (no edit tool)
     ├─ al-object-builder        (5 skills)
     ├─ al-extension-builder     (4 skills — incl. al-extend-events)
     ├─ al-report-builder        (7 skills — incl. al-report-rdlc-layout)
     ├─ al-integration-builder   (4 skills)
     └─ al-permission-builder    (2 skills)   + al-framework-setup
```

## Install
1. `pwsh ./check-plugin-ready.ps1` → PLUGIN_READY=OK
2. `git init && git add . && git commit -m "v2.1.1"` (from THIS folder)
3. `git push -u origin main && git tag v2.1.1 && git push --tags`
4. BC project → Chat: Install Plugin From Source → repo URL → reload
5. `/al-bc-framework:al-framework-setup` → fill SETUP → commit

## Commands
`/al-bc-framework:al-feature` · `:al-quick-object` · `:al-stat-report` · `:al-report-layout` · `:al-framework-setup`

## RDLC layout — the honest boundary
Cloud-only cannot test-RUN the report, so this is NOT "zero error, never runs". It IS: three offline
checks that eliminate structure/binding/expression failures, so the one Ctrl+F5 preview succeeds
nearly every time. Adding a local validation container later upgrades PREVIEW_REQUIRED to VERIFIED
without changing the skill. See CHANGELOG.md.

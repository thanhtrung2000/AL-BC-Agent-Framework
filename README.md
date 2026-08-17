# AL Copilot Framework v2.2.0 — Agent Plugin
Plan → Implement automation for Business Central AL development. A read-only planner drafts a
work-packet plan; an orchestrator routes each packet to a domain expert; each expert classifies
the sub-type first, then loads one focused skill.

**7 agents · 23 skills · 22 templates · 4 commands · 8 instruction files (incl. al-setup.md)**

## What's new in v2.2.0
The SETUP block is now a SEPARATE file, `.github/al-setup.md`, which the framework NEVER overwrites.
`copilot-instructions.md` becomes pure conventions that update freely. This makes instruction
updates trivial and safe — no preservation logic, no risk to your project settings. Includes a
`migrate-to-2.2.ps1` helper that moves existing SETUP values into al-setup.md without re-typing.

New person? Read **SETUP-GUIDE.md** — the complete step-by-step flow.

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

## Install (see SETUP-GUIDE.md for the full walkthrough)
1. `pwsh ./check-plugin-ready.ps1` → PLUGIN_READY=OK
2. `git init && git add . && git commit -m "v2.2.0"` (from THIS folder) ; push ; tag v2.2.0
3. BC project → Chat: Install Plugin From Source → repo URL → reload
4. `pwsh <plugin-root>/skills/al-framework-setup/scripts/install-instructions.ps1`
5. Fill `.github/al-setup.md` → commit

## Commands
`/al-bc-framework:al-feature` · `:al-quick-object` · `:al-stat-report` · `:al-report-layout` · `:al-framework-setup`

## The v2.2.0 SETUP split — why it matters
| File | Owner | Updates on a framework release? |
|---|---|---|
| copilot-instructions.md | Framework | Yes — overwritten freely |
| al-setup.md | You | Never — protected |
Because they are separate, updating conventions can never wipe your affix/ID range. See CHANGELOG.md.

# AL Copilot Framework v1.0.0 — Agent Plugin
First team release. Plan → Implement automation for Business Central AL development.
A read-only planner drafts a work-packet plan; an orchestrator routes each packet to a
domain expert; each expert **checks the code first**, classifies the sub-type, loads one
focused skill, and the build is driven to **zero compile errors** before anything is "done".

**7 agents · 23 skills · 22 templates · 9 syntax references · 5 scripts · 4 commands · 8 instruction files**

## What v1.0.0 guarantees (the fixes proven in testing)
- **No duplicate objects.** Every builder checks first and edits in place (AL0264/AL0139 prevented).
- **Nothing "done" over a red build.** The implementer compiles and fixes to zero errors.
- **Correct AL syntax.** An always-on fundamentals rule (var/begin structure) plus per-object
  syntax references that load on demand — cheap, focused.
- **Your model, your cost.** No model is pinned; you pick it in the VS Code dropdown.
- **Safe settings.** Project settings live in .github/al-setup.md, never overwritten by updates.
- **Correct install.** The installer locates the plugin root robustly (no path-level bug).

## Architecture
```
/al-feature OR built-in /plan
  → al-planner (read-only, searches first) → [approve] → al-implementer (no edit tool, BUILD GATE)
     ├─ al-object-builder        (5 skills, + syntax refs)
     ├─ al-extension-builder     (4 skills, + syntax refs)
     ├─ al-report-builder        (7 skills, incl. RDLC-from-picture)
     ├─ al-integration-builder   (4 skills)
     └─ al-permission-builder    (2 skills)   + al-framework-setup
```

## Install — see SETUP-GUIDE.md for the full walkthrough
1. `pwsh ./check-plugin-ready.ps1` → PLUGIN_READY=OK
2. `git init && git add . && git commit -m "v1.0.0"` (from THIS folder); push; tag v1.0.0
3. BC project → Chat: Install Plugin From Source → repo URL → reload
4. `pwsh <plugin-root>/skills/al-framework-setup/scripts/install-instructions.ps1`
5. Fill `.github/al-setup.md` → commit

## Commands
`/al-bc-framework:al-feature` · `:al-quick-object` · `:al-stat-report` · `:al-report-layout` · `:al-framework-setup`

## Two-layer AL syntax (cost-efficient)
Layer 1 (always-on, ~40 lines): universal var/begin rules — al-language-fundamentals.
Layer 2 (on demand): detailed grammar per object type, loaded only when that type is built.

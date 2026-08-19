# AL Copilot Framework — Complete Setup Guide (v1.0.0)
Zero to generating AL, step by step. Three one-time setups, then a daily loop.

## The picture
```
YOU (VS Code + Copilot)
 ├─ PLUGIN (installed once, globally)   agents, skills, commands
 └─ YOUR BC PROJECT (per repo)
      .github/copilot-instructions.md   conventions (framework-owned)
      .github/al-setup.md               YOUR settings (fill once, never overwritten)
      .github/instructions/             AL fundamentals + 6 scoped rule sets
      .vscode/settings.json             AL analyzers
      src/                              the AL the agents generate
```

## PART A — Install the plugin (once per person)
A1. User settings JSON: `"chat.plugins.enabled": true`.
A2. Ctrl+Shift+P → Chat: Install Plugin From Source → `https://github.com/<org>/al-bc-framework`.
A3. Developer: Reload Window.
A4. Type `/` in Chat → see the al-bc-framework: commands. Dropdown shows al-planner + al-implementer (5 builders hidden — correct).

## PART B — Install instructions (once per repo, zero AI credits)
B1. Open your BC project (folder with app.json).
B2. In the terminal: `pwsh <plugin-root>/skills/al-framework-setup/scripts/install-instructions.ps1`
   Plugin root: Windows %APPDATA%\Code\agentPlugins\github.com\<org>\al-bc-framework ·
   macOS ~/Library/Application Support/Code/agentPlugins/... · Linux ~/.config/Code/agentPlugins/...
   Creates copilot-instructions.md + 7 scoped instructions + al-setup.md (blank).

## PART C — Fill in your settings (once per repo)
C1. Open .github/al-setup.md, replace the 5 placeholders (the script printed the app.json values).
C2. Verify: `install-instructions.ps1 -VerifyOnly` → SETUP_STATUS=OK.
C3. Commit: `git add .github/ .vscode/settings.json && git commit -m "AL conventions" && git push`.
> Agents refuse to run until al-setup.md is complete — a wrong ID range fails AppSourceCop at release.

## PART D — Daily loop
D1. Full feature: `/al-bc-framework:al-feature` → describe it → answer the planner's questions →
   review the work-packet table (each marked NEW/EDIT) → Start Implementation → al-implementer →
   it builds to zero errors → you review the diff and write tests.
D2. Single object: `/al-bc-framework:al-quick-object`.
D3. Report layout from a picture: `/al-bc-framework:al-report-layout` → give a screenshot + report name →
   it returns PREVIEW_REQUIRED → `Ctrl+F5` renders once in your cloud sandbox.

## PART E — Keeping current
Update the plugin (Extensions: Check for Extension Updates → reload). Re-run install-instructions.ps1
only if the CHANGELOG says conventions changed — it overwrites framework-owned files but NEVER your al-setup.md.

## Troubleshooting
No commands → plugin not installed / chat.plugins.enabled off. NEEDS_SETUP every run → fill al-setup.md.
Duplicate object → old agents cached; reload the window. Build red → the implementer reports the exact errors; fix and rebuild.
Diagnostics: right-click in Chat → Diagnostics.

## 60-second summary
```
ONCE/person: install plugin (A)
ONCE/repo:   install instructions (B) + fill al-setup.md + commit (C)
DAILY:       /al-feature → approve → Start Implementation → build passes → review + tests
LAYOUTS:     /al-report-layout → Ctrl+F5
UPDATES:     update plugin; re-install only if conventions changed (al-setup.md is safe)
```

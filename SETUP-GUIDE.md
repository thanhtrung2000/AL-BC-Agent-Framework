# AL Copilot Framework — Setup Guide (v1.0.0)
## PART A — install plugin (once/person)
Enable chat.plugins.enabled → Chat: Install Plugin From Source → repo URL → Reload Window.
Type `/` → see al-bc-framework: commands; dropdown shows al-planner + al-implementer.
## PART B — install instructions (once/repo, zero credits)
Open the BC project → terminal: `pwsh <plugin-root>/skills/al-framework-setup/scripts/install-instructions.ps1`.
Creates copilot-instructions.md + 7 scoped instructions + al-setup.md.
## PART C — fill settings (once/repo)
Edit .github/al-setup.md (5 values from app.json) → `-VerifyOnly` → SETUP_STATUS=OK → commit .github/.
## PART D — daily loop
/al-bc-framework:al-feature → describe → answer questions → review packets (NEW/EDIT) → Start Implementation
→ dup scan + build to zero errors → review diff, write tests.
/al-quick-object for one object. /al-report-layout for an RDLC layout (Ctrl+F5 to preview).
## PART E — updates
Update the plugin; re-run install-instructions.ps1 only if conventions changed (al-setup.md is safe).

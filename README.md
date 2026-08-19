# AL Copilot Framework v1.0.0
First team release. Plan -> Implement automation for Business Central AL development. Each expert
enforces one file = one object (no duplicates); reports link to their layout by a deterministic name;
the implementer runs a duplicate scan then compiles to zero errors before anything is "done".

**7 agents / 23 skills / 22 templates / 9 syntax refs / 6 scripts / 4 commands / 9 instruction files**

## v1.0.0 guarantees
- No duplicate objects (one file = one object + dup scanner; AL0264/AL0139).
- Report <-> layout linked by a deterministic name; layout designed only when a picture/description is given.
- Nothing "done" over a red build.
- Correct AL syntax (always-on fundamentals + on-demand per-object syntax refs).
- Model unpinned. SETUP split (al-setup.md protected). Robust installer.

## Install (see SETUP-GUIDE.md)
1. pwsh ./check-plugin-ready.ps1 -> PLUGIN_READY=OK
2. git init/add/commit/tag v1.0.0/push (from THIS folder)
3. BC project -> Chat: Install Plugin From Source -> repo URL -> reload
4. pwsh <plugin-root>/skills/al-framework-setup/scripts/install-instructions.ps1
5. Fill .github/al-setup.md -> commit

---
name: al-framework-setup
description: Install and verify the AL Copilot Framework instruction files in a Business Central repository. Use once after installing the plugin, or when agents report NEEDS_SETUP. Copies conventions + 6 scoped instructions and creates al-setup.md (only if absent). Never overwrites your filled-in al-setup.md.
argument-hint: [install | verify]
---

# AL Framework Setup (v2.2.0)
Plugins distribute agents/skills/commands - NOT instruction files. This installs them.
v2.2.0 change: your project settings live in a SEPARATE file, `.github/al-setup.md`,
which the framework NEVER overwrites. Conventions are framework-owned and update freely.

## Install
`pwsh <plugin-root>/skills/al-framework-setup/scripts/install-instructions.ps1`
- Copies copilot-instructions.md + 6 scoped instructions (overwrites - they carry no user values).
- Copies al-setup.md ONLY IF ABSENT (never overwrites your filled-in settings).
Use `-Force` to overwrite the conventions files; al-setup.md is still protected.

## Fill al-setup.md (once)
Open `.github/al-setup.md` and replace the 5 placeholders (AFFIX, PRODUCTION ID RANGE,
TEST ID RANGE, TARGET BC VERSION, PUBLISHER). The script prints values from app.json.
Verify with `-VerifyOnly`. Enable the four AL analyzers in .vscode/settings.json. Commit .github/.

## Migrating from v2.1.x (SETUP was inside copilot-instructions.md)
Run: `pwsh <plugin-root>/skills/al-framework-setup/scripts/migrate-to-2.2.ps1`
It extracts your 5 SETUP values from the old copilot-instructions.md, writes them to
al-setup.md, and replaces the conventions file with the pure v2.2.0 version. Your values
are preserved - no re-typing.

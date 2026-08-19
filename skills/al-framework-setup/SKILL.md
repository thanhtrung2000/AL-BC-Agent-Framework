---
name: al-framework-setup
description: Install and verify the AL Copilot Framework instruction files in a BC repository. Use once after installing the plugin, or when agents report NEEDS_SETUP. Copies conventions + scoped instructions and creates al-setup.md (only if absent). Never overwrites your al-setup.md.
argument-hint: [install | verify]
---
# AL Framework Setup
Plugins distribute agents/skills/commands - NOT instruction files. This installs them.
Project settings live in a SEPARATE .github/al-setup.md that the framework NEVER overwrites.

## Install
`pwsh <plugin-root>/skills/al-framework-setup/scripts/install-instructions.ps1`
Copies copilot-instructions.md + 7 scoped instructions (incl. al-language-fundamentals);
creates al-setup.md ONLY IF ABSENT. `-Force` overwrites conventions; al-setup.md still protected.

## Fill al-setup.md (once)
Open `.github/al-setup.md`, replace the 5 placeholders. The script prints values from app.json.
Verify with `-VerifyOnly`. Enable the four AL analyzers. Commit .github/.

---
name: al-framework-setup
description: Install and verify the AL Copilot Framework instruction files in a BC repository. Copies conventions + scoped instructions and creates al-setup.md (only if absent). Never overwrites your al-setup.md.
argument-hint: [install | verify]
---
# AL Framework Setup
Plugins distribute agents/skills/commands - NOT instruction files. This installs them.
Settings live in a SEPARATE .github/al-setup.md the framework NEVER overwrites.
## Install
`pwsh <plugin-root>/skills/al-framework-setup/scripts/install-instructions.ps1`
Copies copilot-instructions.md + 7 scoped instructions; creates al-setup.md ONLY IF ABSENT.
## Fill al-setup.md, then commit. Verify with -VerifyOnly.

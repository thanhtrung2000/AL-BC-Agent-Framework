---
name: al-framework-setup
description: Install and verify the AL Copilot Framework instruction files in a Business Central repository. Use once after installing the plugin, or when agents report NEEDS_SETUP. Copies 7 instruction templates into .github/ and checks the SETUP block.
argument-hint: [install | verify]
---

# AL Framework Setup
Plugins distribute agents/skills/commands - NOT instruction files. This installs them.

## Install
`pwsh <plugin-root>/skills/al-framework-setup/scripts/install-instructions.ps1`
Add `-Force` to overwrite (backs up to .bak). Creates copilot-instructions.md + 6 instructions
(tables, pages, codeunits, reports, integration, plan-handoff).

## Fill the SETUP block
AFFIX, PRODUCTION ID RANGE, TEST ID RANGE, TARGET BC VERSION, PUBLISHER. The script prints values
from app.json. Verify with `-VerifyOnly`. Enable the four AL analyzers. Commit .github/.

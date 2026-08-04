---
name: al-framework-setup
description: Install and verify the AL Copilot Framework instruction files in a Business Central repository. Use once after installing the plugin, or when agents report NEEDS_SETUP. Copies instruction templates into .github/ and checks the SETUP block is complete.
argument-hint: [install | verify]
---

# AL Framework Setup

Run **once per BC repository** after installing the plugin, and again whenever
an agent returns `NEEDS_SETUP`.

## Why this step exists

Agent plugins distribute **agents, skills, and commands**. They do **not**
distribute instruction files.

Instructions must live in the repository because:

- they are version-controlled next to the code they govern
- every teammate on that project needs the identical set
- they differ per project — different affix, different ID range

This skill bridges that gap.

## Step 1 — Install

```powershell
pwsh <plugin-root>/skills/al-framework-setup/scripts/install-instructions.ps1
```

Add `-Force` to overwrite existing files. Each is backed up to `.bak` first.

Creates:

```
.github/
├── copilot-instructions.md          always-on, contains SETUP block
└── instructions/
    ├── al-tables.instructions.md
    ├── al-pages.instructions.md
    ├── al-codeunits.instructions.md
    ├── al-reports.instructions.md
    └── al-integration.instructions.md
```

Existing files are never silently overwritten.

## Step 2 — Fill in the SETUP block

Open `.github/copilot-instructions.md`:

```
AFFIX / PREFIX      : <e.g. VSA>
PRODUCTION ID RANGE : <e.g. 50000..50099>
TEST ID RANGE       : <e.g. 50100..50149>
TARGET BC VERSION   : <e.g. 26.0>
PUBLISHER           : <e.g. Contoso>
```

| Value | Source |
|---|---|
| Production ID range | `app.json` → `idRanges` |
| Target BC version | `app.json` → `application` |
| Publisher | `app.json` → `publisher` |
| Affix | Your team standard. For AppSource, registered with Microsoft |
| Test ID range | Your choice — must sit **outside** the production range |

The script reads `app.json` and prints the detected values.

## Step 3 — Verify

```powershell
pwsh <plugin-root>/skills/al-framework-setup/scripts/install-instructions.ps1 -VerifyOnly
```

Checks every file exists, every `*.instructions.md` declares `applyTo`, no
`<...>` placeholders remain, and all four AL analyzers are enabled.

## Step 4 — Enable the AL analyzers

```json
// .vscode/settings.json
{
  "al.codeAnalyzers": [
    "${CodeCop}", "${UICop}", "${AppSourceCop}", "${PerTenantExtensionCop}"
  ]
}
```

The framework's instructions deliberately skip everything these catch, so agent
context goes to what a linter cannot see. Without them you lose half the
coverage.

## Step 5 — Commit

```bash
git add .github/ .vscode/settings.json
git commit -m "Add AL Copilot Framework conventions"
```

These are team conventions, not personal settings.

## Step 6 — Confirm the plugin loaded

Right-click in Chat → **Diagnostics**:

- **Agents**: `al-planner` and `al-implementer` in the dropdown; the five
  builders are subagent-only by design
- **Skills**: 21, prefixed `al-bc-framework:`
- **Commands**: 4, prefixed `al-bc-framework:`

## Troubleshooting

| Symptom | Fix |
|---|---|
| Agent returns `NEEDS_SETUP` | Re-run steps 1–3 |
| `app.json not found` | `cd` to the extension root, or pass `-Root` |
| Skills missing from `/` menu | Extensions view → `@agentPlugins` → enable |
| `pwsh: command not found` | Install PowerShell 7, or copy files manually |

## Manual installation

```
<plugin-root>/instructions-template/copilot-instructions.md  ->  .github/
<plugin-root>/instructions-template/instructions/*           ->  .github/instructions/
```

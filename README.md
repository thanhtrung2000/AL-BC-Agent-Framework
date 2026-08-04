# AL Copilot Framework v2.0.0 — Agent Plugin

Plan → Implement automation for Microsoft Dynamics 365 Business Central AL
development, packaged as an installable VS Code agent plugin.

You describe a feature. A read-only planner researches your codebase and drafts
a work-packet plan. You approve it. An orchestrator routes each packet to a
domain expert. **Each expert classifies the sub-type first, then loads one
focused skill.**

---

## Architecture

```
Feature description
  │
  └─> al-planner                    STAGE 1 — read-only, no edits
        │  Discovery → Alignment → Design → Refinement
        │  [you approve]
        ▼
      al-implementer                STAGE 2 — orchestrator, NO edit tool
        │  decompose → route → sequence → build
        │
        ├─> al-object-builder ──────┬─> al-object-table
        │                           ├─> al-object-page
        │                           ├─> al-object-codeunit
        │                           ├─> al-object-enum-interface
        │                           └─> al-object-query-xmlport
        │
        ├─> al-extension-builder ───┬─> al-extend-table
        │                           ├─> al-extend-page
        │                           └─> al-extend-enum-profile
        │
        ├─> al-report-builder ──────┬─> al-report-document
        │                           ├─> al-report-list
        │                           ├─> al-report-statistical
        │                           ├─> al-report-processing
        │                           ├─> al-report-validation
        │                           └─> al-report-extension
        │
        ├─> al-integration-builder ─┬─> al-integration-api-page
        │                           ├─> al-integration-api-query
        │                           ├─> al-integration-outbound
        │                           └─> al-integration-auth
        │
        └─> al-permission-builder ──┬─> al-permission-set
                                    └─> al-permission-entitlement
              │
              └─ BUILD: pass
                   │
                   └─ [you] review diff · write tests · check upgrade impact
```

**7 agents · 21 skills · 20 templates · 4 commands · 6 instruction files**

---

## Why one agent per domain, many skills per agent

An agent defines **who** (persona, tools, model). A skill defines **what**
(procedure, template, checklist).

All five object types need the identical tool set, so they are one agent. What
differs between a table and a codeunit is the *procedure* — and that is exactly
what skills are for.

| Signal | New agent? |
|---|---|
| Different tools needed | ✅ Yes |
| Different trust level (read-only vs edit) | ✅ Yes |
| Needs parallel execution | ✅ Yes |
| Only the procedure differs | ❌ Use a skill |

Skills load progressively: the agent sees N one-line descriptions, loads **one**
skill body, and reads **one** template. Twenty-one skills cost roughly what one
costs.

---

## Install

### 1. Verify before pushing

```powershell
pwsh ./check-plugin-ready.ps1
```

Checks the eight things that fail **silently** at install time — illegal
`plugin.json` name, skill name ≠ folder name, namespace prefixes, skill/command
collisions, broken template links, missing `agent` tool, version mismatch.

### 2. Push

```bash
git init && git add . && git commit -m "AL Copilot Framework v2.0.0"
git branch -M main
git remote add origin https://github.com/<your-org>/al-bc-framework.git
git push -u origin main
git tag v2.0.0 && git push --tags
```

Private repos work — VS Code falls back to cloning with your Git credentials.

### 3. Install into a BC project

Open your **BC project** (the folder with `app.json`), then:

```
Ctrl/Cmd + Shift + P  →  Chat: Install Plugin From Source
```

Paste `https://github.com/<your-org>/al-bc-framework`, then
**Developer: Reload Window**.

Requires `"chat.plugins.enabled": true` in **User** settings.

### 4. Set up the project

```
/al-bc-framework:al-framework-setup
```

Copies six instruction files into `.github/`, reads `app.json`, and prints the
values for the SETUP block. Then fill in
`.github/copilot-instructions.md` and commit it.

**Agents refuse to run until the SETUP block is complete.** A wrong object ID
range compiles fine and fails AppSourceCop at release — stalling is cheaper.

---

## Team rollout

Commit this once per BC repo. Teammates get a notification on their first chat
message and install with one click.

```json
// .github/copilot/settings.json
{
  "extraKnownMarketplaces": {
    "al-bc-tools": {
      "source": { "source": "github", "repo": "<your-org>/al-bc-framework" }
    }
  },
  "enabledPlugins": { "al-bc-framework@al-bc-tools": true }
}
```

Ready-made copy in `examples/workspace-settings.json`.

---

## Commands

| Command | Use |
|---|---|
| `/al-bc-framework:al-feature` | Full plan-then-implement flow |
| `/al-bc-framework:al-quick-object` | Single object, skips planning |
| `/al-bc-framework:al-stat-report` | Statistical report |
| `/al-bc-framework:al-api` | API page, API query, or outbound integration |
| `/al-bc-framework:al-framework-setup` | Install and verify instructions |

---

## Routing matrix

| Work | Expert |
|---|---|
| New table, page, codeunit, enum, interface, query, XMLport | `al-object-builder` |
| Extend a base or third-party object | `al-extension-builder` |
| Any report type, report extension, layout | `al-report-builder` |
| API page/query, outbound HTTP, OAuth | `al-integration-builder` |
| Permission set, entitlement | `al-permission-builder` |

**Edge cases:**

- **API page or API query** → integration-builder, *not* object-builder — the
  contract matters more than the object type
- **Report extension** → report-builder, *not* extension-builder
- Codeunit wrapping HTTP → integration-builder · with business logic →
  object-builder
- Field on a **base** table → extension-builder · on an **own** table →
  object-builder

A packet spanning two experts gets **split**.

---

## Design principles

**The orchestrator has no `edit` tool.** It physically cannot write AL, so it
must route. Enforcement, not guidance.

**Experts classify before building.** Getting the sub-type wrong — a document
report built as a statistical report — is a rewrite, not a tweak. Each agent
carries an explicit classification table plus rules for ambiguous cases.

**Experts declare what they do NOT own** and return `OUT_OF_SCOPE` naming the
correct expert rather than doing another specialist's work.

**`NEEDS_INPUT` over guessing.** Experts stall and name what is missing rather
than inventing an ID range, field name, or API contract.

**Shared discipline lives in instructions, not duplicated in skills.** One
source of truth per domain.

**No linter duplication.** Instructions deliberately skip everything CodeCop,
UICop, AppSourceCop, and PerTenantExtensionCop already enforce.

---

## Scope

| ✅ Does | ❌ Does not |
|---|---|
| Plan features into work packets | Automated code review |
| Generate objects, extensions, all report types, APIs, permissions | Generate tests |
| Allocate object IDs from `app.json` | Generate upgrade codeunits |
| Enforce conventions during generation | Produce RDLC/Word layout files |
| Compile and route build failures | Commit or open PRs |

**You still review the diff and write tests.**

---

## Requirements

- VS Code with GitHub Copilot, agent mode enabled
- `chat.plugins.enabled` set to `true` (may be org-managed)
- AL Language extension
- PowerShell 7+ (`pwsh`) for the bundled scripts
- BC sandbox or Docker container for compilation

---

## Shipping updates

```powershell
pwsh ./release.ps1 -Version 2.1.0 -Push -Message "Add al-events-builder"
```

Bumps `plugin.json` **and** `marketplace.json` atomically, validates, commits,
tags, and pushes. It also detects instruction-template changes and tells you to
warn the team — those do **not** propagate via plugin update.

⚠️ Bumping only one version file is the most common distribution bug. No error
appears; teammates silently stay on the old version.

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Plugin does not appear | `chat.plugins.enabled` off | Enable in User settings |
| Plugin does not appear, setting on | Illegal `name` in `plugin.json` | Lowercase, numbers, hyphens |
| A skill silently never loads | `name` ≠ folder name | Must match exactly |
| Commands have no prefix | Not loaded as a plugin | Check Extensions → `@agentPlugins` |
| All 7 agents in dropdown | `user-invocable: false` stripped | Restore in the five builders |
| Every run returns `NEEDS_SETUP` | SETUP block has placeholders | Fill in all five values |
| Agents ignore conventions | Instructions not applied | Check **References** list in the response |
| Update not received | Version bumped in only one file | Bump both |

Verify via right-click in Chat → **Diagnostics**.

---

## Security note

Plugins can bundle hooks and MCP servers that execute code. **This plugin ships
neither** — only agents, skills, commands, and three PowerShell scripts you
invoke explicitly.

---

See `CHANGELOG.md` for version history and roadmap.

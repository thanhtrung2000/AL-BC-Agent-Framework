# Changelog — AL Copilot Framework

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning is [Semantic](https://semver.org/).

---

## [2.0.0] — 2026-08-03

**Breaking.** Every expert now classifies the sub-type first, then loads one
focused skill. Skill names changed; the single monolithic skill per expert is
gone.

### Why

The v1 experts each shipped **one** template, so an expert titled "report
builder" was really a statistical-report builder wearing a general title. The
same was true across the board: `al-object-builder` had one table template but
was expected to build pages, codeunits, enums, interfaces, queries, and XMLports.

### Added

**Object skills (5)** — replacing the single `al-new-object`
- `al-object-table` — fields, keys, field groups, FlowFields, DataClassification
- `al-object-page` — all seven page types, actions, FactBoxes, performance
- `al-object-codeunit` — business logic, integration events, `IsHandled`,
  subscribers
- `al-object-enum-interface` — extensible enums, interface contracts, and the
  enum-implements-interface dispatch pattern that removes `case` statements
- `al-object-query-xmlport` — SQL-level joins and aggregation, CSV/XML import
  and export with culture-invariant parsing

**Extension skills (3)** — replacing the single `al-extend-object`
- `al-extend-table` — storage cost assessment, upgrade impact reporting
- `al-extend-page` — anchor stability ranking (the most common upgrade break)
- `al-extend-enum-profile` — enum values with implementations, profile and page
  customization

**Report skills (6)** — replacing the single `al-report-authoring`
- `al-report-document` — header/line, company branding, per-document language
- `al-report-list` — registers, ledgers, `RequestFilterFields`, key matching
- `al-report-statistical` — temp-buffer aggregation, accounting-period logic
- `al-report-processing` — the only report type that writes; confirmation,
  preview mode, progress dialog, mandatory summary
- `al-report-validation` — finds problems, never fixes them; severity grouping,
  `RecordId` drill-through, shared check codeunit
- `al-report-extension` — extend base reports, never duplicate

**Integration skills (4)** — replacing the single `al-integration-api`
- `al-integration-api-page` — inbound CRUD, permanent contract, versioning
- `al-integration-api-query` — read-only joins; the implicit GROUP BY trap
- `al-integration-outbound` — timeout, no-HTTP-in-transaction, retry policy
- `al-integration-auth` — Isolated Storage, OAuth token caching, masked setup

**Permission skills (2)** — replacing the single `al-permission-authoring`
- `al-permission-set` — coverage, minimum grants, indirect permissions, rollup
- `al-permission-entitlement` — AppSource licence mapping; Team Member must be
  read-only

**Tooling**
- `check-plugin-ready.ps1` — verifies the eight silent-failure modes before push,
  now including skill-to-template link integrity
- `release.ps1` — bumps `plugin.json` and `marketplace.json` atomically, detects
  instruction-template changes that do not propagate via plugin update

### Changed

- **All five experts now classify before building.** Each carries an explicit
  classification table plus rules for ambiguous cases — "print/send" → Document,
  "update/recalculate" → Processing, "check before posting" → Validation, a
  register → List not Statistical.
- **Agents load one skill, not all of them.** Progressive loading means 21
  skills cost roughly what one costs in context.
- `al-reports.instructions.md` expanded to hold the ~70% shared across all six
  report types, so type skills stay focused.
- Version 2.0.0 — skill names changed, so this is breaking for anyone who
  referenced them directly.

### Migration from 1.x

1. Update the plugin: **Extensions: Check for Extension Updates**
2. Re-run setup in each BC repo — the instruction templates changed:
   ```
   /al-bc-framework:al-framework-setup -Force
   ```
   Existing files are backed up to `.bak`; your filled-in SETUP block is
   recoverable.
3. Nothing else. Agent names and command names are unchanged.

### Known limitations

Deliberate scope cuts, not defects:

| Limitation | Manual workaround |
|---|---|
| No automated code review | Review the diff before committing |
| No test generation | Write AL test codeunits and Playwright specs by hand |
| No upgrade codeunit generation | `al-extend-table` reports upgrade impact; write the migration |
| No CI/CD integration | Agents run in VS Code only |
| RDLC/Word layouts not generated | Report skills produce AL + dataset; author the layout in a designer |

---

## [1.1.0] — 2026-08-03

Repackaged as an installable agent plugin.

### Added
- `plugin.json`, `marketplace.json`, `al-bc-framework.code-workspace`
- `al-framework-setup` skill with `install-instructions.ps1`
- `instructions-template/` staged for installation
- `commands/` distributed as plugin slash commands with automatic prefix

### Changed
- Agents read instructions by **workspace path**, not relative link — a plugin
  installs outside the workspace, so `../copilot-instructions.md` resolved to
  nothing
- `al-new-object` command renamed `al-quick-object` to avoid colliding with the
  skill of the same name (both share the `/` namespace)
- Setup guard now checks for a missing instructions file, not just placeholders

---

## [1.0.0] — 2026-08-03

First release. Scope: **Plan → Implement**.

### Added
- 6 instruction files with a SETUP block for affix, ID ranges, version, publisher
- 7 agents: `al-planner`, `al-implementer`, and 5 builders
- 5 skills, one per expert
- 4 prompt files

### Design decisions
- Orchestrator has no `edit` tool — it physically cannot write AL, so it must
  route
- Experts declare what they do NOT own and return `OUT_OF_SCOPE`
- Setup guard stops with `NEEDS_SETUP` rather than guessing an ID range
- Instructions linked, never duplicated — subagents inherit none
- No linter duplication

---

## Roadmap

### [2.1.0] — under consideration
- `al-events-builder` — event subscriber codeunits currently split between
  object-builder and integration-builder. The softest boundary in the matrix.
- `al-object-page` split into list/card/document sub-skills if page work proves
  to need it

### [3.0.0] — Review & Test gates
- `al-reviewer` orchestrator + `al-perf-reviewer`, `al-upgrade-reviewer`,
  `al-permission-reviewer` in parallel, all read-only
- `al-test-builder` with `verify-test-setup.ps1`
- `al-upgrade-builder`
- Build → Test → Review chain with BLOCK routed to the owning builder
- `PostToolUse` hook for deterministic formatting

### [4.0.0] — CI and organisation rollout
- Review ported to a skill with `context: fork` so it runs in the Copilot cloud
  agent and Azure DevOps PR validation
- Organization-level instructions so per-repo setup is unnecessary
- Optional MCP server for live BC environment queries

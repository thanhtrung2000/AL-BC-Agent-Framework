# Changelog — AL Copilot Framework

## [1.0.0] — 2026-08-03  (first team release)
Consolidates the internal 2.x iteration into a single, tested release. Every fix found
during sandbox testing is folded in.

### Included
- **Plan → Implement pipeline** — planner + implementer orchestrator + 5 domain experts.
- **23 skills** across object (5), extension (4), report (7 incl. RDLC-from-picture),
  integration (4), permission (2), plus the setup skill.
- **Anti-duplicate protocol** — every builder checks the code first and edits in place;
  the implementer runs a dedupe check. Prevents AL0264 (duplicate ID) / AL0139 (duplicate name).
- **Mandatory build gate** — the implementer compiles and drives to zero errors; never
  reports "done" over a red build; fix loop edits in place (never regenerates).
- **AL syntax knowledge** — always-on al-language-fundamentals (var/begin) + on-demand
  per-object syntax references (table, page, codeunit, enum/interface, query/xmlport,
  extensions, event subscribers).
- **Model unpinned** — the developer chooses the model in VS Code (cost control).
- **SETUP split** — project settings in .github/al-setup.md, never overwritten.
- **Robust installer** — locates the plugin root by searching upward (no folder-level bug).
- **RDLC layout skill** — offline-validated (.rdl from a picture/Excel); PREVIEW_REQUIRED.
- **Plan handoff** — the built-in /plan agent can hand off to al-implementer.

### Internal pre-release history (for reference)
2.0.0 skill split · 2.0.1 plan handoff · 2.1.0 events skill · 2.1.1 RDLC layout ·
2.2.0 SETUP split. These were development iterations; 1.0.0 is the first release to the team.

## Roadmap
- v1.1.0 — Review & Test gates (al-reviewer + parallel read-only reviewers, al-test-builder)
- v1.2.0 — CI (Azure DevOps PR validation) + org-level instructions
- Later — optional local container to turn RDLC PREVIEW_REQUIRED into VERIFIED

# Changelog — AL Copilot Framework

## [1.0.0] — 2026-08-03 (first team release)
Consolidates internal 2.x iteration into one tested release. All testing fixes folded in.
### Included
- Plan → Implement pipeline: planner + implementer + 5 domain experts.
- 23 skills; 22 templates; 9 per-object syntax references (loaded on demand).
- **Anti-duplicate**: one file = one object; overwrite whole; a mechanical duplicate scanner
  (check-duplicates.ps1) runs in the build gate BEFORE compiling. Prevents AL0264/AL0139.
- **Build gate**: compile to zero errors; never "done" over a red build; fix loop overwrites,
  never appends.
- **AL syntax knowledge**: always-on al-language-fundamentals (var/begin) + on-demand syntax refs.
- **Model unpinned** (cost control). **SETUP split** (al-setup.md protected). **Robust installer**.
- **RDLC layout** skill (offline-validated). **Plan handoff** to al-implementer.
### Pre-release history (reference)
2.0.0 skill split · 2.0.1 plan handoff · 2.1.0 events · 2.1.1 RDLC layout · 2.2.0 SETUP split.
## Roadmap
- v1.1.0 Review & Test gates · v1.2.0 CI + org-level instructions.

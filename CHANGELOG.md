# Changelog — AL Copilot Framework

## [1.0.0] — 2026-08-03 (first team release)
Consolidates internal 2.x iteration into one tested release. All testing fixes folded in.
### Included
- Plan -> Implement pipeline: planner + implementer + 5 domain experts. 23 skills; 22 templates;
  9 per-object syntax references (on demand).
- Anti-duplicate: one file = one object; overwrite whole; mechanical duplicate scanner
  (check-duplicates.ps1) in the build gate. Prevents AL0264/AL0139.
- Report <-> layout linking: report objects DEFINE a deterministic layout reference
  (<AFFIX><ReportName>Layout); the RDLC layout skill reads that exact name/path, checks if the
  .rdl exists, and fills it — only when a picture/description is provided.
- Build gate: compile to zero errors; never "done" over a red build; fix loop overwrites, never appends.
- AL syntax knowledge (var/begin) always-on + on-demand refs. Model unpinned. SETUP split. Robust installer.
### Pre-release history
2.0.0 skill split · 2.0.1 plan handoff · 2.1.0 events · 2.1.1 RDLC layout · 2.2.0 SETUP split.
## Roadmap
- v1.1.0 Review & Test gates · v1.2.0 CI + org-level instructions.

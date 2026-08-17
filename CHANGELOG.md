# Changelog — AL Copilot Framework

## [2.2.0] — 2026-08-17
### Added
- **al-setup.md** — a separate, team-owned SETUP file in .github/. Holds the 5 project settings
  (affix, ID ranges, target version, publisher). The framework NEVER overwrites it.
- **migrate-to-2.2.ps1** — extracts SETUP values from a v2.1.x copilot-instructions.md into the new
  al-setup.md and swaps in the pure conventions file. Values preserved; no re-typing. Verified.
- **SETUP-GUIDE.md** — complete step-by-step user guide: plugin install, per-repo setup, daily loop, updates.
### Changed
- **copilot-instructions.md is now pure conventions** — framework-owned, safe to overwrite on every
  update. The SETUP block moved out to al-setup.md.
- **install-instructions.ps1** copies conventions + 6 scoped files (overwrite), and al-setup.md ONLY
  IF ABSENT — your filled-in settings are never touched.
- **All agents' setup gate** now reads .github/al-setup.md instead of a SETUP block inside conventions.
- **al-plan-handoff** setup gate points at al-setup.md.
### Why
In v2.1.x the SETUP block lived inside copilot-instructions.md, so updating conventions risked
overwriting team settings (handled by preservation logic in update-instructions.ps1). Splitting the
two concerns removes that risk entirely: conventions update like any other file; settings are a
separate, protected file. Instruction updates become trivial.
### Team action
Update the plugin, then run migrate-to-2.2.ps1 once per existing repo (or install-instructions.ps1
for fresh repos). Your al-setup.md values are preserved.

## [2.1.1] — 2026-08-17
al-report-rdlc-layout skill — generate an RDLC layout from a picture/Excel, offline-validated. Report skills 6 → 7.

## [2.1.0] — 2026-08-17
al-extend-events skill — event subscribers as an extension of base behaviour. Skills 21 → 22.

## [2.0.1] — 2026-08-17
al-plan-handoff.instructions.md — built-in /plan hands off to al-implementer.

## [2.0.0] — 2026-08-03
Breaking. Every expert classifies first, then loads one focused skill. Skills 5 → 21.

## [1.1.0] / [1.0.0] — 2026-08-03
Plugin packaging / first release.

## Roadmap
- v3.0.0 — Review & Test gates (al-reviewer + 3 parallel reviewers, al-test-builder, al-upgrade-builder)
- v4.0.0 — CI (Azure DevOps PR validation) + org-level instructions

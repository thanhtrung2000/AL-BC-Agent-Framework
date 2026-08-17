# Changelog — AL Copilot Framework

## [2.1.1] — 2026-08-17
### Added
- **al-report-rdlc-layout skill** on al-report-builder — generates a BC RDLC layout (.rdl) from a
  picture (primary) or an Excel mock-up. Reads the target into a layout map, binds each column to a
  dataset field, fills a validated RDL template (never hand-writes structure), and runs an offline
  validator: (1) XSD schema, (2) field bindings vs the AL dataset, (3) expression whitelist. Returns
  STATUS: PREVIEW_REQUIRED with a single Ctrl+F5 step. Bundles ReportLayout.rdl.template and validate-rdl.ps1.
- New command /al-bc-framework:al-report-layout.
### Changed
- al-report-builder now classifies 7 types (document, list, statistical, processing, validation,
  extension, RDLC layout). The "never fabricate .rdlc" rule stands for the six OBJECT skills; the
  new layout skill is the exception because it works from a source, fills a validated template, and
  validates offline before handing back.
### Why offline-validated instead of "just generate"
RDLC is a large XML doc validated against an XSD, but expressions run on a separate engine. XSD +
binding checks catch the structural and "field not found" failures offline; an expression whitelist
avoids the ones that fail the compiler. Cloud-only cannot test-RUN, so the residual is one preview.
### Team action
Update the plugin; re-run /al-bc-framework:al-framework-setup -Force.
### Upgrade path
Add a local BC container (validation only; cloud dev workflow unchanged) to enable a headless
run-and-capture step, turning PREVIEW_REQUIRED into VERIFIED. Skill is written for that seam.

## [2.1.0] — 2026-08-17
al-extend-events skill on al-extension-builder — event subscribers as an extension of base behaviour.
Skills 21 → 22; agents stay 7.

## [2.0.1] — 2026-08-17
Patch. al-plan-handoff.instructions.md (7th instruction file) so the built-in /plan hands off to al-implementer.

## [2.0.0] — 2026-08-03
Breaking. Every expert classifies first, then loads one focused skill. Skills 5 → 21.

## [1.1.0] / [1.0.0] — 2026-08-03
Plugin packaging / first release.

## Roadmap
- v3.0.0 — Review & Test gates (al-reviewer + 3 parallel reviewers, al-test-builder, al-upgrade-builder)
- v4.0.0 — CI (Azure DevOps PR validation) + org-level instructions

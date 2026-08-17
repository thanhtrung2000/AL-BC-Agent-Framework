# AL Copilot Framework — Complete Setup Guide

The whole flow, step by step, from zero to generating your first AL. Written for
a team member who has never used the framework. Follow it top to bottom.

There are three one-time setups (plugin, repo, settings) and then a daily loop.

---

## The picture — how it fits together

```
YOU (VS Code + Copilot)
   │
   ├─ PLUGIN  (installed once, globally)      ← agents, skills, commands
   │
   └─ YOUR BC PROJECT  (per repo)
        .github/copilot-instructions.md       ← conventions (framework-owned)
        .github/al-setup.md                    ← YOUR settings (you fill in once)
        .github/instructions/                  ← 6 rule sets by object type
        .vscode/settings.json                  ← AL analyzers
        src/                                   ← the AL the agents generate
```

Two things you provide once: **install the plugin**, and **fill in `al-setup.md`**.
Everything else is automatic.

---

## PART A — One-time, per person: install the plugin

You do this once on your machine. It makes the agents available in every repo.

**A1. Check plugins are enabled.**
`Ctrl/Cmd + Shift + P` → *Preferences: Open User Settings (JSON)* → add:
```json
{ "chat.plugins.enabled": true }
```
(If your org has locked this, ask your admin.)

**A2. Install the plugin from your team's repo.**
`Ctrl/Cmd + Shift + P` → **Chat: Install Plugin From Source** → paste:
```
https://github.com/<your-org>/al-bc-framework
```

**A3. Reload.**
`Ctrl/Cmd + Shift + P` → *Developer: Reload Window*.

**A4. Confirm it loaded.**
Open Chat, type `/`. You should see the prefixed commands:
```
/al-bc-framework:al-feature
/al-bc-framework:al-quick-object
/al-bc-framework:al-stat-report
/al-bc-framework:al-report-layout
/al-bc-framework:al-framework-setup
```
The agent dropdown shows **al-planner** and **al-implementer** (the 5 builders are
hidden subagents — that is correct).

> If your team committed `.github/copilot/settings.json` to the repo, you can skip
> A2: just send any chat message and click **Install** on the notification.

---

## PART B — One-time, per BC repo: install the instructions

The plugin ships agents/skills, NOT the instruction files. Those live in each repo.
This costs **zero AI credits** — it is a file copy.

**B1. Open your BC project** (the folder with `app.json`) in VS Code.

**B2. Install the instruction files.** In the VS Code **terminal** (not chat):
```powershell
pwsh <plugin-root>/skills/al-framework-setup/scripts/install-instructions.ps1
```
Find `<plugin-root>` here:
| OS | Path |
|---|---|
| Windows | %APPDATA%\Code\agentPlugins\github.com\<org>\al-bc-framework |
| macOS | ~/Library/Application Support/Code/agentPlugins/github.com/<org>/al-bc-framework |
| Linux | ~/.config/Code/agentPlugins/github.com/<org>/al-bc-framework |

This creates:
```
.github/copilot-instructions.md      conventions (framework-owned)
.github/al-setup.md                  YOUR settings (created blank - fill it next)
.github/instructions/  (6 files)
.vscode/settings.json                (if absent) the 4 AL analyzers
```

> Zero-credit alternative: if a teammate already committed `.github/` to the repo,
> just `git pull` — nothing to install.

---

## PART C — One-time, per BC repo: fill in your settings

**C1. Open `.github/al-setup.md`** and replace the 5 placeholders. Type them by
hand — no AI:
```
AFFIX / PREFIX      : VSA
PRODUCTION ID RANGE : 50000..50099      (from app.json -> idRanges)
TEST ID RANGE       : 50100..50149      (outside the production range)
TARGET BC VERSION   : 26.0              (from app.json -> application)
PUBLISHER           : Contoso           (from app.json -> publisher)
```
The install script printed the values it detected from `app.json` — copy those.

**C2. Verify.** In the terminal:
```powershell
pwsh <plugin-root>/skills/al-framework-setup/scripts/install-instructions.ps1 -VerifyOnly
```
Expect `SETUP_STATUS=OK`. If it lists a placeholder, you missed a value.

**C3. Commit** so the whole team shares it:
```bash
git add .github/ .vscode/settings.json
git commit -m "Add AL Copilot conventions and setup"
git push
```

> ⚠️ Agents refuse to run until `al-setup.md` is complete. That is deliberate —
> a wrong ID range compiles fine and fails AppSourceCop at release.

---

## PART D — The daily loop: generate AL

Now you are set up. Two ways to work.

### D1. A full feature (plan → implement)
```
/al-bc-framework:al-feature
```
Then describe it, e.g. *"vendor spend statistics by quarter"*.

What happens:
1. **al-planner researches** your codebase and **asks clarifying questions.**
   Answer them — this is where design errors get caught cheaply.
2. It drafts a **work-packet table** showing which expert builds what.
3. **You review and approve.** Check the routing (e.g. a base-table field goes to
   the extension builder, not the object builder).
4. Click **Start Implementation** → choose **al-implementer**.
5. The implementer routes each packet to an expert; each expert classifies its
   sub-type and loads one skill.
6. It builds. **You review the diff and write tests** — the framework stops there.

### D2. A single object (skip planning)
```
/al-bc-framework:al-quick-object
```
Pick a type and purpose. Faster for small, self-contained work.

### D3. A report layout from a picture
```
/al-bc-framework:al-report-layout
```
Give it a screenshot (or Excel mock-up) and the report name. It generates a
validated `.rdl`, runs offline checks, and hands back **PREVIEW_REQUIRED**. Then:
```
Ctrl + F5     (publishes + renders once in your cloud sandbox)
```
Because it validated offline, that first preview passes nearly every time.

---

## PART E — Keeping current (occasional)

**E1. Update the plugin** when a new version ships:
`Ctrl/Cmd + Shift + P` → *Extensions: Check for Extension Updates* → Update → reload.

**E2. Update instructions ONLY if the CHANGELOG says conventions changed.**
Most releases touch agents/skills only — the plugin update is enough. When
conventions do change, run (zero credits):
```powershell
pwsh <plugin-root>/skills/al-framework-setup/scripts/install-instructions.ps1
```
This overwrites the framework-owned files but **never touches your `al-setup.md`**
— your affix and ID range are safe. Then `git diff .github/`, commit, push;
teammates `git pull`.

---

## Migrating from v2.1.x (SETUP used to be inside copilot-instructions.md)

If this repo was set up on v2.1.x, run once:
```powershell
pwsh <plugin-root>/skills/al-framework-setup/scripts/migrate-to-2.2.ps1 -Source <plugin-root>/instructions-template
```
It moves your 5 SETUP values into the new `.github/al-setup.md` and swaps in the
pure v2.2.0 conventions. Your values are preserved — no re-typing. Review the
`git diff`, then commit.

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| No commands in the `/` menu | Plugin not installed / `chat.plugins.enabled` off (Part A) |
| Only some agents, or all 7 visible | Re-install; 2 visible + 5 hidden is correct |
| Every run says NEEDS_SETUP | `al-setup.md` has placeholders — finish Part C |
| Agent ignores conventions | Check the response's **References** list includes copilot-instructions.md |
| RDLC preview errors | Paste the BC error back to the agent; it re-validates and fixes |
| Update wiped my settings | You ran the old `-Force` — restore al-setup.md from `git` and re-run without -Force |

Diagnostics: right-click in Chat → **Diagnostics** lists everything loaded.

---

## The 60-second summary

```
ONCE per person:   install plugin (Part A)
ONCE per repo:     install instructions (Part B) + fill al-setup.md + commit (Part C)
DAILY:             /al-bc-framework:al-feature  → approve plan → Start Implementation
                   review diff, write tests
LAYOUTS:           /al-bc-framework:al-report-layout → Ctrl+F5 to preview
UPDATES:           update plugin; re-run install only if conventions changed (al-setup.md is safe)
```

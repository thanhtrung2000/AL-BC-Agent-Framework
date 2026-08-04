---
name: al-feature
description: Plan and implement a complete AL feature end to end. Starts with the planner, then hands off to the implementer.
argument-hint: [feature description]
agent: al-planner
---

Plan the following Business Central feature.

**Feature:** ${input:feature:Describe what you need, e.g. "vendor spend statistics by quarter"}

Follow the four-phase workflow:

1. **Discovery** — search the codebase for existing objects this will touch,
   patterns already in use that I should follow, and object IDs already
   allocated in `app.json`.
2. **Alignment** — ask me any clarifying questions that would change the design.
   Ask them all together in one message, not one at a time.
3. **Design** — produce the plan in the standard format, including the work
   packet table with expert routing.
4. **Refinement** — wait for my approval before handing off.

Read conventions from `.github/copilot-instructions.md` in the workspace. If
that file is missing or its SETUP block still has `<...>` placeholders, stop and
tell me to run `/al-bc-framework:al-framework-setup`.

Do not write any code. When I approve the plan, use the **Start Implementation**
handoff button.

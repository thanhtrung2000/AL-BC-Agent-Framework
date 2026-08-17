---
name: al-feature
description: Plan and implement a complete AL feature end to end. Starts with the planner, then hands off to the implementer.
argument-hint: [feature description]
agent: al-planner
---
Plan the following Business Central feature.
**Feature:** ${input:feature:Describe what you need}
Four-phase workflow (Discovery, Alignment, Design, Refinement). Read conventions from .github/copilot-instructions.md. If SETUP has placeholders, stop and tell me to run /al-bc-framework:al-framework-setup. On approval, use Start Implementation.

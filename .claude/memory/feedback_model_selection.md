---
name: Model selection: Opus for planning, Sonnet for implementation
description: Which Claude model to use for planning vs. coding work in this project
type: feedback
---

Use **Opus** for planning and **Sonnet** for code implementation.

**Why:** Opus has stronger reasoning for architecture, design, and multi-step planning. Sonnet is faster and cheaper for executing well-defined coding tasks where the design is already settled.

**How to apply:**
- Planning, architecture decisions, design reviews, breaking down complex tasks → Opus
- Writing code, applying edits, running tests, executing a defined plan → Sonnet
- If the user hasn't explicitly switched models, suggest a switch when transitioning between phases (e.g. "plan looks good — switch to Sonnet for implementation").

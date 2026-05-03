---
name: Memory system rules
description: Guidelines for what to store in memory and how to use it across sessions
type: feedback
---

**Store only information useful across multiple interactions.**

General principles:
- Prefer long-term, stable facts over temporary data
- Do not store one-time requests or transient context
- Do not store full user messages
- Keep memory structured and minimal
- Avoid duplication
- Update existing values instead of creating new ones when possible

Extraction rules:
- Only store explicitly stated facts
- Do not guess or infer
- Normalize values when possible (e.g. numbers, short phrases)

Usage rules:
- Memory must be used to improve future responses
- Memory should act as defaults, not strict constraints
- Do not blindly trust memory if user provides new input

Safety:
- Do not store sensitive or unnecessary personal data
- Do not store secrets, credentials, or private tokens

**Why:** A clean, minimal memory system avoids noise and keeps decision-making clear across sessions.

**How to apply:** Before saving any memory, ask: "Is this a stable fact useful in multiple sessions?" If not, don't save it. Prefer updating existing memories over duplicating them.

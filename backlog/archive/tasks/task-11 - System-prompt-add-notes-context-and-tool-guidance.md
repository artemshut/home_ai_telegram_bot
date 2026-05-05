---
id: task-11
title: 'System prompt: add notes context and tool guidance'
status: To Do
assignee: []
created_date: '2026-05-05 14:26'
labels:
  - notes
dependencies: []
priority: medium
---

## Description

Update Ai::Prompts::SystemPrompt to include a notes section so Claude knows about existing notes and understands when to use create_note, list_notes, edit_note, and delete_note tools. Also add note-specific instructions: always ask for visibility and category via the tool rather than free-form text.

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 SystemPrompt#notes_section returns a string listing confirmed notes count + categories available for the household (or 'No notes yet' / 'No categories yet')
- [ ] #2 notes_section is included in the assembled prompt via parts array (like household_section, expenses_section, etc.)
- [ ] #3 Prompt includes instruction: 'When creating a note, call create_note with the content. The bot will handle asking for visibility and category via inline buttons — do not ask the user yourself.'
- [ ] #4 Prompt includes instruction: 'When listing notes, always call list_notes — never answer from memory.'
- [ ] #5 Prompt includes instruction: 'When deleting or editing a note by description, call list_notes first to resolve the note_id, then call delete_note or edit_note.'
- [ ] #6 Existing prompt structure and formatting conventions (Telegram Markdown, section order) are preserved
<!-- AC:END -->

---
id: task-12.9
title: 'System prompt: add notes context and tool guidance'
status: Done
assignee:
  - '@claude'
created_date: '2026-05-05 14:43'
updated_date: '2026-05-05 15:05'
labels:
  - notes
dependencies: []
parent_task_id: task-12
priority: medium
---

## Description

Update Ai::Prompts::SystemPrompt to include a notes section and instructions for when/how to use the four note tools.

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 SystemPrompt#notes_section returns confirmed note count and available categories for the household (or 'No notes yet' / 'No categories yet')
- [x] #2 notes_section included in prompt parts array alongside existing sections
- [x] #3 Instruction added: 'When creating a note, call create_note with the content — the bot handles visibility and category via inline buttons, do not ask the user yourself'
- [x] #4 Instruction added: 'When listing notes, always call list_notes — never answer from memory'
- [x] #5 Instruction added: 'When deleting or editing a note by description, call list_notes first to resolve the note_id, then call delete_note or edit_note'
- [x] #6 Existing prompt formatting conventions preserved
<!-- AC:END -->


## Implementation Notes

Added notes_section to SystemPrompt (confirmed note count + category list). Added three note-tool instructions to the prompt's instruction block. notes_section included in parts array between calendar_section and the blank line separator.

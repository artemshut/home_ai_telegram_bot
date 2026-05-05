---
id: task-10
title: delete_note tool — ownership-checked deletion
status: To Do
assignee: []
created_date: '2026-05-05 14:26'
labels:
  - notes
dependencies: []
priority: medium
---

## Description

Implement Ai::Tools::DeleteNoteTool. Called by Claude when a user explicitly asks to delete a note by describing it (Claude resolves the note_id from context via list_notes first). Only the note owner may delete.

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Tool is registered under name 'delete_note'
- [ ] #2 Schema accepts: note_id (required integer)
- [ ] #3 Verifies note belongs to context.telegram_user; returns ToolResult.err('Not authorised') otherwise
- [ ] #4 Destroys the note record
- [ ] #5 Returns success: 'Note deleted.'
- [ ] #6 Returns ToolResult.err('Note not found') if note_id does not exist or does not belong to household
- [ ] #7 ToolCall record is persisted
<!-- AC:END -->

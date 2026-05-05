---
id: task-12.8
title: delete_note tool — ownership-checked deletion
status: Done
assignee:
  - '@claude'
created_date: '2026-05-05 14:43'
updated_date: '2026-05-05 15:04'
labels:
  - notes
dependencies: []
parent_task_id: task-12
priority: medium
---

## Description

Implement Ai::Tools::DeleteNoteTool. Called by Claude when the user asks to delete a note by description (Claude resolves note_id via list_notes first). Only the note owner may delete.

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Tool registered under name 'delete_note'
- [x] #2 Schema accepts: note_id (required integer)
- [x] #3 Verifies note.telegram_user_id == context.telegram_user.id; returns ToolResult.err('Not authorised') otherwise
- [x] #4 Destroys note; returns 'Note deleted.'
- [x] #5 Returns ToolResult.err('Note not found') if note_id absent or not in household; ToolCall record persisted
<!-- AC:END -->


## Implementation Notes

Implemented DeleteNoteTool. Scopes lookup to household to prevent cross-household deletion. Checks ownership before destroying. Registered in tool_registry.rb.

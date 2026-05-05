---
id: task-12.7
title: 'edit_note tool — update content, category, or visibility'
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

Implement Ai::Tools::EditNoteTool. Called by Claude or the inline-button edit flow to update a note. Only the note owner may edit.

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Tool registered under name 'edit_note'
- [x] #2 Schema accepts: note_id (required integer), content (optional string), category_name (optional string), visibility (optional 'private'|'public'); at least one optional field must be present
- [x] #3 Verifies note.telegram_user_id == context.telegram_user.id; returns ToolResult.err('Not authorised') otherwise
- [x] #4 category_name given: finds-or-creates NoteCategory scoped to household
- [x] #5 Updates only provided fields; updated_at refreshed by ActiveRecord
- [x] #6 Returns success message summarising what changed; ToolCall record persisted
<!-- AC:END -->


## Implementation Notes

Implemented EditNoteTool. Validates at least one field present, checks ownership, finds-or-creates category if given, updates only provided fields. Returns human-readable summary of changes. Registered in tool_registry.rb.

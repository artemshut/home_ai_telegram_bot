---
id: task-9
title: 'edit_note tool — update content, category, or visibility'
status: To Do
assignee: []
created_date: '2026-05-05 14:25'
labels:
  - notes
dependencies: []
priority: medium
---

## Description

Implement Ai::Tools::EditNoteTool. Called by Claude when the user has confirmed an edit via the inline button flow and provided new content/category/visibility. Only the note owner may edit a note.

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Tool is registered under name 'edit_note'
- [ ] #2 Schema accepts: note_id (required integer), content (optional string), category_name (optional string), visibility (optional 'private'|'public')
- [ ] #3 At least one of content, category_name, or visibility must be present; returns ToolResult.err if none supplied
- [ ] #4 Verifies note belongs to context.telegram_user; returns ToolResult.err('Not authorised') otherwise
- [ ] #5 If category_name given: finds-or-creates NoteCategory scoped to household
- [ ] #6 Updates only the provided fields; untouched fields remain unchanged
- [ ] #7 updated_at is refreshed automatically by ActiveRecord
- [ ] #8 Returns success message summarising what changed (e.g. 'Note updated: content changed, category → Recipes')
- [ ] #9 ToolCall record is persisted
<!-- AC:END -->

---
id: task-12.5
title: list_notes tool with privacy filtering
status: Done
assignee:
  - '@claude'
created_date: '2026-05-05 14:42'
updated_date: '2026-05-05 14:58'
labels:
  - notes
dependencies: []
parent_task_id: task-12
priority: high
---

## Description

Implement Ai::Tools::ListNotesTool. Returns confirmed notes visible to the requesting user: their own private notes plus all public notes in the household. Never returns another user's private notes.

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Tool registered under name 'list_notes'
- [x] #2 Schema accepts: query (optional string, keyword search in content), category_name (optional string), limit (optional integer, default 20)
- [x] #3 Privacy scope: Note.where(household:, status: 'confirmed').where('visibility = ? OR telegram_user_id = ?', 'public', current_user.id)
- [x] #4 query param: filters by content ILIKE '%query%'; category_name param: joins note_categories, filters by name case-insensitively
- [x] #5 Returns array of note objects: id, content, visibility, category_name, owner_display_name, created_at (day/month/year)
- [x] #6 Returns 'No notes found.' when result is empty; ToolCall record persisted
<!-- AC:END -->


## Implementation Notes

Implemented ListNotesTool using the visible_to scope (public OR owned by user). Supports query (ILIKE), category_name (case-insensitive join), and limit. Returns JSON array with id/content/visibility/category/owner/date. Registered in tool_registry.rb.

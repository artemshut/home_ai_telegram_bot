---
id: task-7
title: list_notes tool with privacy filtering
status: To Do
assignee: []
created_date: '2026-05-05 14:25'
labels:
  - notes
dependencies: []
priority: high
---

## Description

Implement Ai::Tools::ListNotesTool. Returns confirmed notes visible to the requesting user: their own private notes plus all public notes in the household. Never returns another user's private notes.

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Tool is registered in ToolRegistry under name 'list_notes'
- [ ] #2 Schema accepts: query (optional string for keyword search in content), category_name (optional string to filter by category), limit (optional integer, default 20)
- [ ] #3 Query scope: Note.where(household: household, status: 'confirmed').where('visibility = ? OR telegram_user_id = ?', 'public', current_user.id)
- [ ] #4 If query param present: filters by content ILIKE '%query%'
- [ ] #5 If category_name param present: joins note_categories and filters by name (case-insensitive)
- [ ] #6 Returns structured result: array of note objects each with id, content, visibility, category_name, owner_display_name, created_at formatted as day/month/year
- [ ] #7 Returns a user-friendly message when no notes match ('No notes found.')
- [ ] #8 ToolCall record is persisted
<!-- AC:END -->

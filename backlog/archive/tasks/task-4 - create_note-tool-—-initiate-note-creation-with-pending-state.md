---
id: task-4
title: create_note tool — initiate note creation with pending state
status: To Do
assignee: []
created_date: '2026-05-05 14:25'
labels:
  - notes
dependencies: []
priority: high
---

## Description

Implement the Ai::Tools::CreateNoteTool. When Claude calls this tool, it creates a Note in 'pending' status and returns a structured response that tells the bot what to ask the user next. The tool handles three cases: (1) no visibility → save pending note, return visibility question; (2) visibility present but no category → save pending note with visibility, return available categories; (3) all info present → save confirmed note immediately.

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Tool is registered in ToolRegistry under name 'create_note'
- [ ] #2 Schema accepts: content (required string), visibility (optional: 'private'|'public'), category_name (optional string)
- [ ] #3 When visibility is absent: creates Note with status='pending', returns JSON with pending_note_id and instruction for bot to ask visibility
- [ ] #4 When visibility present but category_name absent: creates/updates pending Note with visibility, returns pending_note_id plus list of existing NoteCategory names for the household
- [ ] #5 When both visibility and category_name present: finds-or-creates NoteCategory, creates Note with status='confirmed', returns success message with note id
- [ ] #6 ToolCall record is persisted for every execution
- [ ] #7 Tool returns ToolResult.err with user-friendly message on any failure (missing household, validation error)
<!-- AC:END -->

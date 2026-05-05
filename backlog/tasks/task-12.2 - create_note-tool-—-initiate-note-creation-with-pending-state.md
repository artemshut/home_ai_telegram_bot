---
id: task-12.2
title: create_note tool — initiate note creation with pending state
status: Done
assignee:
  - '@claude'
created_date: '2026-05-05 14:42'
updated_date: '2026-05-05 14:51'
labels:
  - notes
dependencies: []
parent_task_id: task-12
priority: high
---

## Description

Implement Ai::Tools::CreateNoteTool. Creates a Note in 'pending' status and returns a structured response telling the bot what to ask the user next. Three cases: (1) no visibility → save pending note, return visibility question; (2) visibility present but no category → save pending note, return available categories; (3) all info present → save confirmed note immediately.

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Tool registered in ToolRegistry under name 'create_note'
- [x] #2 Schema accepts: content (required string), visibility (optional 'private'|'public'), category_name (optional string)
- [x] #3 Visibility absent: creates Note with status='pending', returns pending_note_id and instruction for bot to ask visibility
- [x] #4 Visibility present, category absent: creates/updates pending Note, returns pending_note_id plus list of existing NoteCategory names for the household
- [x] #5 Both present: finds-or-creates NoteCategory, creates Note with status='confirmed', returns success message with note id
- [x] #6 ToolCall record is persisted; ToolResult.err returned with user-friendly message on failure
<!-- AC:END -->


## Implementation Plan

1. Look at an existing tool for patterns (log_expense_tool)
2. Write CreateNoteTool with the three-case logic
3. Register in ToolRegistry
4. Verify with rails runner


## Implementation Notes

Implemented CreateNoteTool with three-case logic: (1) no visibility → pending note + awaiting_visibility flag, (2) visibility only → pending note + category list, (3) both → confirmed note immediately. Added last_pending_note to ToolContext and AiRouter. Added MakeNoteVisibilityNullable migration so nil visibility distinguishes 'not yet chosen' from explicit 'private'. Registered in tool_registry.rb.

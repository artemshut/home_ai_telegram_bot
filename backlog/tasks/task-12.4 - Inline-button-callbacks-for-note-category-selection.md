---
id: task-12.4
title: Inline button callbacks for note category selection
status: Done
assignee:
  - '@claude'
created_date: '2026-05-05 14:42'
updated_date: '2026-05-05 14:57'
labels:
  - notes
dependencies: []
parent_task_id: task-12
priority: high
---

## Description

Extend CallbackRouter and KeyboardBuilder for category selection during note creation or editing. Keyboard shows existing categories plus a 'New category' button. Selecting a category finalises the pending note; 'New category' prompts a plain-text reply which is then treated as the new category name.

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 KeyboardBuilder#note_category_choice(note, categories) returns inline_keyboard: one button per NoteCategory (callback_data: 'note_category:<cat_id>:<note_id>') plus {text: '+ New category', callback_data: 'note_new_category:<note_id>'}
- [x] #2 CallbackRouter /\Anote_category:(\d+):(\d+)\z/: sets note_category, status='confirmed', saves, sends confirmation message
- [x] #3 CallbackRouter /\Anote_new_category:(\d+)\z/: edits message asking user to type a category name
- [x] #4 WebhookHandler detects user has a pending note awaiting category; treats their next plain-text message as the category name, finds-or-creates NoteCategory, confirms note, replies with confirmation
- [x] #5 Confirmation message includes: content snippet, visibility label, category name, creation timestamp
<!-- AC:END -->


## Implementation Plan

1. Add note_category and note_new_category callbacks to CallbackRouter
2. Add pending-note-awaiting-category detection in ProcessTelegramUpdateJob (plain-text intercept)
3. Extract note_saved_text helper for reuse


## Implementation Notes

Added assign_note_category and prompt_new_category handlers to CallbackRouter. Added pending/confirmed/awaiting_category/visible_to scopes to Note model. Added handle_pending_note_input intercept in ProcessTelegramUpdateJob (checks for pending note awaiting typed category before routing to Claude). note_edit and note_delete callbacks also added here (used by task-12.6).

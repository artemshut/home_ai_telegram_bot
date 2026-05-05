---
id: task-12.3
title: Inline button callbacks for note visibility selection
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

Extend CallbackRouter and KeyboardBuilder for the visibility-selection step. Bot sends Personal/Public buttons after create_note returns a pending note. Callback updates the pending note and either confirms it or proceeds to category selection.

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 KeyboardBuilder#note_visibility_choice(note) returns inline_keyboard: [{text: 'Personal', callback_data: 'note_visibility:private:<id>'}, {text: 'Public', callback_data: 'note_visibility:public:<id>'}]
- [x] #2 CallbackRouter handles /\Anote_visibility:(private|public):(\d+)\z/; finds pending Note, sets visibility
- [x] #3 If note_category_id already set: sets status='confirmed', saves, sends confirmation message
- [x] #4 If no category and household has NoteCategory records: edits message to show category selection keyboard
- [x] #5 If no category and household has NO NoteCategory records: edits message asking user to type a category name
- [x] #6 BotClient#answer_callback_query called; note not found or not pending answered with error message
<!-- AC:END -->


## Implementation Plan

1. Add note_visibility_choice to KeyboardBuilder
2. Add note_category_choice to KeyboardBuilder (needed by visibility callback)
3. Handle note_visibility callback in CallbackRouter
4. Wire visibility keyboard sending in ProcessTelegramUpdateJob


## Implementation Notes

Added note_visibility_choice, note_category_choice, note_actions to KeyboardBuilder. Added set_note_visibility handler to CallbackRouter (3 branches: confirm, show category keyboard, ask for typed category). Wired pending note keyboard dispatch in ProcessTelegramUpdateJob.

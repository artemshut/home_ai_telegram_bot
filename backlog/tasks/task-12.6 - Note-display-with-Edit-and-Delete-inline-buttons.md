---
id: task-12.6
title: Note display with Edit and Delete inline buttons
status: Done
assignee:
  - '@claude'
created_date: '2026-05-05 14:43'
updated_date: '2026-05-05 15:03'
labels:
  - notes
dependencies: []
parent_task_id: task-12
priority: medium
---

## Description

When the bot displays a note, attach Edit and Delete inline buttons for the note owner. Other users see public notes without action buttons. CallbackRouter handles delete immediately; edit puts the user in a pending-edit state for their next message.

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 KeyboardBuilder#note_actions(note, current_user) returns inline_keyboard with Edit + Delete buttons only when note.telegram_user_id == current_user.id; otherwise nil
- [x] #2 MessageFormatter#format_note(note) renders: category, visibility icon (🔒 Personal / 🌐 Public), content, timestamp in Telegram Markdown
- [x] #3 CallbackRouter 'note_delete:<id>': verifies ownership, destroys note, edits message to 'Note deleted.'
- [x] #4 CallbackRouter 'note_edit:<id>': verifies ownership, edits message to show current content and instructs user to send replacement; stores note_id as pending edit
- [x] #5 Next plain-text message from that user while pending edit is active: calls edit_note tool or updates note directly, replies with confirmation
- [x] #6 Ownership mismatch: callback answered with 'Not authorised'
<!-- AC:END -->


## Implementation Plan

1. Add format_note to MessageFormatter
2. KeyboardBuilder#note_actions already done
3. note_delete and note_edit callbacks already in CallbackRouter
4. Add pending_edit column to notes via migration
5. Set pending_edit=true in prompt_note_edit callback
6. Add handle_pending_note_edit intercept in job


## Implementation Notes

Added format_note to MessageFormatter (Telegram Markdown with category, visibility icon, timestamp). note_actions/note_delete/note_edit callbacks were already in CallbackRouter. Added pending_edit_note_id to telegram_users (migration). prompt_note_edit now sets that field. handle_pending_note_edit intercept in job clears the field and updates note content.

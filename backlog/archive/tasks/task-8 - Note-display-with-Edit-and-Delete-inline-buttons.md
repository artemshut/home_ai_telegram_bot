---
id: task-8
title: Note display with Edit and Delete inline buttons
status: To Do
assignee: []
created_date: '2026-05-05 14:25'
labels:
  - notes
dependencies: []
priority: medium
---

## Description

When the bot displays a note (via list_notes or after creation), each note message includes two inline buttons: Edit and Delete. Extend KeyboardBuilder and CallbackRouter accordingly. Only the note owner may see or use Edit/Delete — other users' public notes are shown without action buttons.

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 KeyboardBuilder#note_actions(note, current_telegram_user) returns inline_keyboard with Edit and Delete buttons only when note.telegram_user_id == current_telegram_user.id; otherwise returns nil (no keyboard)
- [ ] #2 Edit button: {text: 'Edit', callback_data: 'note_edit:<note_id>'}
- [ ] #3 Delete button: {text: 'Delete', callback_data: 'note_delete:<note_id>'}
- [ ] #4 CallbackRouter handles 'note_delete:<note_id>': verifies ownership, destroys note, edits message to 'Note deleted.'
- [ ] #5 CallbackRouter handles 'note_edit:<note_id>': verifies ownership, edits message to show current content and asks user to send updated content; stores note_id so next plain-text message from this user is treated as the replacement content (pending edit state)
- [ ] #6 MessageFormatter#format_note(note) renders: category label, visibility label (🔒 Personal / 🌐 Public), content, and creation timestamp in Telegram Markdown
- [ ] #7 Ownership mismatch (e.g. stale callback from another session): callback answered with 'Not authorised'
<!-- AC:END -->

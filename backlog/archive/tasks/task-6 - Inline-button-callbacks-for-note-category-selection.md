---
id: task-6
title: Inline button callbacks for note category selection
status: To Do
assignee: []
created_date: '2026-05-05 14:25'
labels:
  - notes
dependencies: []
priority: high
---

## Description

Extend CallbackRouter and KeyboardBuilder to handle category selection during note creation or editing. The keyboard shows existing NoteCategory buttons plus a 'New category' button. Selecting an existing category finalizes the pending note; selecting 'New category' asks the user to type a name. When a plain-text reply is received while a pending-note context exists, it is treated as the new category name.

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 KeyboardBuilder#note_category_choice(note, categories) returns inline_keyboard: one button per NoteCategory ({text: name, callback_data: 'note_category:<category_id>:<note_id>'}), plus a final button {text: '+ New category', callback_data: 'note_new_category:<note_id>'}
- [ ] #2 CallbackRouter handles pattern /\Anote_category:(\d+):(\d+)\z/ — finds category and pending note, sets note_category, sets status='confirmed', saves, sends confirmation message
- [ ] #3 CallbackRouter handles pattern /\Anote_new_category:(\d+)\z/ — edits message to ask user to type a category name; stores pending note id in message text or relies on WebhookHandler to detect next plain-text message as category input
- [ ] #4 WebhookHandler (or ProcessTelegramUpdateJob) detects when a user has a pending note with no category and their next plain-text message is used as the new category name: finds-or-creates NoteCategory, assigns it, sets note status='confirmed', replies with confirmation
- [ ] #5 Confirmation message includes: note content snippet, visibility label, category name, and creation timestamp
- [ ] #6 BotClient#answer_callback_query is called for all callback types
<!-- AC:END -->

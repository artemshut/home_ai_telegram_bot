---
id: task-5
title: Inline button callbacks for note visibility selection
status: To Do
assignee: []
created_date: '2026-05-05 14:25'
labels:
  - notes
dependencies: []
priority: high
---

## Description

Extend CallbackRouter and KeyboardBuilder to handle the visibility-selection step of note creation. When a pending note is waiting for visibility, the bot sends inline buttons 'Personal' / 'Public'. The callback updates the pending note and either confirms it (if category was already known) or proceeds to ask for category.

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 KeyboardBuilder#note_visibility_choice(note) returns inline_keyboard with two buttons: {text: 'Personal', callback_data: 'note_visibility:private:<note_id>'} and {text: 'Public', callback_data: 'note_visibility:public:<note_id>'}
- [ ] #2 CallbackRouter handles pattern /\Anote_visibility:(private|public):(\d+)\z/
- [ ] #3 Callback finds the pending Note by id; if not found or not pending, answers with 'Note not found or already saved'
- [ ] #4 Sets note.visibility to the chosen value
- [ ] #5 If note.note_category_id is already set: sets status='confirmed', saves, sends confirmation message
- [ ] #6 If note has no category and household has NoteCategory records: edits message to show category selection keyboard (see task for category callbacks)
- [ ] #7 If note has no category and household has NO NoteCategory records: edits message to ask user to type a category name as a plain text reply
- [ ] #8 BotClient#answer_callback_query is called to dismiss the spinner
<!-- AC:END -->

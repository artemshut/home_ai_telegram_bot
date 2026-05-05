---
id: task-12.1
title: Note and NoteCategory models with migrations
status: Done
assignee:
  - '@claude'
created_date: '2026-05-05 14:42'
updated_date: '2026-05-05 14:46'
labels:
  - notes
dependencies: []
parent_task_id: task-12
priority: high
---

## Description

Create the database schema and ActiveRecord models for the Notes feature. Notes belong to a telegram_user and household, have content, visibility (private/public), a status (pending/confirmed — pending is used during multi-step creation flow), and a category. NoteCategory is shared across the household.

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Migration creates note_categories table: id, name (string, not null, unique per household), household_id (FK), timestamps
- [x] #2 Migration creates notes table: id, content (text, not null), visibility (string, not null, default 'private'), status (string, not null, default 'pending'), telegram_user_id (FK), household_id (FK), note_category_id (FK nullable), timestamps
- [x] #3 Note model: belongs_to :telegram_user, :household, :note_category (optional); validates content presence; validates visibility inclusion in %w[private public]; validates status inclusion in %w[pending confirmed]
- [x] #4 NoteCategory model: belongs_to :household; validates name presence and uniqueness scoped to household_id; has_many :notes
- [x] #5 Household has_many :notes and has_many :note_categories; TelegramUser has_many :notes
- [x] #6 rails db:migrate runs without errors
<!-- AC:END -->


## Implementation Plan

1. Generate migration for note_categories
2. Generate migration for notes
3. Write NoteCategory model
4. Write Note model
5. Add associations to Household and TelegramUser
6. Run migrations


## Implementation Notes

Created migrations for note_categories (with unique index on household_id+name) and notes (nullable note_category_id, defaults for visibility/status). Models: Note and NoteCategory with validations. Added has_many associations to Household and TelegramUser.

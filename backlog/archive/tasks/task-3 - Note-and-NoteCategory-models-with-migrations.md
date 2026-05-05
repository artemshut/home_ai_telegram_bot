---
id: task-3
title: Note and NoteCategory models with migrations
status: To Do
assignee: []
created_date: '2026-05-05 14:25'
labels:
  - notes
dependencies: []
priority: high
---

## Description

Create the database schema and ActiveRecord models for the Notes feature. Notes belong to a telegram_user and household, have content, visibility (private/public), a status (pending/confirmed — pending is used during multi-step creation flow), and a category. NoteCategory is shared across the household.

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Migration creates note_categories table: id, name (string, not null, unique per household), household_id (FK), timestamps
- [ ] #2 Migration creates notes table: id, content (text, not null), visibility (string, not null, default 'private'), status (string, not null, default 'pending'), telegram_user_id (FK), household_id (FK), note_category_id (FK nullable), timestamps
- [ ] #3 Note model: belongs_to :telegram_user, :household, :note_category (optional); validates content presence; validates visibility inclusion in %w[private public]; validates status inclusion in %w[pending confirmed]
- [ ] #4 NoteCategory model: belongs_to :household; validates name presence and uniqueness scoped to household_id; has_many :notes
- [ ] #5 Household has_many :notes and has_many :note_categories
- [ ] #6 TelegramUser has_many :notes
- [ ] #7 rails db:migrate runs without errors
<!-- AC:END -->

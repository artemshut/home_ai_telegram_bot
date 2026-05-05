---
id: task-1.3
title: Add format_daily_digest to MessageFormatter
status: To Do
assignee: []
created_date: '2026-05-05 09:58'
labels: []
dependencies: []
parent_task_id: task-1
---

## Description

Add public method format_daily_digest(date:, events:, meals:) to Telegram::MessageFormatter. Receives pre-fetched AR collections (no DB queries inside). Formats a morning message with calendar events and meals sections.

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Both sections present with correct data when populated
- [ ] #2 Shows 'No events today.' when events are empty
- [ ] #3 Shows 'No meals planned today.' when meals are empty
- [ ] #4 All-day events show 'all day' instead of a time
- [ ] #5 Meals sorted breakfast → lunch → dinner
- [ ] #6 Uses Telegram single-asterisk Markdown only
- [ ] #7 Tests cover all cases including empty sections and all-day events
<!-- AC:END -->

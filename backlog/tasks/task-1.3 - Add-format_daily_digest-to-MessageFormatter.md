---
id: task-1.3
title: Add format_daily_digest to MessageFormatter
status: Done
assignee:
  - '@claude'
created_date: '2026-05-05 09:58'
updated_date: '2026-05-05 10:08'
labels: []
dependencies: []
parent_task_id: task-1
---

## Description

Add public method format_daily_digest(date:, events:, meals:) to Telegram::MessageFormatter. Receives pre-fetched AR collections (no DB queries inside). Formats a morning message with calendar events and meals sections.

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Both sections present with correct data when populated
- [x] #2 Shows 'No events today.' when events are empty
- [x] #3 Shows 'No meals planned today.' when meals are empty
- [x] #4 All-day events show 'all day' instead of a time
- [x] #5 Meals sorted breakfast → lunch → dinner
- [x] #6 Uses Telegram single-asterisk Markdown only
- [x] #7 Tests cover all cases including empty sections and all-day events
<!-- AC:END -->


## Implementation Plan

1. Add format_daily_digest(date:, events:, meals:) to MessageFormatter
   - Header line with date using *bold* Markdown
   - Events section: each event shows HH:MM or "all day" (via all_day boolean)
   - Meals section: sort by MEAL_TYPES index (breakfast→lunch→dinner), show "meal_type: dish.name"
   - Empty fallbacks for both sections
   - No DB queries — trust caller to eager-load dish on meals
2. Create test/services/telegram/message_formatter_test.rb
   - Both sections populated
   - Empty events section
   - Empty meals section
   - All-day event shows "all day"
   - Meals sorted correctly


## Implementation Notes

Added format_daily_digest to MessageFormatter. Header uses *bold* Markdown. Events show HH:MM or 'all day' based on the all_day boolean. Meals are sorted via MEAL_TYPES.index. Empty fallbacks for both sections. Created test/services/telegram/message_formatter_test.rb with 7 tests covering all ACs. All pass.

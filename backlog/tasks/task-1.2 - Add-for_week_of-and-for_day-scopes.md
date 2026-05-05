---
id: task-1.2
title: Add for_week_of and for_day scopes
status: Done
assignee:
  - '@claude'
created_date: '2026-05-05 09:58'
updated_date: '2026-05-05 10:05'
labels: []
dependencies: []
parent_task_id: task-1
---

## Description

Add `for_week_of(date)` scope to WeeklyMenu (finds menu whose week_start_date covers the given date) and `for_day(day)` scope to Meal (filters by day_of_week string).

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 for_week_of(Date.new(2026,5,5)) matches week_start_date == 2026-05-04 (Monday)
- [x] #2 for_week_of returns empty when no menu covers the week
- [x] #3 for_day('tuesday') filters meals to Tuesday only
- [x] #4 Tests cover both scopes
<!-- AC:END -->


## Implementation Plan

1. Add scope :for_week_of to WeeklyMenu using date.beginning_of_week
2. Add scope :for_day to Meal using where(day_of_week: day)
3. Add tests to weekly_menu_test.rb: matches correct week, returns empty when no match
4. Add tests to meal_test.rb: filters by day, excludes other days


## Implementation Notes

Added scope :for_week_of to WeeklyMenu using date.beginning_of_week (Rails defaults to Monday). Added scope :for_day to Meal using where(day_of_week: day). Added 2 tests for each scope. All 19 model tests pass.

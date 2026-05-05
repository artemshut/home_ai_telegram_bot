---
id: task-1.2
title: Add for_week_of and for_day scopes
status: To Do
assignee: []
created_date: '2026-05-05 09:58'
labels: []
dependencies: []
parent_task_id: task-1
---

## Description

Add `for_week_of(date)` scope to WeeklyMenu (finds menu whose week_start_date covers the given date) and `for_day(day)` scope to Meal (filters by day_of_week string).

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 for_week_of(Date.new(2026,5,5)) matches week_start_date == 2026-05-04 (Monday)
- [ ] #2 for_week_of returns empty when no menu covers the week
- [ ] #3 for_day('tuesday') filters meals to Tuesday only
- [ ] #4 Tests cover both scopes
<!-- AC:END -->

---
id: task-1.1
title: Add today scope to CalendarEvent
status: Done
assignee:
  - '@claude'
created_date: '2026-05-05 09:58'
updated_date: '2026-05-05 10:03'
labels: []
dependencies: []
parent_task_id: task-1
---

## Description

Add a `today` scope to CalendarEvent that returns events with start_at within Date.current.all_day (Warsaw timezone). Chainable with existing `active` scope.

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Scope returns confirmed/synced events whose start_at falls within today's day boundaries in Warsaw time
- [x] #2 Excludes events on other dates
- [x] #3 Excludes pending and cancelled events when chained with .active
- [x] #4 Existing scope tests pass unchanged
<!-- AC:END -->


## Implementation Plan

1. Add `scope :today` to CalendarEvent model using `Date.current.all_day` range on `start_at`
2. Add 4 tests to test/models/calendar_event_test.rb:
   - today scope returns events whose start_at falls within today (Warsaw time)
   - today scope excludes events on other dates
   - active.today excludes pending and cancelled events
   - existing tests still pass (no change needed, just run them)


## Implementation Notes

Added  to CalendarEvent using  on . Rails time_zone is Warsaw so Date.current already reflects the correct timezone. Added 3 new tests covering: events within today, exclusion of other dates, and active.today chaining. All 11 model tests pass.

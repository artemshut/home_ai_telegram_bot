---
id: task-1.5
title: Wire recurring schedule in config/recurring.yml
status: Done
assignee:
  - '@claude'
created_date: '2026-05-05 09:58'
updated_date: '2026-05-05 10:20'
labels: []
dependencies:
  - task-1.4
parent_task_id: task-1
---

## Description

Add SendDailyDigestJob to config/recurring.yml under both production and development sections using Fugit TZ-aware cron: "TZ=Europe/Warsaw 0 8 * * *". Use class: key (not command:) so Solid Queue calls perform_later with no args.

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Job fires at 08:00 Warsaw time daily in production
- [x] #2 Same entry present in development for local testing
- [x] #3 Existing clear_solid_queue_finished_jobs task unchanged
- [ ] #4 After deploy: SolidQueue::RecurringTask.find_by(key: 'send_daily_digest') exists in console
<!-- AC:END -->


## Implementation Plan

1. Add send_daily_digest entry to existing production section in config/recurring.yml
   - class: SendDailyDigestJob, schedule: "TZ=Europe/Warsaw 0 8 * * *"
2. Add development section with the same entry


## Implementation Notes

Added send_daily_digest entry to production and development sections of config/recurring.yml. Uses TZ=Europe/Warsaw cron expression for 08:00 Warsaw time. Uses class: key so Solid Queue calls perform_later. Existing clear_solid_queue_finished_jobs unchanged. AC #4 is verified post-deploy only.

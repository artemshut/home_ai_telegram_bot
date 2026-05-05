---
id: task-1.5
title: Wire recurring schedule in config/recurring.yml
status: To Do
assignee: []
created_date: '2026-05-05 09:58'
labels: []
dependencies:
  - task-1.4
parent_task_id: task-1
---

## Description

Add SendDailyDigestJob to config/recurring.yml under both production and development sections using Fugit TZ-aware cron: "TZ=Europe/Warsaw 0 8 * * *". Use class: key (not command:) so Solid Queue calls perform_later with no args.

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Job fires at 08:00 Warsaw time daily in production
- [ ] #2 Same entry present in development for local testing
- [ ] #3 Existing clear_solid_queue_finished_jobs task unchanged
- [ ] #4 After deploy: SolidQueue::RecurringTask.find_by(key: 'send_daily_digest') exists in console
<!-- AC:END -->

---
id: task-1.4
title: Create SendDailyDigestJob
status: To Do
assignee: []
created_date: '2026-05-05 09:58'
labels: []
dependencies:
  - task-1.1
  - task-1.2
  - task-1.3
parent_task_id: task-1
---

## Description

Create app/jobs/send_daily_digest_job.rb queued on :telegram. Iterates all households with find_each, fetches today's active calendar events and today's meals from the current week's menu, formats with MessageFormatter, and sends via BotClient using user.telegram_id as chat_id. Per-user rescue logs errors and continues.

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Calls send_message once per telegram_user in each household
- [ ] #2 Skips households with no telegram_users
- [ ] #3 Handles missing weekly menu gracefully (empty meals, no crash)
- [ ] #4 Per-user Telegram failure is logged and does not abort other users
- [ ] #5 Queued on :telegram
- [ ] #6 Tests stub BotClient and cover happy path, empty household, missing menu, and per-user error
<!-- AC:END -->

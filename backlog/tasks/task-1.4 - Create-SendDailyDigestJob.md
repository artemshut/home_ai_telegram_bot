---
id: task-1.4
title: Create SendDailyDigestJob
status: Done
assignee:
  - '@claude'
created_date: '2026-05-05 09:58'
updated_date: '2026-05-05 10:16'
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
- [x] #1 Calls send_message once per telegram_user in each household
- [x] #2 Skips households with no telegram_users
- [x] #3 Handles missing weekly menu gracefully (empty meals, no crash)
- [x] #4 Per-user Telegram failure is logged and does not abort other users
- [x] #5 Queued on :telegram
- [x] #6 Tests stub BotClient and cover happy path, empty household, missing menu, and per-user error
<!-- AC:END -->


## Implementation Plan

1. Create app/jobs/send_daily_digest_job.rb:
   - queue_as :telegram
   - perform: instantiate BotClient + MessageFormatter
   - Household.find_each; skip if no telegram_users
   - Fetch events: household.calendar_events.active.today
   - Fetch meals: find menu via weekly_menus.for_week_of(Date.current).first, then menu.meals.for_day(day_of_week).includes(:dish) or [] if no menu
   - format_daily_digest(date: Date.current, events:, meals:)
   - Send to each telegram_user.telegram_id; rescue StandardError per user, log and continue
2. Create test/jobs/send_daily_digest_job_test.rb:
   - Stub Telegram::BotClient.new to capture calls
   - happy path: two users both receive send_message
   - skip households with no telegram_users (send_message never called)
   - missing weekly menu: no crash, empty meals list sent
   - per-user error: one user raises, other still receives message


## Implementation Notes

Created SendDailyDigestJob queued on :telegram. Iterates Household.find_each, skips those with no telegram_users, fetches today's active calendar events and today's meals from the current week's menu (empty array when no menu). Formats via MessageFormatter#format_daily_digest and sends to each user's telegram_id. Per-user StandardError is rescued, logged, and iteration continues. Six tests cover: all users receive the digest, empty household is skipped, missing menu yields no crash, per-user failure logs and continues, events appear in output, meals appear in output.

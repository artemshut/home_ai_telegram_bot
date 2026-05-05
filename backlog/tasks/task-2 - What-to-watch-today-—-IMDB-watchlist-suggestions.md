---
id: task-2
title: What to watch today — IMDB watchlist suggestions
status: To Do
assignee: []
created_date: '2026-05-05 09:58'
labels: []
dependencies: []
---

## Description

Add a feature where the bot suggests what to watch today based on the user's IMDB watchlist. User can ask the bot for a viewing suggestion; Claude picks something from the watchlist considering factors like mood, length, or genre.

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 User can trigger suggestion via natural language message or command
- [ ] #2 Bot retrieves the household's IMDB watchlist (import from IMDB export CSV or manual list)
- [ ] #3 Claude selects a suggestion with a short reason
- [ ] #4 User can ask for another suggestion or mark as watched
- [ ] #5 Watched items are tracked so they are not suggested again
<!-- AC:END -->

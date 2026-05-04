# Backlog

Task tracker for HomeAiTelegramBot. Tasks are grouped by epic and roughly ordered by milestone.

## Status Legend

- `[ ]` todo — not started
- `[~]` in progress — actively being worked on
- `[x]` done — merged/shipped
- `[-]` cancelled — decided not to do

See [`CLAUDE.md`](CLAUDE.md) for architecture and the implementation plan.

---

## Milestone 0 — Smallest provable loop

Goal: `/start` → echo reply, with rows in `telegram_messages` and `ai_runs`.

### Epic: Foundation

- [x] Add `json-schema` gem to Gemfile (Google gems deferred to Milestone 5)
- [x] Migrations + models: `Household`, `TelegramUser`, `TelegramMessage` with associations, validations, and `update_id` unique index
- [x] Add `Rails.application.credentials.telegram` (bot_token, webhook_secret, allowed_telegram_ids) and `:anthropic` (api_key)
- [x] `Telegram::WebhooksController#create` — secret-token + `X-Telegram-Bot-Api-Secret-Token` header verification, idempotent on `update_id`
- [x] `Telegram::WebhookHandler` (upsert user, persist message, enqueue job) and `Telegram::AuthGuard` (whitelist)
- [x] `Telegram::BotClient` wrapper (`send_message`, `send_chat_action`, `edit_message_text`, `answer_callback_query`)
- [x] `ProcessTelegramUpdateJob` skeleton on `:telegram` queue with echo behaviour
- [x] Rake task `telegram:set_webhook` / `telegram:delete_webhook` for local dev with ngrok

---

## Milestone 1 — Claude in the loop, no tools

Goal: free-form chat works; every user message gets a Claude reply; every call writes an `AiRun`.

- [x] Migrations + models: `AiRun`, `ToolCall` with status enums
- [x] `Ai::ClaudeClient` with prompt caching and `AiRun` persistence (tokens, latency, cost)
- [x] `Ai::AiRouter` tool-loop (max depth 5), `Ai::ToolContext`, `Ai::ToolResult`
- [x] `Ai::ToolRegistry` and `Ai::Tools::BaseTool` with JSON-Schema argument validation
- [x] `Ai::Prompts::SystemPrompt` (household members, current date, timezone)
- [x] Minitest coverage: webhook auth, idempotency, AiRouter happy/sad path with stubbed Claude

---

## Milestone 2 — Menu Tool

Goal: User adds dishes to a shared dish library, then picks which dishes to cook this week; `WeeklyMenu` + `Meal`s saved; formatted Telegram reply.

### Epic: Menu Tool

- [x] Migrations + models: `Dish` (name, household), `WeeklyMenu`, `Meal` with unique `(household_id, week_start_date)`
- [x] `AddDishTool` — add a named dish to the household dish library
- [x] `ListDishesTool` — return the household's dish library
- [x] `PlanWeeklyMenuTool` — schema: `week_start_date`, dish names; creates `WeeklyMenu` + `Meal`s
- [x] Household seed / assignment — `seeds.rb` creates default "Home" household; `WebhookHandler` auto-assigns new users
- [x] `Telegram::MessageFormatter#format_weekly_menu` (day-grouped output)
- [x] `/menu` deterministic command (show active menu without calling Claude)

---

## Milestone 3 — Shopping List Tool

Goal: "build a shopping list from this week's menu" → `ShoppingList` + items; "mark purchased" callback flow.

### Epic: Shopping List Tool

- [x] Migrations + models: `ShoppingList`, `ShoppingItem`
- [x] `CreateShoppingListTool` (from active menu or freeform item list) and `AddShoppingItemTool`
- [x] `KeyboardBuilder#shopping_item_toggle` + `CallbackRouter` that flips `purchased` and refreshes the list message

---

## Milestone 4 — Expenses Tool

Goal: "I spent 12 eur on groceries" → `Expense` row; "expenses this month" → summary reply.

### Epic: Expenses Tool

- [x] Migrations + models: `ExpenseCategory`, `Expense`; seed default categories
- [x] `LogExpenseTool` with `Expenses::Categorizer` (keyword heuristics; Claude infers category from context)
- [x] `SummarizeExpensesTool` (week / month / year, optional category filter) and `ListExpenseCategoriesTool`
- [x] `MessageFormatter#format_expense_summary`

---

## Milestone 5 — Google Calendar Tool

Goal: OAuth setup + "schedule dinner Friday 7pm" → confirmation flow → event lands in shared Google Calendar.

### Epic: Calendar Tool

- [x] Add gems: `google-apis-calendar_v3`, `googleauth`
- [x] Migrations + models: `GoogleOauthToken`, `CalendarEvent`
- [x] `Google::OauthService` + controller (`/google/oauth/start`, `/google/oauth/callback`)
- [x] `Google::CalendarClient` (insert / list / delete)
- [x] `CreateCalendarEventTool` with `requires_confirmation? = true` + inline-keyboard confirm/cancel
- [x] `SyncCalendarEventJob` — push confirmed events to Google asynchronously
- [x] `ListCalendarEventsTool`

---

## Milestone 6 — Polish & Ops

### Epic: Polish & Ops

- [ ] Deterministic commands routed before Claude: `/help`, `/start`, `/whoami`
- [ ] Admin UI (Tailwind + Turbo) under `/admin` with basic auth: `AiRun`, `ToolCall`, `WeeklyMenu`, `Expense`
- [ ] Structured logging tags (`telegram_user_id`, `ai_run_id`) via `Rails.logger.tagged`
- [ ] Brakeman + Rubocop in CI; gate merges on `bin/rails test`
- [ ] README runbook: ngrok, webhook setup, credentials, Google OAuth flow
- [ ] Kamal `bin/jobs` for Solid Queue and a `solid_queue` process in `deploy.yml`

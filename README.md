# HomeAiTelegramBot

A personal Telegram bot for household management, powered by Claude AI for reasoning and tool orchestration. Rails owns all state, persistence, and side effects; Claude reasons over context and chooses tools to call.

Built for a single household (two users) — owner and partner share menus, shopping lists, expenses, and calendar events through a private Telegram bot.

## Features

### 1. Weekly Menu Planner
Ask the bot to plan a week of meals based on dietary preferences, allergies, and household tastes. Get back a structured menu (breakfast, lunch, dinner) for each day, persisted in the database and formatted as a clean Telegram message. Regenerate individual meals you don't like.

### 2. Shopping List
Auto-generate a categorized shopping list from any weekly menu. Add ad-hoc items via chat. Mark items as purchased with inline buttons — the list updates in place.

### 3. Expense Tracker
Log expenses in natural language ("spent 12 eur on groceries at REWE"). The bot categorizes automatically (groceries, dining, transport, utilities…) and stores them per household. Ask for summaries by week, month, or category.

### 4. Google Calendar Integration
Connect a shared Google Calendar once via OAuth. Create events through chat ("schedule dinner Friday 7pm") with explicit confirmation before anything is added to the real calendar.

## Tech Stack

- **Ruby 3.3.6** + **Rails 8.1.3**
- **PostgreSQL** for persistence
- **Solid Queue** for background jobs (Rails 8 default)
- **Anthropic Claude API** (`anthropic-rb`) for reasoning and tool selection
- **Telegram Bot API** (`telegram-bot-ruby`) for messaging
- **Google Calendar API** for calendar integration
- **Tailwind CSS** + **Hotwire** for the optional admin/debug UI
- **Docker + Kamal** for deployment

## Architecture

Webhook-driven, fully asynchronous, and tool-based:

```
Telegram update → webhook → background job → Claude (with tools) → Rails tool execution → reply
```

Claude is the router, not the database. Every Claude call is recorded as an `AiRun`; every tool invocation is recorded as a `ToolCall` for audit and debugging. See [`CLAUDE.md`](CLAUDE.md) for the full architecture and design rules.

## Getting Started

### Prerequisites
- Ruby 3.3.6 (see `.ruby-version`)
- PostgreSQL running locally
- A Telegram bot token (create one via [@BotFather](https://t.me/BotFather))
- An Anthropic API key
- ngrok or similar for exposing the local webhook during development

### Setup

```bash
bundle install
bin/rails db:create db:migrate
```

Edit credentials and add your secrets:

```bash
EDITOR=vim bin/rails credentials:edit
```

Required keys:

```yaml
telegram:
  bot_token: "<from BotFather>"
  webhook_secret: "<long random string>"
  allowed_telegram_ids: [12345678, 87654321]   # owner + partner
anthropic:
  api_key: "<sk-ant-...>"
```

### Run the dev server

```bash
bin/dev   # web + Tailwind watcher (Procfile.dev)
```

In a separate terminal, expose the local server and register the webhook:

```bash
ngrok http 3000
bin/rails telegram:set_webhook URL=https://<your-ngrok-host>
```

Send a message to your bot — it should reply.

### Tests

```bash
bin/rails test                          # full Minitest suite
bin/rails test test/models/x_test.rb    # single file
bin/rails test test/models/x_test.rb:42 # single test at line 42
```

### Code quality

```bash
bundle exec rubocop          # Rails Omakase style
bundle exec rubocop -A       # auto-fix
bundle exec brakeman         # security scan
bundle exec bundler-audit    # check gems for CVEs
```

## Project Documents

- [`CLAUDE.md`](CLAUDE.md) — architecture, design rules, and guidance for Claude Code agents
- [`backlog.md`](backlog.md) — tracked tasks, grouped by epic, with status

## Deployment

Kamal is configured under `.kamal/` for containerized deployment. The Dockerfile uses a multi-stage build.

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**HomeAiTelegramBot** is a Ruby on Rails application for a Telegram bot that helps with home automation tasks. It integrates Claude AI for reasoning and tool orchestration while keeping Rails as the source of truth for state, persistence, and side effects.

### Project Purpose

This is a Telegram bot for household management with:

**Initial scope:**
- Dish library (household-owned list of dishes)
- Weekly menu planning (pick dishes for the week)
- Shopping lists
- Adding events to calendar

**Future scope:**
- MCP-based tool expansion
- Smart home integrations
- Games inside Telegram
- More household automation

### Tech Stack

- **Ruby 3.3.6** with **Rails 8.1.3**
- **PostgreSQL** for persistence
- **Telegram Bot API** for messaging
- **Anthropic Claude API** for AI reasoning and tool selection
- **Solid Queue** for background jobs
- **Docker & Kamal** for deployment
- **Hotwire** (Turbo + Stimulus) for admin/debug UI (optional)
- **Tailwind CSS** for styling

## Getting Started

### Setup

```bash
# Install dependencies
bundle install

# Create and setup database
rails db:create db:migrate

# Run the development server and CSS watcher
./bin/dev  # or manually: web + css from Procfile.dev
```

The development server runs on `http://localhost:3000` by default.

## Common Commands

### Development

```bash
./bin/dev                              # Run web server + Tailwind watcher
bin/rails server                       # Web server only
bin/rails tailwindcss:watch           # CSS watcher only
```

### Database

```bash
rails db:create                        # Create development and test databases
rails db:migrate                       # Apply pending migrations
rails db:reset                         # Drop, create, and seed databases
rails db:seed                          # Seed database with initial data
```

### Testing

```bash
rails test                             # Run all tests
rails test:system                      # Run system tests (browser-based)
rails test test/models/user_test.rb    # Run single test file
rails test test/models/user_test.rb:42 # Run specific test at line 42
```

### Code Quality

```bash
bundle exec rubocop                    # Lint with RuboCop (Omakase style)
bundle exec rubocop -A                 # Auto-fix linting issues
bundle exec brakeman                   # Security scanning
bundle exec bundler-audit check        # Check for vulnerable gems
```

### Console & Utilities

```bash
rails console                          # Interactive Rails console
rails routes                           # Display all routes
rails assets:precompile               # Compile assets for production
rails credentials:edit                 # Edit encrypted credentials (uses EDITOR env var)
```

## Architecture & Principles

### Core Architecture Principle

**Do not build this as a simple chatbot.** Claude should reason and choose tools, but Rails owns everything else.

Correct flow:

```
User message → Telegram webhook → Rails job → Claude router → tool selection → Rails tool execution → Telegram response
```

**Rails owns:**
- Persistence (state, users, households, menus, shopping lists)
- Validation and authorization
- Side effects (database writes, Telegram sends)
- Calendar actions
- Shopping list state
- User/household state

**Claude must not be treated as the database.** It reasons over current state and decides what tools to call; Rails executes those tools and maintains authoritative state.

### Standard Rails Directories

- **app/models/** — ActiveRecord models and domain logic. Use concerns for shared behavior across multiple models.
- **app/controllers/** — Request handlers. Keep thin; move logic to models or services.
- **app/views/** — ERB templates for HTML rendering (admin/debug UI only, not user-facing).
- **app/jobs/** — Async job definitions using Rails 8's Solid Queue (Telegram webhook processing, AI calls).
- **app/services/** — Namespaced service objects for AI, Telegram, and tool execution.
- **app/mailers/** — Email logic (ActionMailer).
- **app/assets/** — Images and other static assets.
- **app/javascript/** — ESM modules and Stimulus controllers for admin UI.
- **config/environments/** — Environment-specific configuration (development, test, production).
- **db/migrate/** — Schema migration files (numbered by timestamp).
- **lib/tasks/** — Custom Rake tasks.
- **test/** — Test files mirroring app structure (models, controllers, integration, system, etc.).

### Configuration

- **config/routes.rb** — Route definitions (Rails DSL).
- **config/database.yml** — Database connection settings per environment.
- **config/credentials.yml.enc** — Encrypted secrets (edit with `rails credentials:edit`).
- **config/cable.yml** — ActionCable (WebSocket) configuration.
- **config/puma.rb** — Puma web server configuration.
- **config/importmap.rb** — JavaScript import map (for asset pipeline).

### Deployment

- **Dockerfile** — Container image definition.
- **.kamal/** — Kamal deployment configuration (for automatic deploys to VPS/cloud).
- **.dockerignore** — Files excluded from Docker builds.
- **.github/** — GitHub workflows (CI/CD if present).

### Domain Model

Expected core models (build these explicitly with database state, not hidden in Claude prompts):

- **TelegramUser** — Links Telegram user ID to internal user record.
- **Household** — A group of people sharing a space (family, roommates, etc.).
- **HouseholdMembership** — Maps users to households.
- **Dish** — A named dish in the household's dish library (reusable across menus).
- **WeeklyMenu** — A plan for the week, owned by a household.
- **Meal** — A single dish slot in a weekly menu (day + meal type, references a Dish).
- **ShoppingList** — A list of items to buy, linked to a menu or household.
- **ShoppingItem** — An individual item on a shopping list with quantity and category.
- **AiRun** — Record of each Claude call (input, output, tokens, timestamp).
- **ToolCall** — Record of each tool invocation (tool name, args, result, timestamp).

Prefer explicit models and database state over hidden prompt memory.

### Service Structure

Use namespaced services under `app/services/home_ai_telegram_bot/`:

```
app/services/home_ai_telegram_bot/
  ai/
    claude_client.rb          # Calls Claude API, manages requests/responses
    ai_router.rb              # Decodes Claude's tool calls, routes to tools
    tool_registry.rb          # Central registry of available tools
    tools/
      add_dish_tool.rb
      list_dishes_tool.rb
      plan_weekly_menu_tool.rb
      create_shopping_list_tool.rb
      create_calendar_event_tool.rb
  telegram/
    bot_client.rb             # Telegram API interactions (send_message, etc.)
    message_formatter.rb      # Format Rails data into Telegram messages
    callback_router.rb        # Route incoming Telegram updates to jobs
```

Keep service objects small and testable. Each tool should have:
- Clear name and description
- JSON schema for arguments
- Validation logic
- Deterministic Rails-side execution
- Persisted ToolCall record
- Safe error handling (never expose internals to Claude)

## AI & Tool-Use Rules

Claude should use **structured tool calls** where possible (not free-form text responses).

### Initial Tools

- **add_dish** — Add a named dish to the household's dish library.
- **list_dishes** — Return the household's dish library.
- **plan_weekly_menu** — Pick dishes for each slot of the week; creates `WeeklyMenu` + `Meal` records.
- **create_shopping_list** — Generate a shopping list from the active menu or a freeform item list.
- **create_calendar_event** — (Future) Add events to a household calendar.

### Tool Execution Contract

Each tool call requires:
1. **Tool name** — Lowercase, underscore-separated, unambiguous.
2. **JSON schema** — Clear argument types and constraints.
3. **Validation** — Schema validation before execution, user-friendly error messages.
4. **Rails execution** — Tool logic runs in Rails, not Claude. Claude never executes arbitrary code.
5. **Persisted record** — Every tool call is logged as a `ToolCall` record for audit/debugging.
6. **Safe error handling** — Tool failures are caught, logged, and reported to Claude as structured errors (never expose secrets or stack traces).

**Do not parse important data from free-form Claude text if structured output or tool arguments can be used.**

### MCP Strategy

**Do not implement MCP in the first version.** Design the internal `ToolRegistry` so MCP tools can be added later without major refactoring.

The local Rails tool interface should look like:

```ruby
def execute(tool_name, arguments, context)
  # Find tool in registry
  # Validate arguments against schema
  # Execute tool in Rails
  # Return structured result
end
```

Later, MCP tools may be wrapped behind the same interface.

## Safety Rules

Require explicit user confirmation before:
- Creating calendar events
- Ordering anything (future feature)
- Sending external requests with side effects
- Changing smart home state
- Deleting data

**Never execute arbitrary code generated by Claude.**
**Never expose secrets to Claude prompts.**
**Never let Claude directly access shell, filesystem, credentials, or production database.**

## Telegram UX Rules

Prefer short, useful Telegram responses.

Use inline buttons for confirmation flows:
- "Create menu" / "Regenerate" / "Replace meal"
- "Create shopping list"
- "Add to calendar"

Avoid long walls of text when a structured message would be better.

## Key Technologies & Patterns

### Rails 8 Defaults

This project uses Rails 8.1's modern defaults:

- **Solid Cache** — In-process caching with database persistence (replaces Redis in simple deployments).
- **Solid Queue** — Background job queue with database persistence (replaces Sidekiq in simple deployments).
- **Solid Cable** — WebSocket server with database persistence.
- **Propshaft** — Modern asset pipeline (replaces Sprockets).

These are configured in `config/cache.yml`, `config/queue.yml`, and `config/cable.yml`.

### Hotwire (Turbo + Stimulus)

- **Turbo** — Fast page transitions without full reloads (configured in `app/javascript/`).
- **Stimulus** — Lightweight controller library for adding interactivity to HTML (define controllers in `app/javascript/controllers/`).

### Database

PostgreSQL is configured in `config/database.yml`. The development database is `home_ai_telegram_bot_development`. Use migrations (in `db/migrate/`) to modify the schema—never edit `db/schema.rb` manually.

### Credentials & Secrets

Sensitive values (API keys, database passwords) go in `config/credentials.yml.enc`. Edit with:

```bash
EDITOR=vim rails credentials:edit  # or your preferred editor
```

Access credentials in code with `Rails.application.credentials.key_name`. The `config/master.key` file must be kept secure and never committed.

## Code Quality Standards

### Style & Linting

Uses **RuboCop with Omakase configuration** (Rails community best practices). The `.rubocop.yml` inherits from `rubocop-rails-omakase`.

- Run `bundle exec rubocop` to check.
- Run `bundle exec rubocop -A` to auto-fix most issues.
- Override specific rules in `.rubocop.yml` if needed.

### Security Checks

- **Brakeman** — Detects security vulnerabilities in Rails code. Run with `bundle exec brakeman`.
- **Bundler Audit** — Checks dependencies for known CVEs. Run with `bundle exec bundler-audit check`. Configuration in `config/bundler-audit.yml`.

## Testing Strategy

Rails 8 uses **Minitest** by default (in `test/` directory).

### Test Organization

- **test/models/** — Unit tests for ActiveRecord models and domain logic.
- **test/controllers/** — Controller action tests.
- **test/integration/** — Multi-request integration tests (e.g., user workflows).
- **test/system/** — Browser-based system tests using Capybara + Selenium (full user interactions).
- **test/fixtures/** — Reusable test data (YAML format by default).
- **test/test_helper.rb** — Base configuration for all tests.

### Writing Tests

```ruby
# app/models/user.rb
class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
end

# test/models/user_test.rb
require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "user must have email" do
    user = User.new(email: "")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end
end
```

Run tests with `rails test` or filter to specific files/lines.

## Environment Variables

Development behavior can be controlled via environment variables:

```bash
RAILS_LOG_LEVEL=debug    # More verbose logging
RAILS_MAX_THREADS=5      # Database connection pool size (default 5)
```

View or edit with `EDITOR=vim rails credentials:edit` for encrypted storage.

## Debugging Tips

- Use `debugger` gem (already in Gemfile as `debug`) — add `debugger` line in code, then `rails server` will pause there.
- `rails console` for interactive model testing.
- Check `log/development.log` for request/query logs.
- Browser DevTools for JavaScript debugging (Stimulus controllers run in the browser).

## Deployment

**Kamal** is configured for containerized deployment. See `.kamal/` for settings.

For production builds:

```bash
docker build -t home-ai-telegram-bot .
docker run -p 3000:3000 home-ai-telegram-bot
```

The Dockerfile uses a multi-stage build to minimize image size.

## Coding Style

- Prefer Rails conventions over custom abstractions.
- Keep controllers thin; move logic to models or services.
- Use background jobs (`Solid Queue`) for Telegram webhook processing and AI calls.
- Store raw incoming Telegram updates only when useful for debugging.
- Add tests for tool execution, routing logic, and domain models.
- Avoid premature abstractions; three similar lines is better than a generic helper too early.
- Avoid building a large agent framework before the core loop works.
- Default to no comments; only add one if the WHY is non-obvious.

## First Milestone (Current Priority)

Build the smallest useful product: **"User picks dishes for the week → bot saves a `WeeklyMenu` → Telegram shows it."**

Focus on this loop only:

1. Receive Telegram message (webhook → job)
2. Save or identify Telegram user
3. Load household and its dish library
4. Send message + context to Claude
5. Claude uses `add_dish` / `plan_weekly_menu` tools as needed
6. Rails executes tool: create `Dish` / `WeeklyMenu` + `Meal` records
7. Rails formats response
8. Send formatted menu back to Telegram

**Do not implement:** calendar, MCP tools, smart home, games, or shopping lists until the menu flow works end-to-end.

## Future Development Notes

- Implement shopping lists once menu flow is stable.
- Add calendar integration once core tools are working.
- Design MCP wrapper only after internal tools are proven.
- Smart home integrations are later priorities.
- Telegram inline buttons for confirmations come after basic functionality.

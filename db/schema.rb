# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_05_05_000003) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "ai_runs", force: :cascade do |t|
    t.integer "cache_creation_tokens"
    t.integer "cache_read_tokens"
    t.datetime "created_at", null: false
    t.integer "duration_ms"
    t.text "error"
    t.integer "input_tokens"
    t.jsonb "messages", default: [], null: false
    t.string "model", null: false
    t.integer "output_tokens"
    t.jsonb "response", default: {}, null: false
    t.string "status", default: "pending", null: false
    t.text "system_prompt"
    t.bigint "telegram_message_id"
    t.bigint "telegram_user_id"
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_ai_runs_on_status"
    t.index ["telegram_message_id"], name: "index_ai_runs_on_telegram_message_id"
    t.index ["telegram_user_id"], name: "index_ai_runs_on_telegram_user_id"
  end

  create_table "calendar_events", force: :cascade do |t|
    t.boolean "all_day", default: false, null: false
    t.string "calendar_id", default: "primary", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "end_at", null: false
    t.string "google_event_id"
    t.bigint "household_id", null: false
    t.string "location"
    t.datetime "start_at", null: false
    t.string "status", default: "pending", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["household_id", "status"], name: "index_calendar_events_on_household_id_and_status"
    t.index ["household_id"], name: "index_calendar_events_on_household_id"
    t.index ["start_at"], name: "index_calendar_events_on_start_at"
  end

  create_table "dishes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "household_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["household_id", "name"], name: "index_dishes_on_household_id_and_name", unique: true
    t.index ["household_id"], name: "index_dishes_on_household_id"
  end

  create_table "expense_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_expense_categories_on_name", unique: true
  end

  create_table "expenses", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "EUR", null: false
    t.text "description", null: false
    t.bigint "expense_category_id", null: false
    t.bigint "household_id", null: false
    t.date "spent_on", null: false
    t.bigint "telegram_user_id"
    t.datetime "updated_at", null: false
    t.index ["expense_category_id"], name: "index_expenses_on_expense_category_id"
    t.index ["household_id"], name: "index_expenses_on_household_id"
    t.index ["spent_on"], name: "index_expenses_on_spent_on"
    t.index ["telegram_user_id"], name: "index_expenses_on_telegram_user_id"
  end

  create_table "google_oauth_tokens", force: :cascade do |t|
    t.text "access_token"
    t.datetime "created_at", null: false
    t.string "email"
    t.datetime "expires_at"
    t.bigint "household_id", null: false
    t.text "refresh_token"
    t.string "scope"
    t.string "token_type", default: "Bearer"
    t.datetime "updated_at", null: false
    t.index ["household_id"], name: "index_google_oauth_tokens_on_household_id", unique: true
  end

  create_table "households", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "meals", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "day_of_week", null: false
    t.bigint "dish_id", null: false
    t.string "meal_type", null: false
    t.datetime "updated_at", null: false
    t.bigint "weekly_menu_id", null: false
    t.index ["dish_id"], name: "index_meals_on_dish_id"
    t.index ["weekly_menu_id", "day_of_week", "meal_type"], name: "index_meals_on_weekly_menu_id_and_day_of_week_and_meal_type", unique: true
    t.index ["weekly_menu_id"], name: "index_meals_on_weekly_menu_id"
  end

  create_table "shopping_items", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.boolean "purchased", default: false, null: false
    t.bigint "shopping_list_id", null: false
    t.datetime "updated_at", null: false
    t.index ["shopping_list_id", "name"], name: "index_shopping_items_on_shopping_list_id_and_name", unique: true
    t.index ["shopping_list_id"], name: "index_shopping_items_on_shopping_list_id"
  end

  create_table "shopping_lists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "household_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.bigint "weekly_menu_id"
    t.index ["household_id"], name: "index_shopping_lists_on_household_id"
    t.index ["weekly_menu_id"], name: "index_shopping_lists_on_weekly_menu_id"
  end

  create_table "telegram_messages", force: :cascade do |t|
    t.bigint "chat_id", null: false
    t.datetime "created_at", null: false
    t.string "direction", default: "inbound", null: false
    t.bigint "message_id", null: false
    t.jsonb "raw_update", default: {}, null: false
    t.bigint "telegram_user_id"
    t.text "text"
    t.bigint "update_id", null: false
    t.datetime "updated_at", null: false
    t.index ["telegram_user_id"], name: "index_telegram_messages_on_telegram_user_id"
    t.index ["update_id"], name: "index_telegram_messages_on_update_id", unique: true
  end

  create_table "telegram_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "first_name"
    t.bigint "household_id"
    t.string "last_name"
    t.bigint "telegram_id", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["household_id"], name: "index_telegram_users_on_household_id"
    t.index ["telegram_id"], name: "index_telegram_users_on_telegram_id", unique: true
  end

  create_table "tool_calls", force: :cascade do |t|
    t.bigint "ai_run_id", null: false
    t.jsonb "arguments", default: {}, null: false
    t.datetime "created_at", null: false
    t.integer "duration_ms"
    t.text "error"
    t.jsonb "result", default: {}, null: false
    t.string "status", default: "pending", null: false
    t.string "tool_name", null: false
    t.datetime "updated_at", null: false
    t.index ["ai_run_id"], name: "index_tool_calls_on_ai_run_id"
    t.index ["status"], name: "index_tool_calls_on_status"
  end

  create_table "weekly_menus", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "household_id", null: false
    t.text "notes"
    t.datetime "updated_at", null: false
    t.date "week_start_date", null: false
    t.index ["household_id", "week_start_date"], name: "index_weekly_menus_on_household_id_and_week_start_date", unique: true
    t.index ["household_id"], name: "index_weekly_menus_on_household_id"
  end

  add_foreign_key "ai_runs", "telegram_messages"
  add_foreign_key "ai_runs", "telegram_users"
  add_foreign_key "calendar_events", "households"
  add_foreign_key "dishes", "households"
  add_foreign_key "expenses", "expense_categories"
  add_foreign_key "expenses", "households"
  add_foreign_key "expenses", "telegram_users"
  add_foreign_key "google_oauth_tokens", "households"
  add_foreign_key "meals", "dishes"
  add_foreign_key "meals", "weekly_menus"
  add_foreign_key "shopping_items", "shopping_lists"
  add_foreign_key "shopping_lists", "households"
  add_foreign_key "shopping_lists", "weekly_menus"
  add_foreign_key "telegram_messages", "telegram_users"
  add_foreign_key "telegram_users", "households"
  add_foreign_key "tool_calls", "ai_runs"
  add_foreign_key "weekly_menus", "households"
end

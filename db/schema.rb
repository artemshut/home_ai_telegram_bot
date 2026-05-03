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

ActiveRecord::Schema[8.1].define(version: 2026_05_03_000005) do
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

  create_table "households", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
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

  add_foreign_key "ai_runs", "telegram_messages"
  add_foreign_key "ai_runs", "telegram_users"
  add_foreign_key "telegram_messages", "telegram_users"
  add_foreign_key "telegram_users", "households"
  add_foreign_key "tool_calls", "ai_runs"
end

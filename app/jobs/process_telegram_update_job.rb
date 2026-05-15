class ProcessTelegramUpdateJob < ApplicationJob
  queue_as :telegram

  def perform(update_json, telegram_message_id = nil)
    update = JSON.parse(update_json)
    message = update["message"] || update["edited_message"]
    return unless message

    chat_id          = message.dig("chat", "id")
    text             = message["text"].presence || "(no text)"
    telegram_user    = TelegramUser.find_by(telegram_id: message.dig("from", "id"))
    telegram_message = telegram_message_id ? TelegramMessage.find_by(id: telegram_message_id) : nil
    reply_to_text    = message.dig("reply_to_message", "text").presence

    bot = Telegram::BotClient.new

    Rails.logger.tagged("tg_user=#{telegram_user&.telegram_id}") do
      reply = handle_command(text, telegram_user) ||
              handle_pending_note_input(text, telegram_user) ||
              handle_pending_note_edit(text, telegram_user) ||
              ai_reply(telegram_user, text, chat_id, telegram_message, bot, reply_to_text)

      bot.send_message(chat_id: chat_id, text: reply) if reply.present?
    end
  end

  private

  def handle_command(text, telegram_user)
    case text.strip.split.first
    when "/start"
      "Hi! I'm your household assistant. Send me a message to get started, or type /help to see what I can do."
    when "/help"
      <<~TEXT
        *Available commands:*
        /menu — show this week's menu
        /help — show this help message
        /whoami — show your account info

        You can also just chat with me naturally — ask me to plan a menu, add dishes, build a shopping list, log an expense, or schedule a calendar event.
      TEXT
    when "/whoami"
      if telegram_user
        household_name = telegram_user.household&.name || "none"
        "You are #{telegram_user.display_name} (Telegram ID: #{telegram_user.telegram_id}). Household: #{household_name}."
      else
        "I don't have a record for you yet. Try sending any message to get started."
      end
    when "/menu"
      menu = telegram_user&.household&.weekly_menus&.order(week_start_date: :desc)&.first
      if menu
        Telegram::MessageFormatter.new.format_weekly_menu(menu)
      else
        "No menu planned yet. Ask me to plan one!"
      end
    end
  end

  def handle_pending_note_edit(text, telegram_user)
    return nil unless telegram_user&.pending_edit_note_id

    note = telegram_user.notes.confirmed.find_by(id: telegram_user.pending_edit_note_id)
    return nil unless note

    telegram_user.update!(pending_edit_note_id: nil)
    note.update!(content: text.strip)

    visibility_label = note.visibility == "private" ? "🔒 Personal" : "🌐 Public"
    category_label   = note.note_category&.name || "Uncategorised"
    "Note updated! #{visibility_label} · #{category_label}\n\n#{note.content}"
  rescue ActiveRecord::RecordInvalid => e
    "Couldn't update note: #{e.message}"
  end

  def handle_pending_note_input(text, telegram_user)
    return nil unless telegram_user

    pending_note = telegram_user.notes.pending.awaiting_category.last
    return nil unless pending_note

    category = pending_note.household.note_categories.find_or_create_by!(name: text.strip)
    pending_note.update!(note_category: category, status: "confirmed")

    visibility_label = pending_note.visibility == "private" ? "🔒 Personal" : "🌐 Public"
    timestamp        = pending_note.created_at.strftime("%-d %b %Y")
    "Note saved! #{visibility_label} · #{category.name} · #{timestamp}\n\n#{pending_note.content}"
  rescue ActiveRecord::RecordInvalid => e
    "Couldn't save category: #{e.message}"
  end

  def ai_reply(telegram_user, text, chat_id, telegram_message, bot, reply_to_text = nil)
    router = Ai::AiRouter.new(
      telegram_user:    telegram_user,
      message_text:     text,
      chat_id:          chat_id,
      telegram_message: telegram_message,
      reply_to_text:    reply_to_text
    )

    reply = router.call
    structured_sent = false

    if (list = router.last_shopping_list)
      formatted = Telegram::MessageFormatter.new.format_shopping_list(list)
      keyboard  = Telegram::KeyboardBuilder.new.shopping_item_toggle(list)
      bot.send_message(chat_id: chat_id, text: formatted, reply_markup: keyboard.to_json)
      structured_sent = true
    end

    if (event = router.last_pending_calendar_event)
      keyboard = Telegram::KeyboardBuilder.new.calendar_event_confirm(event)
      prompt   = "Confirm '#{event.title}' on #{event.start_at.strftime("%a, %b %-d at %-I:%M %p")}?"
      bot.send_message(chat_id: chat_id, text: prompt, reply_markup: keyboard.to_json)
      structured_sent = true
    end

    if (note = router.last_pending_note)
      kb_builder = Telegram::KeyboardBuilder.new
      if note.awaiting_visibility?
        keyboard = kb_builder.note_visibility_choice(note)
        bot.send_message(chat_id: chat_id, text: "Is this note personal or public?", reply_markup: keyboard.to_json)
        structured_sent = true
      elsif note.awaiting_category?
        categories = note.household.note_categories.order(:name)
        if categories.any?
          keyboard = kb_builder.note_category_choice(note, categories)
          bot.send_message(chat_id: chat_id, text: "Choose a category:", reply_markup: keyboard.to_json)
        else
          bot.send_message(chat_id: chat_id, text: "What category should this note go in? Reply with a name.")
        end
        structured_sent = true
      end
    end

    if router.respond_to?(:google_calendar_reauth_required?) && router.google_calendar_reauth_required?
      bot.send_message(chat_id: chat_id, text: reply) if reply.present?

      household = router.google_calendar_reauth_household
      if household
        keyboard = Telegram::KeyboardBuilder.new.google_calendar_reconnect(household)
        bot.send_message(
          chat_id: chat_id,
          text: "Google Calendar access expired or was revoked. Reconnect it here:",
          reply_markup: keyboard.to_json
        )
      end

      structured_sent = true
    end

    structured_sent ? nil : reply
  end
end

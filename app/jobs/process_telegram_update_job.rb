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

    structured_sent ? nil : reply
  end
end

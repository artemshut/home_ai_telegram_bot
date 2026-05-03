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

    reply = HomeAiTelegramBot::Ai::AiRouter.new(
      telegram_user:    telegram_user,
      message_text:     text,
      chat_id:          chat_id,
      telegram_message: telegram_message
    ).call

    HomeAiTelegramBot::Telegram::BotClient.new.send_message(
      chat_id: chat_id,
      text:    reply
    )
  end
end

require "telegram/bot"

module Telegram
  class BotClient
    def initialize
      token = Rails.application.credentials.dig(:telegram, :bot_token)
      @bot = ::Telegram::Bot::Client.new(token)
    end

    def send_message(chat_id:, text:, parse_mode: "Markdown", **opts)
      @bot.api.send_message(chat_id: chat_id, text: text, parse_mode: parse_mode, **opts)
    end

    def send_chat_action(chat_id:, action: "typing")
      @bot.api.send_chat_action(chat_id: chat_id, action: action)
    end

    def edit_message_text(chat_id:, message_id:, text:, parse_mode: "Markdown", **opts)
      @bot.api.edit_message_text(chat_id: chat_id, message_id: message_id, text: text, parse_mode: parse_mode, **opts)
    end

    def answer_callback_query(callback_query_id:, text: nil)
      @bot.api.answer_callback_query(callback_query_id: callback_query_id, text: text)
    end
  end
end

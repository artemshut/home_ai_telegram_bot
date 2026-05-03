module HomeAiTelegramBot
  module Ai
    ToolContext = Struct.new(:telegram_user, :chat_id, keyword_init: true)
  end
end

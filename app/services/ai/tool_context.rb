module Ai
  ToolContext = Struct.new(:telegram_user, :chat_id, :last_shopping_list, :last_pending_calendar_event, :last_pending_note, keyword_init: true)
end

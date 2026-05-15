module Ai
  ToolContext = Struct.new(
    :telegram_user,
    :chat_id,
    :last_shopping_list,
    :last_pending_calendar_event,
    :last_pending_note,
    :google_calendar_reauth_required,
    :google_calendar_reauth_household,
    keyword_init: true
  )
end

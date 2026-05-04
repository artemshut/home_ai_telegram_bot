module Telegram
  class CallbackRouter
    def initialize(callback_query)
      @callback_query = callback_query
    end

    def call
      data = @callback_query["data"]
      return unless data

      case data
      when /\Atoggle_item:(\d+)\z/
        toggle_shopping_item(Regexp.last_match(1).to_i)
      when /\Aconfirm_event:(\d+)\z/
        confirm_calendar_event(Regexp.last_match(1).to_i)
      when /\Acancel_event:(\d+)\z/
        cancel_calendar_event(Regexp.last_match(1).to_i)
      end

      BotClient.new.answer_callback_query(callback_query_id: @callback_query["id"])
    end

    private

    def confirm_calendar_event(event_id)
      event = CalendarEvent.find_by(id: event_id)
      return unless event&.pending?

      event.update!(status: "confirmed")
      SyncCalendarEventJob.perform_later(event.id)

      chat_id    = @callback_query.dig("message", "chat", "id")
      message_id = @callback_query.dig("message", "message_id")

      BotClient.new.edit_message_text(
        chat_id:    chat_id,
        message_id: message_id,
        text:       "'#{event.title}' confirmed. Syncing to Google Calendar..."
      )
    end

    def cancel_calendar_event(event_id)
      event = CalendarEvent.find_by(id: event_id)
      return unless event&.pending?

      event.update!(status: "cancelled")

      chat_id    = @callback_query.dig("message", "chat", "id")
      message_id = @callback_query.dig("message", "message_id")

      BotClient.new.edit_message_text(
        chat_id:    chat_id,
        message_id: message_id,
        text:       "'#{event.title}' cancelled."
      )
    end

    def toggle_shopping_item(item_id)
      item = ShoppingItem.find_by(id: item_id)
      return unless item

      item.update!(purchased: !item.purchased?)

      list = item.shopping_list
      formatted = MessageFormatter.new.format_shopping_list(list)
      keyboard   = KeyboardBuilder.new.shopping_item_toggle(list)

      chat_id    = @callback_query.dig("message", "chat", "id")
      message_id = @callback_query.dig("message", "message_id")

      BotClient.new.edit_message_text(
        chat_id:      chat_id,
        message_id:   message_id,
        text:         formatted,
        reply_markup: keyboard.to_json
      )
    end
  end
end

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
      when /\Anote_visibility:(private|public):(\d+)\z/
        set_note_visibility(Regexp.last_match(1), Regexp.last_match(2).to_i)
      when /\Anote_category:(\d+):(\d+)\z/
        assign_note_category(Regexp.last_match(1).to_i, Regexp.last_match(2).to_i)
      when /\Anote_new_category:(\d+)\z/
        prompt_new_category(Regexp.last_match(1).to_i)
      when /\Anote_edit:(\d+)\z/
        prompt_note_edit(Regexp.last_match(1).to_i)
      when /\Anote_delete:(\d+)\z/
        delete_note(Regexp.last_match(1).to_i)
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

    def set_note_visibility(visibility, note_id)
      note = Note.find_by(id: note_id)
      chat_id    = @callback_query.dig("message", "chat", "id")
      message_id = @callback_query.dig("message", "message_id")
      bot        = BotClient.new

      unless note&.pending?
        bot.edit_message_text(chat_id: chat_id, message_id: message_id, text: "Note not found or already saved.")
        return
      end

      note.visibility = visibility

      if note.note_category_id.present?
        note.status = "confirmed"
        note.save!
        bot.edit_message_text(chat_id: chat_id, message_id: message_id, text: note_saved_text(note))
      else
        note.save!
        categories = note.household.note_categories.order(:name)
        if categories.any?
          keyboard = KeyboardBuilder.new.note_category_choice(note, categories)
          bot.edit_message_text(chat_id: chat_id, message_id: message_id,
                                text: "Choose a category:", reply_markup: keyboard.to_json)
        else
          bot.edit_message_text(chat_id: chat_id, message_id: message_id,
                                text: "What category should this note go in? Reply with a name.")
        end
      end
    end

    def note_saved_text(note)
      visibility_label = note.visibility == "private" ? "🔒 Personal" : "🌐 Public"
      category_label   = note.note_category&.name || "Uncategorised"
      "Note saved! #{visibility_label} · #{category_label}\n\n#{note.content}"
    end

    def assign_note_category(category_id, note_id)
      note     = Note.find_by(id: note_id)
      category = NoteCategory.find_by(id: category_id)
      chat_id    = @callback_query.dig("message", "chat", "id")
      message_id = @callback_query.dig("message", "message_id")
      bot        = BotClient.new

      unless note&.pending? && category
        bot.edit_message_text(chat_id: chat_id, message_id: message_id, text: "Note or category not found.")
        return
      end

      note.update!(note_category: category, status: "confirmed")
      bot.edit_message_text(chat_id: chat_id, message_id: message_id, text: note_saved_text(note))
    end

    def prompt_new_category(note_id)
      note = Note.find_by(id: note_id)
      chat_id    = @callback_query.dig("message", "chat", "id")
      message_id = @callback_query.dig("message", "message_id")
      bot        = BotClient.new

      unless note&.pending?
        bot.edit_message_text(chat_id: chat_id, message_id: message_id, text: "Note not found or already saved.")
        return
      end

      bot.edit_message_text(
        chat_id:    chat_id,
        message_id: message_id,
        text:       "What should the new category be called? (note ##{note.id} is waiting)"
      )
    end

    def prompt_note_edit(note_id)
      telegram_user_id = @callback_query.dig("from", "id")
      note = Note.find_by(id: note_id)
      chat_id    = @callback_query.dig("message", "chat", "id")
      message_id = @callback_query.dig("message", "message_id")
      bot        = BotClient.new

      owner = note&.telegram_user
      unless owner && owner.telegram_id.to_s == telegram_user_id.to_s
        bot.edit_message_text(chat_id: chat_id, message_id: message_id, text: "Not authorised.")
        return
      end

      owner.update!(pending_edit_note_id: note.id)

      bot.edit_message_text(
        chat_id:    chat_id,
        message_id: message_id,
        text:       "Send the new content for note ##{note.id}:\n\n_#{note.content}_"
      )
    end

    def delete_note(note_id)
      telegram_user_id = @callback_query.dig("from", "id")
      note = Note.find_by(id: note_id)
      chat_id    = @callback_query.dig("message", "chat", "id")
      message_id = @callback_query.dig("message", "message_id")
      bot        = BotClient.new

      owner = note&.telegram_user
      unless owner && owner.telegram_id.to_s == telegram_user_id.to_s
        bot.edit_message_text(chat_id: chat_id, message_id: message_id, text: "Not authorised.")
        return
      end

      note.destroy!
      bot.edit_message_text(chat_id: chat_id, message_id: message_id, text: "Note deleted.")
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

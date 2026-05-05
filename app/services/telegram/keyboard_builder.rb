module Telegram
  class KeyboardBuilder
    def calendar_event_confirm(event)
      {
        inline_keyboard: [
          [
            { text: "Confirm", callback_data: "confirm_event:#{event.id}" },
            { text: "Cancel",  callback_data: "cancel_event:#{event.id}" }
          ]
        ]
      }
    end

    def note_visibility_choice(note)
      {
        inline_keyboard: [
          [
            { text: "Personal 🔒", callback_data: "note_visibility:private:#{note.id}" },
            { text: "Public 🌐",   callback_data: "note_visibility:public:#{note.id}" }
          ]
        ]
      }
    end

    def note_category_choice(note, categories)
      rows = categories.map do |cat|
        [ { text: cat.name, callback_data: "note_category:#{cat.id}:#{note.id}" } ]
      end
      rows << [ { text: "+ New category", callback_data: "note_new_category:#{note.id}" } ]
      { inline_keyboard: rows }
    end

    def note_actions(note, current_user)
      return nil unless note.telegram_user_id == current_user.id

      {
        inline_keyboard: [
          [
            { text: "Edit ✏️",   callback_data: "note_edit:#{note.id}" },
            { text: "Delete 🗑", callback_data: "note_delete:#{note.id}" }
          ]
        ]
      }
    end

    def shopping_item_toggle(shopping_list)
      rows = shopping_list.shopping_items.order(:name).map do |item|
        label = item.purchased? ? "✓ #{item.name}" : "○ #{item.name}"
        [ { text: label, callback_data: "toggle_item:#{item.id}" } ]
      end
      { inline_keyboard: rows }
    end
  end
end

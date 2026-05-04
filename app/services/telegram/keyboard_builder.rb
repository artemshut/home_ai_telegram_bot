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

    def shopping_item_toggle(shopping_list)
      rows = shopping_list.shopping_items.order(:name).map do |item|
        label = item.purchased? ? "✓ #{item.name}" : "○ #{item.name}"
        [ { text: label, callback_data: "toggle_item:#{item.id}" } ]
      end
      { inline_keyboard: rows }
    end
  end
end

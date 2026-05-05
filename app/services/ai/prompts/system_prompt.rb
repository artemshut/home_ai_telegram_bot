module Ai
  module Prompts
    class SystemPrompt
      def initialize(telegram_user)
        @telegram_user = telegram_user
      end

      def call
        parts = [
          "You are a home assistant bot for #{household_name}.",
          "Today is #{Date.current.strftime("%A, %B %-d, %Y")}.",
          household_section,
          dish_library_section,
          shopping_list_section,
          expenses_section,
          calendar_section,
          notes_section,
          "",
          "You help manage household tasks: weekly menus, shopping lists, expenses, notes, and other home organisation.",
          "Always use the available tools to take actions — don't just describe what you would do.",
          "When asked about calendar events, schedules, or any question about when something happens, ALWAYS call list_calendar_events first. Never answer from memory alone.",
          "For ANY question about specific events, birthdays, or a person's schedule, call list_calendar_events WITHOUT a query (use days_ahead: 365 to cover the full year), then find the relevant events yourself from the returned list. Never use a person's name as the query — names change grammatical form in Russian/Ukrainian and will fail to match.",
          "When creating a note, call create_note with the content — the bot handles visibility and category via inline buttons, do not ask the user yourself.",
          "When listing or searching notes, always call list_notes — never answer from memory.",
          "When deleting or editing a note by description, call list_notes first to resolve the note_id, then call delete_note or edit_note.",
          "Keep responses short and suited for Telegram.",
          "Format using Telegram Markdown: *bold* (single asterisk), _italic_, `code`. Never use **double asterisks**."
        ]

        parts.compact.join("\n")
      end

      private

      def household_name
        @telegram_user&.household&.name || "your household"
      end

      def household_section
        return nil unless @telegram_user&.household

        members = @telegram_user.household.telegram_users.map(&:display_name).join(", ")
        "Household members: #{members}"
      end

      def dish_library_section
        return nil unless @telegram_user&.household

        dishes = @telegram_user.household.dishes.order(:name)
        return "Dish library: (empty)" if dishes.none?

        names = dishes.map(&:name).join(", ")
        "Dish library: #{names}"
      end

      def expenses_section
        return nil unless @telegram_user&.household

        range    = Date.current.beginning_of_month..Date.current.end_of_month
        expenses = @telegram_user.household.expenses.where(spent_on: range)
        return nil if expenses.none?

        by_currency = expenses.group_by(&:currency)
        totals = by_currency.map { |cur, exps| "#{format("%.2f", exps.sum(&:amount))} #{cur}" }.join(", ")
        "Expenses this month: #{totals}"
      end

      def calendar_section
        return nil unless @telegram_user&.household

        events = @telegram_user.household.calendar_events
                               .active
                               .where("start_at >= ?", Time.current)
                               .order(:start_at)
                               .limit(5)
        return nil if events.none?

        lines = [ "Upcoming events:" ]
        events.each do |e|
          lines << "  - #{e.title} (#{e.start_at.strftime("%a, %b %-d at %-I:%M %p")})"
        end
        lines.join("\n")
      end

      def notes_section
        return nil unless @telegram_user&.household

        count      = @telegram_user.household.notes.confirmed.count
        categories = @telegram_user.household.note_categories.order(:name).pluck(:name)

        count_label    = count.zero?      ? "No notes yet"      : "#{count} note#{"s" if count != 1}"
        category_label = categories.empty? ? "No categories yet" : categories.join(", ")
        "Notes: #{count_label}. Categories: #{category_label}."
      end

      def shopping_list_section
        return nil unless @telegram_user&.household

        list = @telegram_user.household.shopping_lists.order(created_at: :desc).first
        return nil unless list

        items = list.shopping_items.order(:name)
        return "Active shopping list: #{list.name} (empty)" if items.none?

        pending   = items.reject(&:purchased?).map(&:name)
        purchased = items.select(&:purchased?).map(&:name)

        lines = [ "Active shopping list: #{list.name}" ]
        lines << "  To buy: #{pending.join(", ")}"   if pending.any?
        lines << "  Bought: #{purchased.join(", ")}" if purchased.any?
        lines.join("\n")
      end
    end
  end
end

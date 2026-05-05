module Telegram
  class MessageFormatter
    def format_weekly_menu(menu)
      lines = [ "Menu for week of #{menu.week_start_date.strftime("%-d %b")}:" ]
      WeeklyMenu::DAYS.each do |day|
        day_meals = menu.meals.includes(:dish)
                        .select { |m| m.day_of_week == day }
                        .sort_by { |m| WeeklyMenu::MEAL_TYPES.index(m.meal_type) }
        next if day_meals.empty?

        slots = day_meals.map { |m| "#{m.meal_type.capitalize}: #{m.dish.name}" }.join(", ")
        lines << "  #{day.capitalize}: #{slots}"
      end
      lines.join("\n")
    end

    def format_shopping_list(shopping_list)
      items = shopping_list.shopping_items.order(:name)
      lines = [ "#{shopping_list.name}:" ]
      items.each do |item|
        mark = item.purchased? ? "✓" : "○"
        lines << "  #{mark} #{item.name}"
      end
      lines.join("\n")
    end

    def format_daily_digest(date:, events:, meals:)
      lines = [ "*Daily digest — #{date.strftime("%-d %b %Y")}*", "" ]

      lines << "*Events:*"
      if events.empty?
        lines << "No events today."
      else
        events.each do |event|
          time = event.all_day? ? "all day" : event.start_at.strftime("%H:%M")
          lines << "• #{time} #{event.title}"
        end
      end

      lines << ""
      lines << "*Meals:*"
      sorted_meals = meals.sort_by { |m| WeeklyMenu::MEAL_TYPES.index(m.meal_type) }
      if sorted_meals.empty?
        lines << "No meals planned today."
      else
        sorted_meals.each do |meal|
          lines << "• #{meal.meal_type.capitalize}: #{meal.dish.name}"
        end
      end

      lines.join("\n")
    end

    def format_expense_summary(expenses, period:)
      return "No expenses recorded for this #{period}." if expenses.empty?

      lines = [ "Expenses (#{period}):" ]

      expenses.group_by(&:currency).each do |currency, by_currency|
        rows = by_currency.group_by { |e| e.expense_category&.name || "Uncategorized" }
                          .sort_by { |cat, _| cat }
        rows.each do |category, exps|
          total = exps.sum(&:amount)
          count = exps.size
          lines << "  #{category}: #{format_amount(total, currency)} (#{entry_count(count)})"
        end
        grand = by_currency.sum(&:amount)
        lines << "  Total: #{format_amount(grand, currency)} (#{entry_count(by_currency.size)})"
      end

      lines.join("\n")
    end

    def format_note(note)
      visibility_icon = note.visibility == "private" ? "🔒 Personal" : "🌐 Public"
      category_label  = note.note_category&.name || "Uncategorised"
      timestamp       = note.created_at.strftime("%-d %b %Y")
      "*#{category_label}* · #{visibility_icon} · #{timestamp}\n\n#{note.content}"
    end

    private

    def format_amount(amount, currency)
      "#{format("%.2f", amount)} #{currency}"
    end

    def entry_count(n)
      n == 1 ? "1 entry" : "#{n} entries"
    end
  end
end

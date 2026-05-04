module Ai
  module Tools
    class PlanWeeklyMenuTool < BaseTool
      def self.tool_name = "plan_weekly_menu"
      def self.description = <<~DESC
        Plan a weekly menu for the household. Creates a WeeklyMenu record and saves each meal slot.
        Call list_dishes first to know what dishes are available.
        week_start_date must be a Monday in YYYY-MM-DD format.
      DESC

      def self.schema
        {
          "type"       => "object",
          "properties" => {
            "week_start_date" => {
              "type"        => "string",
              "description" => "Monday of the target week, YYYY-MM-DD"
            },
            "meals" => {
              "type"  => "array",
              "items" => {
                "type"       => "object",
                "properties" => {
                  "day"        => { "type" => "string", "enum" => WeeklyMenu::DAYS },
                  "meal_type"  => { "type" => "string", "enum" => WeeklyMenu::MEAL_TYPES },
                  "dish_name"  => { "type" => "string" }
                },
                "required" => [ "day", "meal_type", "dish_name" ]
              }
            }
          },
          "required" => [ "week_start_date", "meals" ]
        }
      end

      private

      def call(arguments, context)
        household = context.telegram_user&.household
        return ToolResult.err("No household found for this user.") unless household

        week_start = Date.parse(arguments["week_start_date"])
        menu = household.weekly_menus.find_or_initialize_by(week_start_date: week_start)
        menu.meals.destroy_all if menu.persisted?
        menu.save! unless menu.persisted?

        errors = []
        arguments["meals"].each do |slot|
          dish = household.dishes.find_by("LOWER(name) = ?", slot["dish_name"].downcase)
          unless dish
            errors << "Unknown dish: '#{slot["dish_name"]}'"
            next
          end

          meal = menu.meals.build(dish: dish, day_of_week: slot["day"], meal_type: slot["meal_type"])
          errors << meal.errors.full_messages.join(", ") unless meal.save
        end

        return ToolResult.err(errors.join("; ")) if errors.any?

        summary = format_menu(menu.reload)
        ToolResult.ok(summary)
      end

      def format_menu(menu)
        lines = [ "Menu for the week of #{menu.week_start_date.strftime("%b %-d")}:" ]
        WeeklyMenu::DAYS.each do |day|
          day_meals = menu.meals.select { |m| m.day_of_week == day }
                          .sort_by { |m| WeeklyMenu::MEAL_TYPES.index(m.meal_type) }
          next if day_meals.empty?

          slots = day_meals.map { |m| "#{m.meal_type}: #{m.dish.name}" }.join(", ")
          lines << "  #{day.capitalize}: #{slots}"
        end
        lines.join("\n")
      end
    end
  end
end

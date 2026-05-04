module Ai
  module Tools
    class SummarizeExpensesTool < BaseTool
      def self.tool_name = "summarize_expenses"
      def self.description = <<~DESC
        Summarize household expenses for a given period (week, month, or year).
        Optionally filter by a single category.
      DESC

      def self.schema
        {
          "type"       => "object",
          "properties" => {
            "period"   => {
              "type"        => "string",
              "enum"        => [ "week", "month", "year" ],
              "description" => "Time period to summarize"
            },
            "category" => {
              "type"        => "string",
              "description" => "Filter to a single category (optional)"
            }
          },
          "required" => [ "period" ]
        }
      end

      private

      def call(arguments, context)
        household = context.telegram_user&.household
        return ToolResult.err("No household found for this user.") unless household

        range    = date_range(arguments["period"])
        expenses = household.expenses.where(spent_on: range).includes(:expense_category)

        if arguments["category"].present?
          cat = ExpenseCategory.find_by("LOWER(name) = ?", arguments["category"].downcase)
          return ToolResult.err("Unknown category: '#{arguments["category"]}'.") unless cat
          expenses = expenses.where(expense_category: cat)
        end

        formatted = Telegram::MessageFormatter.new
                      .format_expense_summary(expenses.to_a, period: arguments["period"])
        ToolResult.ok(formatted)
      end

      def date_range(period)
        today = Date.current
        case period
        when "week"  then today.beginning_of_week..today.end_of_week
        when "month" then today.beginning_of_month..today.end_of_month
        when "year"  then today.beginning_of_year..today.end_of_year
        end
      end
    end
  end
end

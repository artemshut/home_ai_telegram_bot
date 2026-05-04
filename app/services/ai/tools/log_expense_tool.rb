module Ai
  module Tools
    class LogExpenseTool < BaseTool
      def self.tool_name = "log_expense"
      def self.description = <<~DESC
        Log a household expense. Provide the amount, a description, and optionally a category
        and date. If category is omitted it is guessed from the description.
      DESC

      def self.schema
        {
          "type"       => "object",
          "properties" => {
            "amount"      => { "type" => "number", "description" => "Amount spent (positive number)" },
            "description" => { "type" => "string", "description" => "What the expense was for" },
            "currency"    => { "type" => "string", "description" => "ISO 4217 currency code (default: EUR)" },
            "category"    => { "type" => "string", "description" => "Category name (guessed if omitted)" },
            "spent_on"    => { "type" => "string", "description" => "Date in YYYY-MM-DD (defaults to today)" }
          },
          "required" => [ "amount", "description" ]
        }
      end

      private

      def call(arguments, context)
        household = context.telegram_user&.household
        return ToolResult.err("No household found for this user.") unless household

        category = resolve_category(arguments["category"], arguments["description"])
        return ToolResult.err("No expense categories found. Run db:seed first.") unless category

        spent_on = arguments["spent_on"] ? Date.parse(arguments["spent_on"]) : Date.current

        expense = household.expenses.create!(
          expense_category: category,
          telegram_user:    context.telegram_user,
          amount:           arguments["amount"],
          currency:         arguments["currency"].presence || "EUR",
          description:      arguments["description"],
          spent_on:         spent_on
        )

        ToolResult.ok(
          "Logged #{format_amount(expense.amount, expense.currency)} for " \
          "'#{expense.description}' under #{category.name} on #{expense.spent_on.strftime("%-d %b")}."
        )
      rescue ArgumentError => e
        ToolResult.err("Invalid date: #{e.message}")
      end

      def resolve_category(name, description)
        if name.present?
          cat = ExpenseCategory.find_by("LOWER(name) = ?", name.downcase)
          return cat if cat
        end
        guessed = Expenses::Categorizer.new.call(description)
        ExpenseCategory.find_by(name: guessed) || ExpenseCategory.find_by(name: "Other")
      end

      def format_amount(amount, currency)
        "#{format("%.2f", amount)} #{currency}"
      end
    end
  end
end

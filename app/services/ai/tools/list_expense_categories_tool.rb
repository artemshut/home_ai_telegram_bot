module Ai
  module Tools
    class ListExpenseCategoriesTool < BaseTool
      def self.tool_name = "list_expense_categories"
      def self.description = "List all available expense categories."
      def self.schema
        { "type" => "object", "properties" => {} }
      end

      private

      def call(_arguments, _context)
        names = ExpenseCategory.order(:name).pluck(:name)
        return ToolResult.err("No categories found.") if names.empty?

        ToolResult.ok(names.join(", "))
      end
    end
  end
end

module Ai
  module Tools
    class ListDishesTool < BaseTool
      def self.tool_name = "list_dishes"
      def self.description = "List all dishes in the household's dish library."
      def self.schema
        {
          "type"       => "object",
          "properties" => {}
        }
      end

      private

      def call(_arguments, context)
        household = context.telegram_user&.household
        return ToolResult.err("No household found for this user.") unless household

        dishes = household.dishes.order(:name)
        return ToolResult.ok("The dish library is empty.") if dishes.none?

        lines = dishes.map.with_index(1) { |d, i| "#{i}. #{d.name}" }
        ToolResult.ok(lines.join("\n"))
      end
    end
  end
end

module Ai
  module Tools
    class AddDishTool < BaseTool
      def self.tool_name = "add_dish"
      def self.description = "Add a dish to the household's dish library."
      def self.schema
        {
          "type" => "object",
          "properties" => {
            "name"        => { "type" => "string", "description" => "Dish name" },
            "description" => { "type" => "string", "description" => "Optional description" }
          },
          "required" => [ "name" ]
        }
      end

      private

      def call(arguments, context)
        household = context.telegram_user&.household
        return ToolResult.err("No household found for this user.") unless household

        dish = household.dishes.find_or_initialize_by(name: arguments["name"])

        if dish.persisted?
          return ToolResult.err("'#{dish.name}' is already in the dish library.")
        end

        dish.description = arguments["description"]

        if dish.save
          ToolResult.ok("Added '#{dish.name}' to the dish library.")
        else
          ToolResult.err(dish.errors.full_messages.join(", "))
        end
      end
    end
  end
end

module Ai
  module Tools
    class CreateShoppingListTool < BaseTool
      def self.tool_name = "create_shopping_list"
      def self.description = <<~DESC
        Create a shopping list. Either generate items from the household's most recent weekly menu
        (set from_menu to true), or provide an explicit list of items.
      DESC

      def self.schema
        {
          "type"       => "object",
          "properties" => {
            "name"      => { "type" => "string", "description" => "Name for the shopping list" },
            "from_menu" => { "type" => "boolean", "description" => "Populate from the most recent weekly menu" },
            "items"     => {
              "type"  => "array",
              "items" => { "type" => "string" },
              "description" => "Item names to add (used when from_menu is false)"
            }
          },
          "required" => [ "name" ]
        }
      end

      private

      def call(arguments, context)
        household = context.telegram_user&.household
        return ToolResult.err("No household found for this user.") unless household

        list = household.shopping_lists.create!(name: arguments["name"])

        if arguments["from_menu"]
          menu = household.weekly_menus.order(week_start_date: :desc).first
          return ToolResult.err("No weekly menu found to build a list from.") unless menu

          dish_names = menu.meals.includes(:dish).map { |m| m.dish.name }.uniq.sort
          dish_names.each { |name| list.shopping_items.create!(name: name) }
        else
          Array(arguments["items"]).each { |item| list.shopping_items.create!(name: item) }
        end

        context.last_shopping_list = list
        ToolResult.ok("Created shopping list '#{list.name}' with #{list.shopping_items.count} items.")
      end
    end
  end
end

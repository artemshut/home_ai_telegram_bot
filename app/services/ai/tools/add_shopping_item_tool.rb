module Ai
  module Tools
    class AddShoppingItemTool < BaseTool
      def self.tool_name = "add_shopping_item"
      def self.description = "Add an item to the household's most recent shopping list."
      def self.schema
        {
          "type"       => "object",
          "properties" => {
            "name" => { "type" => "string", "description" => "Item to add" }
          },
          "required" => [ "name" ]
        }
      end

      private

      def call(arguments, context)
        household = context.telegram_user&.household
        return ToolResult.err("No household found for this user.") unless household

        list = household.shopping_lists.order(created_at: :desc).first
        return ToolResult.err("No shopping list found. Create one first.") unless list

        item = list.shopping_items.find_or_initialize_by(name: arguments["name"])
        return ToolResult.err("'#{item.name}' is already on the list.") if item.persisted?

        item.save!
        context.last_shopping_list = list
        ToolResult.ok("Added '#{item.name}' to '#{list.name}'.")
      end
    end
  end
end

require "test_helper"

class Ai::Tools::AddShoppingItemToolTest < ActiveSupport::TestCase
  setup do
    @household = Household.create!(name: "TestHousehold")
    @user = TelegramUser.create!(telegram_id: 6_500_001, household: @household)
    @list = ShoppingList.create!(household: @household, name: "Groceries")
    @context = Ai::ToolContext.new(telegram_user: @user, chat_id: 1)
    @tool = Ai::Tools::AddShoppingItemTool.new
  end

  test "adds an item to the most recent list" do
    result = @tool.execute({ "name" => "Milk" }, @context)
    assert result.success
    assert_equal 1, @list.shopping_items.count
  end

  test "returns error when item already exists" do
    ShoppingItem.create!(shopping_list: @list, name: "Milk")
    result = @tool.execute({ "name" => "Milk" }, @context)
    assert_not result.success
    assert_includes result.to_s, "already"
  end

  test "returns error when no shopping list exists" do
    @list.destroy!
    result = @tool.execute({ "name" => "Milk" }, @context)
    assert_not result.success
    assert_includes result.to_s, "No shopping list"
  end

  test "sets last_shopping_list on context" do
    @tool.execute({ "name" => "Milk" }, @context)
    assert_equal @list, @context.last_shopping_list
  end

  test "returns error when user has no household" do
    user = TelegramUser.create!(telegram_id: 6_500_002)
    ctx  = Ai::ToolContext.new(telegram_user: user, chat_id: 1)
    result = @tool.execute({ "name" => "Milk" }, ctx)
    assert_not result.success
  end

  test "raises ArgumentError when name is missing" do
    assert_raises(ArgumentError) { @tool.execute({}, @context) }
  end
end

require "test_helper"

class Ai::Tools::CreateShoppingListToolTest < ActiveSupport::TestCase
  setup do
    @household = Household.create!(name: "TestHousehold")
    @user = TelegramUser.create!(telegram_id: 6_400_001, household: @household)
    @context = Ai::ToolContext.new(telegram_user: @user, chat_id: 1)
    @tool = Ai::Tools::CreateShoppingListTool.new
  end

  test "creates a shopping list with freeform items" do
    result = @tool.execute({ "name" => "Groceries", "items" => [ "Milk", "Eggs" ] }, @context)
    assert result.success
    list = @household.shopping_lists.last
    assert_equal "Groceries", list.name
    assert_equal 2, list.shopping_items.count
  end

  test "creates an empty list when no items provided" do
    result = @tool.execute({ "name" => "Groceries" }, @context)
    assert result.success
    assert_equal 0, @household.shopping_lists.last.shopping_items.count
  end

  test "creates list from menu" do
    menu = WeeklyMenu.create!(household: @household, week_start_date: "2026-05-04")
    pasta = Dish.create!(household: @household, name: "Pasta")
    soup  = Dish.create!(household: @household, name: "Soup")
    Meal.create!(weekly_menu: menu, dish: pasta, day_of_week: "monday", meal_type: "dinner")
    Meal.create!(weekly_menu: menu, dish: soup,  day_of_week: "tuesday", meal_type: "lunch")

    result = @tool.execute({ "name" => "This week", "from_menu" => true }, @context)
    assert result.success
    item_names = @household.shopping_lists.last.shopping_items.pluck(:name).sort
    assert_equal %w[Pasta Soup], item_names
  end

  test "returns error when from_menu is true but no menu exists" do
    result = @tool.execute({ "name" => "This week", "from_menu" => true }, @context)
    assert_not result.success
    assert_includes result.to_s, "No weekly menu"
  end

  test "sets last_shopping_list on context" do
    @tool.execute({ "name" => "Groceries", "items" => [ "Milk" ] }, @context)
    assert_not_nil @context.last_shopping_list
    assert_equal "Groceries", @context.last_shopping_list.name
  end

  test "returns error when user has no household" do
    user = TelegramUser.create!(telegram_id: 6_400_002)
    ctx  = Ai::ToolContext.new(telegram_user: user, chat_id: 1)
    result = @tool.execute({ "name" => "Groceries" }, ctx)
    assert_not result.success
  end

  test "raises ArgumentError when name is missing" do
    assert_raises(ArgumentError) { @tool.execute({}, @context) }
  end
end

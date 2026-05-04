require "test_helper"

class Ai::Tools::ListDishesToolTest < ActiveSupport::TestCase
  setup do
    @household = Household.create!(name: "TestHousehold")
    @user = TelegramUser.create!(telegram_id: 6_200_001, household: @household)
    @context = Ai::ToolContext.new(telegram_user: @user, chat_id: 1)
    @tool = Ai::Tools::ListDishesTool.new
  end

  test "returns empty message when library has no dishes" do
    result = @tool.execute({}, @context)
    assert result.success
    assert_includes result.to_s, "empty"
  end

  test "lists dishes alphabetically" do
    Dish.create!(household: @household, name: "Soup")
    Dish.create!(household: @household, name: "Pasta")
    result = @tool.execute({}, @context)
    assert result.success
    assert result.to_s.index("Pasta") < result.to_s.index("Soup")
  end

  test "numbers the dishes" do
    Dish.create!(household: @household, name: "Pasta")
    result = @tool.execute({}, @context)
    assert_includes result.to_s, "1."
  end

  test "returns error when user has no household" do
    user = TelegramUser.create!(telegram_id: 6_200_002)
    ctx = Ai::ToolContext.new(telegram_user: user, chat_id: 1)
    result = @tool.execute({}, ctx)
    assert_not result.success
  end
end

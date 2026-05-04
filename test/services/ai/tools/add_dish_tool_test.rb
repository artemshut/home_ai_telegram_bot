require "test_helper"

class Ai::Tools::AddDishToolTest < ActiveSupport::TestCase
  setup do
    @household = Household.create!(name: "TestHousehold")
    @user = TelegramUser.create!(telegram_id: 6_100_001, household: @household)
    @context = Ai::ToolContext.new(telegram_user: @user, chat_id: 1)
    @tool = Ai::Tools::AddDishTool.new
  end

  test "adds a dish and returns success message" do
    result = @tool.execute({ "name" => "Pasta" }, @context)
    assert result.success
    assert_includes result.to_s, "Pasta"
    assert_equal 1, @household.dishes.count
  end

  test "returns error when dish already exists" do
    Dish.create!(household: @household, name: "Pasta")
    result = @tool.execute({ "name" => "Pasta" }, @context)
    assert_not result.success
    assert_includes result.to_s, "already"
  end

  test "returns error when user has no household" do
    user = TelegramUser.create!(telegram_id: 6_100_002)
    ctx = Ai::ToolContext.new(telegram_user: user, chat_id: 1)
    result = @tool.execute({ "name" => "Pasta" }, ctx)
    assert_not result.success
  end

  test "saves optional description" do
    @tool.execute({ "name" => "Risotto", "description" => "Creamy rice dish" }, @context)
    assert_equal "Creamy rice dish", @household.dishes.find_by(name: "Risotto").description
  end

  test "raises ArgumentError when name is missing" do
    assert_raises(ArgumentError) { @tool.execute({}, @context) }
  end
end

require "test_helper"

class Ai::Tools::PlanWeeklyMenuToolTest < ActiveSupport::TestCase
  setup do
    @household = Household.create!(name: "TestHousehold")
    @user = TelegramUser.create!(telegram_id: 6_300_001, household: @household)
    @context = Ai::ToolContext.new(telegram_user: @user, chat_id: 1)
    @tool = Ai::Tools::PlanWeeklyMenuTool.new
    @pasta = Dish.create!(household: @household, name: "Pasta")
    @soup  = Dish.create!(household: @household, name: "Soup")
  end

  def args(meals: nil)
    {
      "week_start_date" => "2026-05-04",
      "meals" => meals || [
        { "day" => "monday", "meal_type" => "dinner", "dish_name" => "Pasta" }
      ]
    }
  end

  test "creates a WeeklyMenu record" do
    assert_difference("WeeklyMenu.count") do
      @tool.execute(args, @context)
    end
  end

  test "creates Meal records for each slot" do
    @tool.execute(args(meals: [
      { "day" => "monday", "meal_type" => "dinner",  "dish_name" => "Pasta" },
      { "day" => "tuesday", "meal_type" => "lunch", "dish_name" => "Soup" }
    ]), @context)

    menu = WeeklyMenu.last
    assert_equal 2, menu.meals.count
  end

  test "returns a formatted summary on success" do
    result = @tool.execute(args, @context)
    assert result.success
    assert_includes result.to_s, "Monday"
    assert_includes result.to_s, "Pasta"
  end

  test "replaces existing menu for the same week" do
    @tool.execute(args, @context)
    assert_no_difference("WeeklyMenu.count") do
      result = @tool.execute(args(meals: [
        { "day" => "wednesday", "meal_type" => "dinner", "dish_name" => "Soup" }
      ]), @context)
      assert result.success
    end
    menu = WeeklyMenu.find_by(week_start_date: "2026-05-04")
    assert_equal 1, menu.meals.count
    assert_equal "wednesday", menu.meals.first.day_of_week
  end

  test "returns error for unknown dish name" do
    result = @tool.execute(args(meals: [
      { "day" => "monday", "meal_type" => "dinner", "dish_name" => "UnknownDish" }
    ]), @context)
    assert_not result.success
    assert_includes result.to_s, "UnknownDish"
  end

  test "dish lookup is case-insensitive" do
    result = @tool.execute(args(meals: [
      { "day" => "monday", "meal_type" => "dinner", "dish_name" => "pasta" }
    ]), @context)
    assert result.success
  end

  test "returns error when user has no household" do
    user = TelegramUser.create!(telegram_id: 6_300_002)
    ctx = Ai::ToolContext.new(telegram_user: user, chat_id: 1)
    result = @tool.execute(args, ctx)
    assert_not result.success
  end

  test "raises ArgumentError when required args missing" do
    assert_raises(ArgumentError) { @tool.execute({}, @context) }
  end
end

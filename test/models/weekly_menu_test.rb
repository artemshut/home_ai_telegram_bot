require "test_helper"

class WeeklyMenuTest < ActiveSupport::TestCase
  setup do
    @household = Household.create!(name: "TestHousehold")
  end

  test "valid with household and week_start_date" do
    menu = WeeklyMenu.new(household: @household, week_start_date: Date.new(2026, 5, 4))
    assert menu.valid?
  end

  test "invalid without week_start_date" do
    menu = WeeklyMenu.new(household: @household, week_start_date: nil)
    assert_not menu.valid?
    assert_includes menu.errors[:week_start_date], "can't be blank"
  end

  test "week_start_date must be unique per household" do
    date = Date.new(2026, 5, 4)
    WeeklyMenu.create!(household: @household, week_start_date: date)
    duplicate = WeeklyMenu.new(household: @household, week_start_date: date)
    assert_not duplicate.valid?
    assert duplicate.errors[:week_start_date].any?
  end

  test "same date allowed for different households" do
    other = Household.create!(name: "OtherHousehold")
    date = Date.new(2026, 5, 4)
    WeeklyMenu.create!(household: @household, week_start_date: date)
    menu = WeeklyMenu.new(household: other, week_start_date: date)
    assert menu.valid?
  end

  test "has many meals" do
    menu = WeeklyMenu.create!(household: @household, week_start_date: Date.new(2026, 5, 4))
    dish = Dish.create!(household: @household, name: "Pasta")
    meal = Meal.create!(weekly_menu: menu, dish: dish, day_of_week: "monday", meal_type: "dinner")
    assert_includes menu.meals, meal
  end

  test "has many dishes through meals" do
    menu = WeeklyMenu.create!(household: @household, week_start_date: Date.new(2026, 5, 4))
    dish = Dish.create!(household: @household, name: "Soup")
    Meal.create!(weekly_menu: menu, dish: dish, day_of_week: "tuesday", meal_type: "lunch")
    assert_includes menu.dishes, dish
  end

  test "DAYS constant covers the full week" do
    assert_equal 7, WeeklyMenu::DAYS.length
    assert_includes WeeklyMenu::DAYS, "monday"
    assert_includes WeeklyMenu::DAYS, "sunday"
  end

  test "MEAL_TYPES constant has expected values" do
    assert_equal %w[breakfast lunch dinner], WeeklyMenu::MEAL_TYPES
  end
end

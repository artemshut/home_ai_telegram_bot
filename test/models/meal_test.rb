require "test_helper"

class MealTest < ActiveSupport::TestCase
  setup do
    @household = Household.create!(name: "TestHousehold")
    @menu = WeeklyMenu.create!(household: @household, week_start_date: Date.new(2026, 5, 4))
    @dish = Dish.create!(household: @household, name: "Pasta")
  end

  def build_meal(overrides = {})
    Meal.new({ weekly_menu: @menu, dish: @dish, day_of_week: "monday", meal_type: "dinner" }.merge(overrides))
  end

  test "valid with required fields" do
    assert build_meal.valid?
  end

  test "invalid without day_of_week" do
    meal = build_meal(day_of_week: nil)
    assert_not meal.valid?
    assert_includes meal.errors[:day_of_week], "can't be blank"
  end

  test "invalid with unknown day_of_week" do
    meal = build_meal(day_of_week: "funday")
    assert_not meal.valid?
    assert meal.errors[:day_of_week].any?
  end

  test "invalid without meal_type" do
    meal = build_meal(meal_type: nil)
    assert_not meal.valid?
    assert_includes meal.errors[:meal_type], "can't be blank"
  end

  test "invalid with unknown meal_type" do
    meal = build_meal(meal_type: "brunch")
    assert_not meal.valid?
    assert meal.errors[:meal_type].any?
  end

  test "day and meal_type combination must be unique per menu" do
    build_meal.save!
    duplicate = build_meal
    assert_not duplicate.valid?
    assert duplicate.errors[:day_of_week].any?
  end

  test "same day and meal_type allowed in different menus" do
    other_menu = WeeklyMenu.create!(household: @household, week_start_date: Date.new(2026, 5, 11))
    build_meal.save!
    meal = Meal.new(weekly_menu: other_menu, dish: @dish, day_of_week: "monday", meal_type: "dinner")
    assert meal.valid?
  end

  test "for_day returns meals on the given day" do
    tuesday_dish = Dish.create!(household: @household, name: "Salad")
    build_meal(day_of_week: "monday", meal_type: "lunch").save!
    Meal.create!(weekly_menu: @menu, dish: tuesday_dish, day_of_week: "tuesday", meal_type: "lunch")

    results = Meal.for_day("tuesday")
    assert results.all? { |m| m.day_of_week == "tuesday" }
    assert_not results.map(&:day_of_week).include?("monday")
  end

  test "belongs to weekly_menu and dish" do
    meal = build_meal
    meal.save!
    assert_equal @menu, meal.weekly_menu
    assert_equal @dish, meal.dish
  end
end

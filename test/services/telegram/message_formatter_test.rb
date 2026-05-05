require "test_helper"

class Telegram::MessageFormatterTest < ActiveSupport::TestCase
  setup do
    @formatter = Telegram::MessageFormatter.new
    @date = Date.new(2026, 5, 5)
    @household = Household.create!(name: "Test")
    @dish_a = Dish.create!(household: @household, name: "Oatmeal")
    @dish_b = Dish.create!(household: @household, name: "Soup")
    @dish_c = Dish.create!(household: @household, name: "Pasta")
  end

  def build_event(title:, start_at:, all_day: false)
    CalendarEvent.new(
      household: @household,
      title: title,
      start_at: start_at,
      end_at: start_at + 1.hour,
      all_day: all_day,
      status: "confirmed"
    )
  end

  def build_meal(dish:, meal_type:)
    menu = WeeklyMenu.new(household: @household, week_start_date: @date.beginning_of_week)
    Meal.new(weekly_menu: menu, dish: dish, day_of_week: "tuesday", meal_type: meal_type)
  end

  test "includes date header" do
    result = @formatter.format_daily_digest(date: @date, events: [], meals: [])
    assert_includes result, "*Daily digest — 5 May 2026*"
  end

  test "shows both sections when populated" do
    events = [ build_event(title: "Doctor", start_at: Time.zone.parse("2026-05-05 09:00")) ]
    meals  = [ build_meal(dish: @dish_c, meal_type: "dinner") ]

    result = @formatter.format_daily_digest(date: @date, events: events, meals: meals)
    assert_includes result, "09:00 Doctor"
    assert_includes result, "Dinner: Pasta"
  end

  test "shows no events message when events empty" do
    result = @formatter.format_daily_digest(date: @date, events: [], meals: [])
    assert_includes result, "No events today."
  end

  test "shows no meals message when meals empty" do
    result = @formatter.format_daily_digest(date: @date, events: [], meals: [])
    assert_includes result, "No meals planned today."
  end

  test "all-day event shows 'all day' instead of time" do
    events = [ build_event(title: "Birthday", start_at: Time.zone.parse("2026-05-05 00:00"), all_day: true) ]
    result = @formatter.format_daily_digest(date: @date, events: events, meals: [])
    assert_includes result, "all day Birthday"
    assert_not_includes result, "00:00"
  end

  test "meals sorted breakfast then lunch then dinner" do
    meals = [
      build_meal(dish: @dish_c, meal_type: "dinner"),
      build_meal(dish: @dish_a, meal_type: "breakfast"),
      build_meal(dish: @dish_b, meal_type: "lunch")
    ]
    result = @formatter.format_daily_digest(date: @date, events: [], meals: meals)
    breakfast_pos = result.index("Breakfast")
    lunch_pos     = result.index("Lunch")
    dinner_pos    = result.index("Dinner")
    assert breakfast_pos < lunch_pos
    assert lunch_pos < dinner_pos
  end

  test "uses single-asterisk markdown for headers" do
    result = @formatter.format_daily_digest(date: @date, events: [], meals: [])
    assert_includes result, "*Daily digest"
    assert_includes result, "*Events:*"
    assert_includes result, "*Meals:*"
    assert_not_includes result, "**"
  end
end

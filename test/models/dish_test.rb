require "test_helper"

class DishTest < ActiveSupport::TestCase
  setup do
    @household = Household.create!(name: "TestHousehold")
  end

  test "valid with name and household" do
    dish = Dish.new(household: @household, name: "Pasta")
    assert dish.valid?
  end

  test "invalid without name" do
    dish = Dish.new(household: @household, name: "")
    assert_not dish.valid?
    assert_includes dish.errors[:name], "can't be blank"
  end

  test "name must be unique within household" do
    Dish.create!(household: @household, name: "Pasta")
    duplicate = Dish.new(household: @household, name: "Pasta")
    assert_not duplicate.valid?
    assert duplicate.errors[:name].any?
  end

  test "same name allowed in different households" do
    other = Household.create!(name: "OtherHousehold")
    Dish.create!(household: @household, name: "Pasta")
    dish = Dish.new(household: other, name: "Pasta")
    assert dish.valid?
  end

  test "belongs to household" do
    dish = Dish.create!(household: @household, name: "Soup")
    assert_equal @household, dish.household
  end
end

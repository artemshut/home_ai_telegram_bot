require "test_helper"

class ShoppingListTest < ActiveSupport::TestCase
  setup do
    @household = Household.create!(name: "TestHousehold")
  end

  test "valid with name and household" do
    list = ShoppingList.new(household: @household, name: "Groceries")
    assert list.valid?
  end

  test "invalid without name" do
    list = ShoppingList.new(household: @household, name: "")
    assert_not list.valid?
    assert_includes list.errors[:name], "can't be blank"
  end

  test "belongs to household" do
    list = ShoppingList.create!(household: @household, name: "Groceries")
    assert_equal @household, list.household
  end

  test "has many shopping items" do
    list = ShoppingList.create!(household: @household, name: "Groceries")
    list.shopping_items.create!(name: "Milk")
    list.shopping_items.create!(name: "Bread")
    assert_equal 2, list.shopping_items.count
  end

  test "destroys shopping items when deleted" do
    list = ShoppingList.create!(household: @household, name: "Groceries")
    list.shopping_items.create!(name: "Milk")
    assert_difference("ShoppingItem.count", -1) { list.destroy! }
  end

  test "optional weekly menu association" do
    list = ShoppingList.new(household: @household, name: "Groceries")
    assert list.valid?
  end
end

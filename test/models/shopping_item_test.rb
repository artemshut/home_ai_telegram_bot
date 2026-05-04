require "test_helper"

class ShoppingItemTest < ActiveSupport::TestCase
  setup do
    @household = Household.create!(name: "TestHousehold")
    @list = ShoppingList.create!(household: @household, name: "Groceries")
  end

  test "valid with name and shopping list" do
    item = ShoppingItem.new(shopping_list: @list, name: "Milk")
    assert item.valid?
  end

  test "invalid without name" do
    item = ShoppingItem.new(shopping_list: @list, name: "")
    assert_not item.valid?
    assert_includes item.errors[:name], "can't be blank"
  end

  test "name must be unique within list" do
    ShoppingItem.create!(shopping_list: @list, name: "Milk")
    dup = ShoppingItem.new(shopping_list: @list, name: "Milk")
    assert_not dup.valid?
    assert dup.errors[:name].any?
  end

  test "name uniqueness is case-insensitive" do
    ShoppingItem.create!(shopping_list: @list, name: "Milk")
    dup = ShoppingItem.new(shopping_list: @list, name: "milk")
    assert_not dup.valid?
  end

  test "same name allowed in different lists" do
    other = ShoppingList.create!(household: @household, name: "Other")
    ShoppingItem.create!(shopping_list: @list, name: "Milk")
    item = ShoppingItem.new(shopping_list: other, name: "Milk")
    assert item.valid?
  end

  test "defaults to not purchased" do
    item = ShoppingItem.create!(shopping_list: @list, name: "Eggs")
    assert_not item.purchased?
  end

  test "can be marked as purchased" do
    item = ShoppingItem.create!(shopping_list: @list, name: "Eggs")
    item.update!(purchased: true)
    assert item.purchased?
  end
end

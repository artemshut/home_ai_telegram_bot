require "test_helper"

class ExpenseTest < ActiveSupport::TestCase
  setup do
    @household = Household.create!(name: "TestHousehold")
    @category  = ExpenseCategory.create!(name: "Groceries")
  end

  def build(**attrs)
    Expense.new({
      household:        @household,
      expense_category: @category,
      amount:           12.50,
      description:      "Supermarket run",
      currency:         "EUR",
      spent_on:         Date.current
    }.merge(attrs))
  end

  test "valid with all required fields" do
    assert build.valid?
  end

  test "invalid without amount" do
    assert_not build(amount: nil).valid?
  end

  test "amount must be positive" do
    assert_not build(amount: -1).valid?
    assert_not build(amount: 0).valid?
    assert build(amount: 0.01).valid?
  end

  test "invalid without description" do
    assert_not build(description: "").valid?
  end

  test "invalid without currency" do
    assert_not build(currency: "").valid?
  end

  test "invalid without spent_on" do
    assert_not build(spent_on: nil).valid?
  end

  test "telegram_user is optional" do
    assert build(telegram_user: nil).valid?
  end
end

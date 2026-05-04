require "test_helper"

class Ai::Tools::SummarizeExpensesToolTest < ActiveSupport::TestCase
  setup do
    @household = Household.create!(name: "TestHousehold")
    @user      = TelegramUser.create!(telegram_id: 6_800_001, household: @household)
    @context   = Ai::ToolContext.new(telegram_user: @user, chat_id: 1)
    @tool      = Ai::Tools::SummarizeExpensesTool.new
    @groceries = ExpenseCategory.create!(name: "Groceries")
    @dining    = ExpenseCategory.create!(name: "Dining")
  end

  def create_expense(amount:, category:, spent_on: Date.current, currency: "EUR")
    @household.expenses.create!(
      expense_category: category,
      amount:           amount,
      currency:         currency,
      description:      "test",
      spent_on:         spent_on
    )
  end

  test "returns no-expenses message when there are none" do
    result = @tool.execute({ "period" => "month" }, @context)
    assert result.success
    assert_includes result.to_s, "No expenses"
  end

  test "summarizes expenses for the month" do
    create_expense(amount: 30.0, category: @groceries)
    create_expense(amount: 15.0, category: @dining)
    result = @tool.execute({ "period" => "month" }, @context)
    assert result.success
    assert_includes result.to_s, "Groceries"
    assert_includes result.to_s, "Dining"
    assert_includes result.to_s, "45.00"
  end

  test "excludes expenses outside the period" do
    create_expense(amount: 10.0, category: @groceries, spent_on: 2.months.ago.to_date)
    result = @tool.execute({ "period" => "month" }, @context)
    assert result.success
    assert_includes result.to_s, "No expenses"
  end

  test "filters by category when specified" do
    create_expense(amount: 30.0, category: @groceries)
    create_expense(amount: 15.0, category: @dining)
    result = @tool.execute({ "period" => "month", "category" => "Groceries" }, @context)
    assert result.success
    assert_includes result.to_s, "Groceries"
    assert_not_includes result.to_s, "Dining"
  end

  test "returns error for unknown category" do
    result = @tool.execute({ "period" => "month", "category" => "Nonexistent" }, @context)
    assert_not result.success
    assert_includes result.to_s, "Unknown category"
  end

  test "returns error when user has no household" do
    user   = TelegramUser.create!(telegram_id: 6_800_002)
    ctx    = Ai::ToolContext.new(telegram_user: user, chat_id: 1)
    result = @tool.execute({ "period" => "month" }, ctx)
    assert_not result.success
  end

  test "raises ArgumentError when period is missing" do
    assert_raises(ArgumentError) { @tool.execute({}, @context) }
  end
end

require "test_helper"

class Ai::Tools::LogExpenseToolTest < ActiveSupport::TestCase
  setup do
    @household  = Household.create!(name: "TestHousehold")
    @user       = TelegramUser.create!(telegram_id: 6_600_001, household: @household)
    @context    = Ai::ToolContext.new(telegram_user: @user, chat_id: 1)
    @tool       = Ai::Tools::LogExpenseTool.new
    @groceries  = ExpenseCategory.create!(name: "Groceries")
    ExpenseCategory.create!(name: "Other")
  end

  test "creates an expense with explicit category" do
    result = @tool.execute({ "amount" => 25.0, "description" => "market trip", "category" => "Groceries" }, @context)
    assert result.success
    assert_equal 1, @household.expenses.count
    assert_equal @groceries, @household.expenses.last.expense_category
  end

  test "guesses category from description when omitted" do
    result = @tool.execute({ "amount" => 10.0, "description" => "supermarket run" }, @context)
    assert result.success
    assert_equal "Groceries", @household.expenses.last.expense_category.name
  end

  test "falls back to Other when no category matches" do
    result = @tool.execute({ "amount" => 5.0, "description" => "random purchase" }, @context)
    assert result.success
    assert_equal "Other", @household.expenses.last.expense_category.name
  end

  test "uses today as default date" do
    @tool.execute({ "amount" => 8.0, "description" => "coffee" }, @context)
    assert_equal Date.current, @household.expenses.last.spent_on
  end

  test "accepts an explicit spent_on date" do
    @tool.execute({ "amount" => 8.0, "description" => "coffee", "spent_on" => "2026-04-01" }, @context)
    assert_equal Date.new(2026, 4, 1), @household.expenses.last.spent_on
  end

  test "accepts an explicit currency" do
    @tool.execute({ "amount" => 10.0, "description" => "gas", "currency" => "USD" }, @context)
    assert_equal "USD", @household.expenses.last.currency
  end

  test "defaults to EUR when currency is omitted" do
    @tool.execute({ "amount" => 10.0, "description" => "gas" }, @context)
    assert_equal "EUR", @household.expenses.last.currency
  end

  test "returns error when user has no household" do
    user   = TelegramUser.create!(telegram_id: 6_600_002)
    ctx    = Ai::ToolContext.new(telegram_user: user, chat_id: 1)
    result = @tool.execute({ "amount" => 5.0, "description" => "thing" }, ctx)
    assert_not result.success
  end

  test "raises ArgumentError when required args missing" do
    assert_raises(ArgumentError) { @tool.execute({}, @context) }
    assert_raises(ArgumentError) { @tool.execute({ "amount" => 5.0 }, @context) }
  end
end

require "test_helper"

class Ai::Tools::ListExpenseCategoriesToolTest < ActiveSupport::TestCase
  setup do
    @user    = TelegramUser.create!(telegram_id: 6_700_001)
    @context = Ai::ToolContext.new(telegram_user: @user, chat_id: 1)
    @tool    = Ai::Tools::ListExpenseCategoriesTool.new
  end

  test "returns error when no categories exist" do
    result = @tool.execute({}, @context)
    assert_not result.success
  end

  test "lists category names" do
    ExpenseCategory.create!(name: "Groceries")
    ExpenseCategory.create!(name: "Dining")
    result = @tool.execute({}, @context)
    assert result.success
    assert_includes result.to_s, "Groceries"
    assert_includes result.to_s, "Dining"
  end
end

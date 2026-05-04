require "test_helper"

class ExpenseCategoryTest < ActiveSupport::TestCase
  test "valid with a name" do
    cat = ExpenseCategory.new(name: "Food")
    assert cat.valid?
  end

  test "invalid without name" do
    cat = ExpenseCategory.new(name: "")
    assert_not cat.valid?
    assert_includes cat.errors[:name], "can't be blank"
  end

  test "name must be unique" do
    ExpenseCategory.create!(name: "Groceries")
    dup = ExpenseCategory.new(name: "Groceries")
    assert_not dup.valid?
    assert dup.errors[:name].any?
  end

  test "DEFAULT_NAMES lists all seeded categories" do
    assert_includes ExpenseCategory::DEFAULT_NAMES, "Groceries"
    assert_includes ExpenseCategory::DEFAULT_NAMES, "Other"
    assert_equal 8, ExpenseCategory::DEFAULT_NAMES.size
  end
end

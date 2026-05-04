require "test_helper"

class Expenses::CategorizerTest < ActiveSupport::TestCase
  setup do
    @categorizer = Expenses::Categorizer.new
  end

  test "matches Groceries keywords" do
    assert_equal "Groceries", @categorizer.call("went to the supermarket")
    assert_equal "Groceries", @categorizer.call("bought food at the shop")
  end

  test "matches Dining keywords" do
    assert_equal "Dining", @categorizer.call("lunch at a restaurant")
    assert_equal "Dining", @categorizer.call("morning coffee")
  end

  test "matches Transport keywords" do
    assert_equal "Transport", @categorizer.call("taxi to the airport")
    assert_equal "Transport", @categorizer.call("fuel for the car")
  end

  test "matches Health keywords" do
    assert_equal "Health", @categorizer.call("pharmacy pickup")
    assert_equal "Health", @categorizer.call("doctor visit")
  end

  test "falls back to Other for unknown description" do
    assert_equal "Other", @categorizer.call("random thing")
    assert_equal "Other", @categorizer.call("")
  end

  test "matching is case-insensitive" do
    assert_equal "Groceries", @categorizer.call("SUPERMARKET")
  end
end

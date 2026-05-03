require "test_helper"

class HomeAiTelegramBot::Ai::ToolResultTest < ActiveSupport::TestCase
  ToolResult = HomeAiTelegramBot::Ai::ToolResult

  test "ok creates a successful result" do
    result = ToolResult.ok("some data")
    assert result.success
    assert_equal "some data", result.data
    assert_nil result.error
  end

  test "err creates a failure result" do
    result = ToolResult.err("something went wrong")
    assert_not result.success
    assert_equal "something went wrong", result.error
    assert_nil result.data
  end

  test "to_s returns data for successful result" do
    result = ToolResult.ok("dish added")
    assert_equal "dish added", result.to_s
  end

  test "to_s returns error message for failed result" do
    result = ToolResult.err("not found")
    assert_equal "Error: not found", result.to_s
  end
end

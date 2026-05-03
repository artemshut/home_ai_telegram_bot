require "test_helper"

class ToolCallTest < ActiveSupport::TestCase
  setup do
    @ai_run = AiRun.create!(model: "claude-haiku", status: :pending)
  end

  test "valid with required fields" do
    tc = ToolCall.new(ai_run: @ai_run, tool_name: "add_dish", status: :pending)
    assert tc.valid?
  end

  test "invalid without tool_name" do
    tc = ToolCall.new(ai_run: @ai_run, tool_name: nil, status: :pending)
    assert_not tc.valid?
    assert_includes tc.errors[:tool_name], "can't be blank"
  end

  test "invalid without status" do
    tc = ToolCall.new(ai_run: @ai_run, tool_name: "add_dish", status: nil)
    assert_not tc.valid?
    assert tc.errors[:status].any?
  end

  test "invalid without ai_run" do
    tc = ToolCall.new(ai_run: nil, tool_name: "add_dish", status: :pending)
    assert_not tc.valid?
    assert tc.errors[:ai_run].any?
  end

  test "status enum includes all expected values" do
    tc = ToolCall.create!(ai_run: @ai_run, tool_name: "tool", status: :pending)
    assert tc.pending?

    tc.update!(status: :running)
    assert tc.running?

    tc.update!(status: :completed)
    assert tc.completed?

    tc.update!(status: :failed)
    assert tc.failed?
  end
end

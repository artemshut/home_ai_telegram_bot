require "test_helper"

class AiRunTest < ActiveSupport::TestCase
  test "valid with model and status" do
    run = AiRun.new(model: "claude-haiku", status: :pending)
    assert run.valid?
  end

  test "invalid without model" do
    run = AiRun.new(model: nil, status: :pending)
    assert_not run.valid?
    assert_includes run.errors[:model], "can't be blank"
  end

  test "invalid without status" do
    run = AiRun.new(model: "claude-haiku", status: nil)
    assert_not run.valid?
    assert run.errors[:status].any?
  end

  test "status enum includes all expected values" do
    run = AiRun.create!(model: "claude-haiku", status: :pending)
    assert run.pending?

    run.update!(status: :running)
    assert run.running?

    run.update!(status: :completed)
    assert run.completed?

    run.update!(status: :failed)
    assert run.failed?
  end

  test "telegram_user is optional" do
    run = AiRun.new(model: "claude-haiku", status: :pending, telegram_user: nil)
    assert run.valid?
  end

  test "telegram_message is optional" do
    run = AiRun.new(model: "claude-haiku", status: :pending, telegram_message: nil)
    assert run.valid?
  end

  test "has many tool_calls" do
    run = AiRun.create!(model: "claude-haiku", status: :pending)
    tc = ToolCall.create!(ai_run: run, tool_name: "test_tool", status: :pending)

    assert_includes run.tool_calls, tc
  end

  test "destroys tool_calls on destroy" do
    run = AiRun.create!(model: "claude-haiku", status: :pending)
    ToolCall.create!(ai_run: run, tool_name: "test_tool", status: :pending)

    assert_difference("ToolCall.count", -1) { run.destroy! }
  end
end

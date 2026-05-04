require "test_helper"

class Ai::Tools::CreateCalendarEventToolTest < ActiveSupport::TestCase
  setup do
    @household = Household.create!(name: "TestHousehold")
    @user      = TelegramUser.create!(telegram_id: 9_100_001, household: @household)
    @context   = Ai::ToolContext.new(telegram_user: @user, chat_id: 1)
    @tool      = Ai::Tools::CreateCalendarEventTool.new
  end

  test "creates a CalendarEvent record" do
    @tool.execute({
      "title"    => "Team lunch",
      "start_at" => "2026-06-01T12:00:00Z",
      "end_at"   => "2026-06-01T13:00:00Z"
    }, @context)

    assert_equal 1, @household.calendar_events.count
    event = @household.calendar_events.last
    assert_equal "Team lunch", event.title
    assert_equal "pending", event.status
  end

  test "stores event in context.last_pending_calendar_event" do
    @tool.execute({
      "title"    => "Dinner",
      "start_at" => "2026-06-01T19:00:00Z",
      "end_at"   => "2026-06-01T21:00:00Z"
    }, @context)

    assert_not_nil @context.last_pending_calendar_event
    assert_equal "Dinner", @context.last_pending_calendar_event.title
  end

  test "returns success result with event details" do
    result = @tool.execute({
      "title"    => "Movie night",
      "start_at" => "2026-06-05T20:00:00Z",
      "end_at"   => "2026-06-05T22:00:00Z"
    }, @context)

    assert result.success
    assert_includes result.to_s, "Movie night"
  end

  test "saves optional description and location" do
    @tool.execute({
      "title"       => "Dinner",
      "start_at"    => "2026-06-01T19:00:00Z",
      "end_at"      => "2026-06-01T21:00:00Z",
      "description" => "Birthday party",
      "location"    => "Casa Nostra"
    }, @context)

    event = @household.calendar_events.last
    assert_equal "Birthday party", event.description
    assert_equal "Casa Nostra", event.location
  end

  test "returns error when user has no household" do
    user    = TelegramUser.create!(telegram_id: 9_100_002)
    ctx     = Ai::ToolContext.new(telegram_user: user, chat_id: 1)
    result  = @tool.execute({ "title" => "X", "start_at" => "2026-06-01T12:00:00Z", "end_at" => "2026-06-01T13:00:00Z" }, ctx)
    assert_not result.success
  end

  test "raises ArgumentError when required args missing" do
    assert_raises(ArgumentError) { @tool.execute({}, @context) }
    assert_raises(ArgumentError) { @tool.execute({ "title" => "X" }, @context) }
  end

  test "returns error on unparseable date" do
    result = @tool.execute({
      "title"    => "X",
      "start_at" => "not-a-date",
      "end_at"   => "2026-06-01T13:00:00Z"
    }, @context)
    assert_not result.success
    assert_includes result.to_s, "Invalid date"
  end
end

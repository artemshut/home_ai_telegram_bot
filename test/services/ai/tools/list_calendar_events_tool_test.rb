require "test_helper"

class Ai::Tools::ListCalendarEventsToolTest < ActiveSupport::TestCase
  setup do
    @household = Household.create!(name: "TestHousehold")
    @user      = TelegramUser.create!(telegram_id: 9_200_001, household: @household)
    @context   = Ai::ToolContext.new(telegram_user: @user, chat_id: 1)
    @tool      = Ai::Tools::ListCalendarEventsTool.new
  end

  def create_event(title:, start_at:, status: "confirmed")
    @household.calendar_events.create!(
      title:    title,
      start_at: start_at,
      end_at:   start_at + 1.hour,
      status:   status
    )
  end

  # Runs the block with Google Calendar reporting as unauthorized so tests
  # exercise the local-DB fallback path.
  def without_google(&block)
    stub_gclient(authorized: false, &block)
  end

  def stub_gclient(authorized:, items: [], &block)
    fake_result = Struct.new(:items).new(items)
    fake_client = Object.new
    fake_client.define_singleton_method(:authorized?) { authorized }
    fake_client.define_singleton_method(:list) { |**_| fake_result }

    Google::CalendarClient.stub(:new, fake_client, &block)
  end

  # ── local DB tests ─────────────────────────────────────────────────────────

  test "returns no-events message when none exist" do
    without_google do
      result = @tool.execute({}, @context)
      assert result.success
      assert_includes result.to_s, "No upcoming events"
    end
  end

  test "lists confirmed and synced events" do
    create_event(title: "Confirmed", start_at: 1.day.from_now, status: "confirmed")
    create_event(title: "Synced",    start_at: 2.days.from_now, status: "synced")
    without_google do
      result = @tool.execute({}, @context)
      assert result.success
      assert_includes result.to_s, "Confirmed"
      assert_includes result.to_s, "Synced"
    end
  end

  test "excludes pending and cancelled events" do
    create_event(title: "Pending",   start_at: 1.day.from_now, status: "pending")
    create_event(title: "Cancelled", start_at: 1.day.from_now, status: "cancelled")
    without_google do
      result = @tool.execute({}, @context)
      assert result.success
      assert_includes result.to_s, "No upcoming events"
    end
  end

  test "excludes events outside the days_ahead window" do
    create_event(title: "Soon",  start_at: 2.days.from_now)
    create_event(title: "Later", start_at: 10.days.from_now)
    without_google do
      result = @tool.execute({ "days_ahead" => 5 }, @context)
      assert_includes result.to_s, "Soon"
      assert_not_includes result.to_s, "Later"
    end
  end

  test "excludes past events" do
    create_event(title: "Past", start_at: 1.day.ago)
    without_google do
      result = @tool.execute({}, @context)
      assert_includes result.to_s, "No upcoming events"
    end
  end

  test "returns error when user has no household" do
    user   = TelegramUser.create!(telegram_id: 9_200_002)
    ctx    = Ai::ToolContext.new(telegram_user: user, chat_id: 1)
    result = @tool.execute({}, ctx)
    assert_not result.success
  end

  test "query filters events by title keyword" do
    create_event(title: "John's Birthday", start_at: 30.days.from_now)
    create_event(title: "Team meeting",    start_at: 2.days.from_now)
    without_google do
      result = @tool.execute({ "query" => "birthday" }, @context)
      assert result.success
      assert_includes result.to_s, "John's Birthday"
      assert_not_includes result.to_s, "Team meeting"
    end
  end

  test "query search is case-insensitive" do
    create_event(title: "BIRTHDAY Party", start_at: 10.days.from_now)
    without_google do
      result = @tool.execute({ "query" => "birthday" }, @context)
      assert_includes result.to_s, "BIRTHDAY Party"
    end
  end

  test "query expands window to 365 days" do
    create_event(title: "Far Birthday", start_at: 200.days.from_now)
    without_google do
      result = @tool.execute({ "query" => "birthday" }, @context)
      assert_includes result.to_s, "Far Birthday"
    end
  end

  test "query returns no-match message when nothing found" do
    without_google do
      result = @tool.execute({ "query" => "dentist" }, @context)
      assert result.success
      assert_includes result.to_s, "No upcoming events matching"
    end
  end

  # ── Google Calendar tests ──────────────────────────────────────────────────

  def google_event(summary:, date_time: nil, date: nil, location: nil)
    start_dt = Struct.new(:date_time, :date).new(date_time, date)
    Struct.new(:summary, :start, :location).new(summary, start_dt, location)
  end

  test "uses Google Calendar when authorized" do
    items = [ google_event(summary: "Doctor", date_time: 2.days.from_now) ]
    stub_gclient(authorized: true, items: items) do
      result = @tool.execute({}, @context)
      assert result.success
      assert_includes result.to_s, "Doctor"
      assert_includes result.to_s, "Google Calendar"
    end
  end

  test "returns no-events message from Google when list is empty" do
    stub_gclient(authorized: true, items: []) do
      result = @tool.execute({}, @context)
      assert result.success
      assert_includes result.to_s, "No upcoming events in Google Calendar"
    end
  end

  test "includes location from Google event" do
    items = [ google_event(summary: "Party", date_time: 3.days.from_now, location: "Warsaw") ]
    stub_gclient(authorized: true, items: items) do
      result = @tool.execute({}, @context)
      assert_includes result.to_s, "Warsaw"
    end
  end

  test "handles all-day events from Google (date field, not date_time)" do
    items = [ google_event(summary: "Diana's Birthday", date: Date.current + 5) ]
    stub_gclient(authorized: true, items: items) do
      result = @tool.execute({}, @context)
      assert result.success
      assert_includes result.to_s, "Diana's Birthday"
    end
  end

  test "marks context for Google reconnect when not authorized" do
    without_google do
      result = @tool.execute({}, @context)

      assert result.success
      assert_equal true, @context.google_calendar_reauth_required
      assert_equal @household, @context.google_calendar_reauth_household
      assert_includes result.to_s, "Google Calendar is not connected"
    end
  end

  test "marks context for Google reconnect when token refresh fails" do
    fake_client = Object.new
    fake_client.define_singleton_method(:authorized?) { true }
    fake_client.define_singleton_method(:list) do |**_|
      raise Google::CalendarClient::ReauthorizationRequired, "invalid_grant"
    end

    Google::CalendarClient.stub(:new, fake_client) do
      result = @tool.execute({}, @context)

      assert result.success
      assert_equal true, @context.google_calendar_reauth_required
      assert_equal @household, @context.google_calendar_reauth_household
      assert_includes result.to_s, "needs to be reconnected"
    end
  end
end

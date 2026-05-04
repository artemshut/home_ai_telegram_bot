require "test_helper"

class SyncCalendarEventJobTest < ActiveSupport::TestCase
  setup do
    @household = Household.create!(name: "TestHousehold")
    @event     = @household.calendar_events.create!(
      title:    "Dinner",
      start_at: 1.day.from_now,
      end_at:   1.day.from_now + 1.hour,
      status:   "confirmed"
    )
  end

  test "skips when event is not found" do
    assert_nothing_raised { SyncCalendarEventJob.new.perform(0) }
  end

  test "skips when event is not confirmed" do
    @event.update!(status: "pending")
    called = false
    fake_client = Object.new
    fake_client.define_singleton_method(:authorized?) { true }
    fake_client.define_singleton_method(:insert) { |**_| called = true; nil }

    Google::CalendarClient.stub(:new, fake_client) do
      SyncCalendarEventJob.new.perform(@event.id)
    end

    assert_not called
  end

  test "skips when household has no OAuth token" do
    called = false
    fake_client = Object.new
    fake_client.define_singleton_method(:authorized?) { false }
    fake_client.define_singleton_method(:insert) { |**_| called = true; nil }

    Google::CalendarClient.stub(:new, fake_client) do
      SyncCalendarEventJob.new.perform(@event.id)
    end

    assert_not called
    assert_equal "confirmed", @event.reload.status
  end

  test "calls CalendarClient#insert and updates event to synced" do
    fake_google_event = Struct.new(:id).new("google_abc123")
    fake_client = Object.new
    fake_client.define_singleton_method(:authorized?) { true }
    fake_client.define_singleton_method(:insert) { |**_| fake_google_event }

    Google::CalendarClient.stub(:new, fake_client) do
      SyncCalendarEventJob.new.perform(@event.id)
    end

    @event.reload
    assert_equal "synced", @event.status
    assert_equal "google_abc123", @event.google_event_id
  end
end

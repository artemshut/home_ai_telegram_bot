require "test_helper"

class CalendarEventTest < ActiveSupport::TestCase
  setup do
    @household = Household.create!(name: "TestHousehold")
  end

  def new_event(attrs = {})
    CalendarEvent.new({ household: @household, title: "Dinner", start_at: 1.day.from_now, end_at: 1.day.from_now + 1.hour }.merge(attrs))
  end

  test "valid with required attributes" do
    assert new_event.valid?
  end

  test "invalid without title" do
    assert_not new_event(title: nil).valid?
  end

  test "invalid without start_at" do
    assert_not new_event(start_at: nil).valid?
  end

  test "invalid without end_at" do
    assert_not new_event(end_at: nil).valid?
  end

  test "status defaults to pending" do
    event = new_event
    event.save!
    assert_equal "pending", event.status
  end

  test "invalid status is rejected" do
    assert_not new_event(status: "unknown").valid?
  end

  test "status predicates work" do
    event = new_event(status: "confirmed")
    assert event.confirmed?
    assert_not event.pending?
    assert_not event.synced?
    assert_not event.cancelled?
  end

  test "today scope returns events starting today" do
    @household.calendar_events.create!(title: "Now", start_at: Time.current, end_at: Time.current + 1.hour, status: "confirmed")
    @household.calendar_events.create!(title: "Yesterday", start_at: 1.day.ago, end_at: 1.day.ago + 1.hour, status: "confirmed")
    @household.calendar_events.create!(title: "Tomorrow", start_at: 1.day.from_now, end_at: 1.day.from_now + 1.hour, status: "confirmed")

    names = CalendarEvent.today.map(&:title)
    assert_includes names, "Now"
    assert_not_includes names, "Yesterday"
    assert_not_includes names, "Tomorrow"
  end

  test "today scope excludes events on other dates" do
    @household.calendar_events.create!(title: "Past", start_at: 7.days.ago, end_at: 7.days.ago + 1.hour, status: "confirmed")
    @household.calendar_events.create!(title: "Future", start_at: 7.days.from_now, end_at: 7.days.from_now + 1.hour, status: "confirmed")

    assert_empty CalendarEvent.today.map(&:title)
  end

  test "active.today excludes pending and cancelled events" do
    @household.calendar_events.create!(title: "Confirmed", start_at: Time.current, end_at: Time.current + 1.hour, status: "confirmed")
    @household.calendar_events.create!(title: "Synced", start_at: Time.current, end_at: Time.current + 1.hour, status: "synced")
    @household.calendar_events.create!(title: "Pending", start_at: Time.current, end_at: Time.current + 1.hour, status: "pending")
    @household.calendar_events.create!(title: "Cancelled", start_at: Time.current, end_at: Time.current + 1.hour, status: "cancelled")

    names = CalendarEvent.active.today.map(&:title)
    assert_includes names, "Confirmed"
    assert_includes names, "Synced"
    assert_not_includes names, "Pending"
    assert_not_includes names, "Cancelled"
  end

  test "active scope returns confirmed and synced" do
    @household.calendar_events.create!(title: "A", start_at: 1.day.from_now, end_at: 2.days.from_now, status: "confirmed")
    @household.calendar_events.create!(title: "B", start_at: 2.days.from_now, end_at: 3.days.from_now, status: "synced")
    @household.calendar_events.create!(title: "C", start_at: 3.days.from_now, end_at: 4.days.from_now, status: "pending")
    @household.calendar_events.create!(title: "D", start_at: 4.days.from_now, end_at: 5.days.from_now, status: "cancelled")

    names = CalendarEvent.active.map(&:title)
    assert_includes names, "A"
    assert_includes names, "B"
    assert_not_includes names, "C"
    assert_not_includes names, "D"
  end
end

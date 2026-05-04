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

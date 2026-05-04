class SyncCalendarEventJob < ApplicationJob
  queue_as :telegram

  def perform(calendar_event_id)
    event = CalendarEvent.find_by(id: calendar_event_id)
    return unless event&.confirmed?

    client = Google::CalendarClient.new(event.household)

    unless client.authorized?
      Rails.logger.warn("SyncCalendarEventJob: no Google OAuth token for household #{event.household_id}")
      return
    end

    google_event = client.insert(
      summary:     event.title,
      description: event.description,
      location:    event.location,
      start_time:  event.start_at,
      end_time:    event.end_at,
      all_day:     event.all_day?
    )

    event.update!(status: "synced", google_event_id: google_event.id)
  rescue => e
    Rails.logger.error("SyncCalendarEventJob failed for event #{calendar_event_id}: #{e.message}")
  end
end

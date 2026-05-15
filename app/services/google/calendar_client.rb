require "google/apis/calendar_v3"

module Google
  class CalendarClient
    ReauthorizationRequired = Class.new(StandardError)

    def initialize(household)
      @household   = household
      @credentials = OauthService.new.credentials_for(household)
    end

    def authorized?
      @credentials.present?
    end

    def insert(summary:, start_time:, end_time:, description: nil, location: nil, all_day: false)
      refresh_if_expired!
      start_dt, end_dt = build_event_datetimes(start_time, end_time, all_day)
      event = ::Google::Apis::CalendarV3::Event.new(
        summary:     summary,
        description: description,
        location:    location,
        start:       start_dt,
        end:         end_dt
      )
      service.insert_event(calendar_id, event)
    end

    def list(time_min: Time.current, time_max: 1.week.from_now, q: nil)
      refresh_if_expired!
      service.list_events(
        calendar_id,
        time_min:      time_min.iso8601,
        time_max:      time_max.iso8601,
        single_events: true,
        order_by:      "startTime",
        q:             q.presence
      )
    end

    def delete(google_event_id)
      refresh_if_expired!
      service.delete_event(calendar_id, google_event_id)
    end

    private

    def build_event_datetimes(start_time, end_time, all_day)
      if all_day
        start_date = start_time.to_date.to_s
        end_date   = (end_time.to_date + 1).to_s
        [
          ::Google::Apis::CalendarV3::EventDateTime.new(date: start_date),
          ::Google::Apis::CalendarV3::EventDateTime.new(date: end_date)
        ]
      else
        [
          ::Google::Apis::CalendarV3::EventDateTime.new(date_time: start_time.iso8601, time_zone: "UTC"),
          ::Google::Apis::CalendarV3::EventDateTime.new(date_time: end_time.iso8601, time_zone: "UTC")
        ]
      end
    end

    def refresh_if_expired!
      raise ReauthorizationRequired, "Google Calendar is not connected." unless @credentials
      return unless @credentials.expires_within?(300)

      @credentials.fetch_access_token!
      persist_token!
    rescue ::Signet::AuthorizationError, ::Google::Apis::AuthorizationError => e
      raise ReauthorizationRequired, e.message
    end

    def persist_token!
      token = @household.google_oauth_token
      return unless token

      token.update!(
        access_token:  @credentials.access_token,
        refresh_token: @credentials.refresh_token.presence || token.refresh_token,
        expires_at:    @credentials.expires_at
      )
    end

    def calendar_id
      Rails.application.credentials.dig(:google, :calendar_id).presence || "primary"
    end

    def service
      @service ||= begin
        svc = ::Google::Apis::CalendarV3::CalendarService.new
        svc.authorization = @credentials
        svc
      end
    end
  end
end

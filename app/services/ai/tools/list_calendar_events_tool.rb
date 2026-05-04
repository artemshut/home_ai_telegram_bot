module Ai
  module Tools
    class ListCalendarEventsTool < BaseTool
      def self.tool_name = "list_calendar_events"
      def self.description = <<~DESC
        List or search calendar events for the household.
        Reads from Google Calendar when connected, otherwise falls back to the local database.

        IMPORTANT — when to use `query` vs no query:
        - For birthday questions ("what birthdays?", "when is X's birthday?") — do NOT use a query.
          Set days_ahead: 365 with no query, then identify birthday events from the titles yourself.
          Birthday event titles may be in any language: "urodziny", "день рождения", "birthday", etc.
        - For searching a specific keyword the user explicitly mentioned (e.g. "dentist", "gym") —
          use the `query` parameter with that exact word.
        - When asked about a specific person's events, do NOT use their name as the query —
          names change grammatical form (declension) and may not match. Omit query, use days_ahead: 365.
      DESC

      def self.schema
        {
          "type"       => "object",
          "properties" => {
            "days_ahead" => {
              "type"        => "integer",
              "description" => "How many days ahead to look (default: 7). Use 365 for birthday and person-specific searches."
            },
            "query" => {
              "type"        => "string",
              "description" => "Keyword to filter event titles (case-insensitive). Do NOT use for birthday lookups or person names."
            }
          }
        }
      end

      private

      def call(arguments, context)
        household = context.telegram_user&.household
        return ToolResult.err("No household found for this user.") unless household

        query  = arguments["query"].presence
        days   = query ? 365 : [ (arguments["days_ahead"] || 7).to_i, 1 ].max
        cutoff = days.days.from_now

        gclient = Google::CalendarClient.new(household)
        return fetch_from_google(gclient, query, cutoff) if gclient.authorized?

        fetch_from_local(household, query, days, cutoff)
      end

      def fetch_from_google(gclient, query, cutoff)
        result = gclient.list(time_min: Time.current, time_max: cutoff, q: query)
        items  = result.items || []

        if items.empty?
          msg = query ? "No events matching \"#{query}\" in Google Calendar." : "No upcoming events in Google Calendar."
          return ToolResult.ok(msg)
        end

        header = query ? "Events matching \"#{query}\" (Google Calendar):" : "Upcoming events (Google Calendar):"
        lines  = [ header ]
        items.each do |e|
          start_time = parse_google_time(e.start)
          lines << "  - #{e.summary} — #{start_time.strftime("%a, %b %-d at %-I:%M %p")}"
          lines << "      #{e.location}" if e.location.present?
        end
        ToolResult.ok(lines.join("\n"))
      rescue => err
        ToolResult.err("Could not read Google Calendar: #{err.message}")
      end

      def fetch_from_local(household, query, days, cutoff)
        events = household.calendar_events
                          .active
                          .where("start_at >= ?", Time.current)
                          .where("start_at <= ?", cutoff)
                          .order(:start_at)

        events = events.where("title ILIKE ?", "%#{sanitize_query(query)}%") if query

        if events.empty?
          msg = query ? "No upcoming events matching \"#{query}\"." : "No upcoming events in the next #{days} day(s)."
          return ToolResult.ok(msg)
        end

        header = query ? "Events matching \"#{query}\":" : "Upcoming events (next #{days} day(s)):"
        lines  = [ header ]
        events.each do |e|
          lines << "  - #{e.title} — #{e.start_at.strftime("%a, %b %-d at %-I:%M %p")}"
          lines << "      #{e.location}" if e.location.present?
        end
        ToolResult.ok(lines.join("\n"))
      end

      def parse_google_time(event_datetime)
        if event_datetime.date_time
          event_datetime.date_time.in_time_zone(Time.zone)
        else
          event_datetime.date.in_time_zone(Time.zone).beginning_of_day
        end
      end

      def sanitize_query(query)
        query.gsub(/[%_\\]/) { |c| "\\#{c}" }
      end
    end
  end
end

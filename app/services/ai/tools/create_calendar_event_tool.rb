module Ai
  module Tools
    class CreateCalendarEventTool < BaseTool
      def self.tool_name = "create_calendar_event"
      def self.description = <<~DESC
        Schedule a calendar event for the household. The user will confirm before it is
        added to Google Calendar.

        IMPORTANT — if the user has not specified a time for the event:
        1. Ask: "Should this be an all-day event, or do you want to set a specific time?"
        2. If all-day: call this tool with all_day: true and start_at as the date (ISO 8601, e.g. "2026-05-19"). end_at is optional.
        3. If specific time: ask for the time, then call with start_at and end_at as full ISO 8601 datetimes.
        Do not assume midnight; always clarify first.
      DESC

      def self.requires_confirmation? = true

      def self.schema
        {
          "type"       => "object",
          "properties" => {
            "title"       => { "type" => "string", "description" => "Event title" },
            "start_at"    => { "type" => "string", "description" => "Start date or datetime (ISO 8601). Date only for all-day events." },
            "end_at"      => { "type" => "string", "description" => "End datetime (ISO 8601). Optional for all-day events." },
            "all_day"     => { "type" => "boolean", "description" => "True if this is an all-day event with no specific time." },
            "description" => { "type" => "string", "description" => "Optional event description" },
            "location"    => { "type" => "string", "description" => "Optional location" }
          },
          "required" => [ "title", "start_at" ]
        }
      end

      private

      def call(arguments, context)
        household = context.telegram_user&.household
        return ToolResult.err("No household found for this user.") unless household

        all_day  = arguments["all_day"] == true
        start_at = parse_start(arguments["start_at"], all_day)
        end_at   = parse_end(arguments["end_at"], start_at, all_day)

        event = household.calendar_events.create!(
          title:       arguments["title"],
          start_at:    start_at,
          end_at:      end_at,
          all_day:     all_day,
          description: arguments["description"],
          location:    arguments["location"],
          status:      "pending"
        )

        context.last_pending_calendar_event = event

        ToolResult.ok(format_event(event))
      rescue ArgumentError => e
        ToolResult.err("Invalid date: #{e.message}")
      end

      def parse_start(value, all_day)
        if all_day
          Date.parse(value).in_time_zone(Time.zone).beginning_of_day
        else
          Time.zone.parse(value) || raise(ArgumentError, "Cannot parse datetime: #{value}")
        end
      end

      def parse_end(value, start_at, all_day)
        if value.present?
          if all_day
            Date.parse(value).in_time_zone(Time.zone).end_of_day
          else
            Time.zone.parse(value) || raise(ArgumentError, "Cannot parse datetime: #{value}")
          end
        elsif all_day
          start_at.end_of_day
        else
          start_at + 1.hour
        end
      end

      def format_event(event)
        lines = [ "Event ready for confirmation:" ]
        lines << "  Title: #{event.title}"
        if event.all_day?
          lines << "  Date:  #{event.start_at.strftime("%A, %b %-d")} (all day)"
        else
          lines << "  Start: #{event.start_at.strftime("%A, %b %-d at %-I:%M %p")}"
          lines << "  End:   #{event.end_at.strftime("%A, %b %-d at %-I:%M %p")}"
        end
        lines << "  Where: #{event.location}" if event.location.present?
        lines.join("\n")
      end
    end
  end
end

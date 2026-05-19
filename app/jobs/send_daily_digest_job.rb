class SendDailyDigestJob < ApplicationJob
  queue_as :telegram

  DigestEvent = Struct.new(:title, :start_at, :all_day, keyword_init: true) do
    def all_day? = all_day == true
  end

  def perform
    bot       = Telegram::BotClient.new
    formatter = Telegram::MessageFormatter.new

    Household.find_each do |household|
      users = household.telegram_users
      next if users.empty?

      events = events_for_today(household)
      meals  = meals_for_today(household)
      text   = formatter.format_daily_digest(date: Date.current, events: events, meals: meals)

      users.each do |user|
        bot.send_message(chat_id: user.telegram_id, text: text)
      rescue StandardError => e
        Rails.logger.error("SendDailyDigestJob: failed for user #{user.telegram_id}: #{e.message}")
      end
    end
  end

  private

  def events_for_today(household)
    client = Google::CalendarClient.new(household)
    return local_events_for_today(household) unless client.authorized?

    result = client.list(time_min: Date.current.beginning_of_day, time_max: Date.current.end_of_day)
    (result.items || []).map { |item| build_digest_event(item) }
  rescue Google::CalendarClient::ReauthorizationRequired => e
    Rails.logger.warn("SendDailyDigestJob: Google Calendar reauthorization required for household #{household.id}: #{e.message}")
    local_events_for_today(household)
  rescue StandardError => e
    Rails.logger.error("SendDailyDigestJob: failed to read Google Calendar for household #{household.id}: #{e.message}")
    local_events_for_today(household)
  end

  def local_events_for_today(household)
    household.calendar_events.active.today
  end

  def build_digest_event(item)
    all_day = item.start.date.present?
    DigestEvent.new(
      title: item.summary,
      start_at: parse_google_start_time(item.start),
      all_day: all_day
    )
  end

  def parse_google_start_time(event_datetime)
    if event_datetime.date_time
      event_datetime.date_time.in_time_zone(Time.zone)
    else
      Date.parse(event_datetime.date.to_s).in_time_zone(Time.zone).beginning_of_day
    end
  end

  def meals_for_today(household)
    menu = household.weekly_menus.for_week_of(Date.current).first
    return [] unless menu

    day = Date.current.strftime("%A").downcase
    menu.meals.for_day(day).includes(:dish)
  end
end

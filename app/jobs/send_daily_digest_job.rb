class SendDailyDigestJob < ApplicationJob
  queue_as :telegram

  def perform
    bot       = Telegram::BotClient.new
    formatter = Telegram::MessageFormatter.new

    Household.find_each do |household|
      users = household.telegram_users
      next if users.empty?

      events = household.calendar_events.active.today
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

  def meals_for_today(household)
    menu = household.weekly_menus.for_week_of(Date.current).first
    return [] unless menu

    day = Date.current.strftime("%A").downcase
    menu.meals.for_day(day).includes(:dish)
  end
end

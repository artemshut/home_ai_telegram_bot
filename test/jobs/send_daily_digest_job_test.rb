require "test_helper"

class SendDailyDigestJobTest < ActiveSupport::TestCase
  setup do
    @household = Household.create!(name: "TestHousehold")
    @user_a    = TelegramUser.create!(telegram_id: 9_000_001, household: @household)
    @user_b    = TelegramUser.create!(telegram_id: 9_000_002, household: @household)
    @dish      = Dish.create!(household: @household, name: "Pasta")
  end

  def fake_bot
    bot = Object.new
    calls = []
    bot.define_singleton_method(:send_message) { |**kwargs| calls << kwargs }
    bot.define_singleton_method(:calls) { calls }
    bot
  end

  def google_event(summary:, date_time: nil, date: nil)
    start = Struct.new(:date_time, :date).new(date_time, date)
    Struct.new(:summary, :start).new(summary, start)
  end

  def stub_google_client(authorized:, items: [], raises: nil, &block)
    fake_result = Struct.new(:items).new(items)
    fake_client = Object.new
    fake_client.define_singleton_method(:authorized?) { authorized }
    fake_client.define_singleton_method(:list) do |**_|
      raise raises if raises

      fake_result
    end

    Google::CalendarClient.stub(:new, fake_client, &block)
  end

  test "sends message to every telegram_user in each household" do
    bot = fake_bot

    Telegram::BotClient.stub(:new, bot) do
      SendDailyDigestJob.new.perform
    end

    chat_ids = bot.calls.map { |c| c[:chat_id] }
    assert_includes chat_ids, @user_a.telegram_id
    assert_includes chat_ids, @user_b.telegram_id
  end

  test "skips households with no telegram_users" do
    empty_household = Household.create!(name: "Empty")
    bot = fake_bot

    Telegram::BotClient.stub(:new, bot) do
      SendDailyDigestJob.new.perform
    end

    chat_ids = bot.calls.map { |c| c[:chat_id] }
    assert_not_includes chat_ids, nil
    # empty_household has no users — verify no phantom sends occurred for it
    assert bot.calls.all? { |c| c[:chat_id].present? }
  end

  test "sends with empty meals when no weekly menu exists" do
    bot = fake_bot
    sent_texts = []

    bot.define_singleton_method(:send_message) { |**kwargs| sent_texts << kwargs[:text] }

    Telegram::BotClient.stub(:new, bot) do
      SendDailyDigestJob.new.perform
    end

    assert sent_texts.any? { |t| t.include?("No meals planned today.") }
  end

  test "per-user error is logged and does not abort remaining users" do
    bot = Object.new
    calls = []
    first_call = true
    bot.define_singleton_method(:send_message) do |**kwargs|
      if first_call
        first_call = false
        raise StandardError, "Telegram timeout"
      end
      calls << kwargs[:chat_id]
    end

    logged_message = nil
    Rails.logger.stub(:error, ->(msg) { logged_message = msg }) do
      Telegram::BotClient.stub(:new, bot) do
        SendDailyDigestJob.new.perform
      end
    end

    assert_equal 1, calls.size, "Second user should still receive the digest"
    assert_includes logged_message, "SendDailyDigestJob"
  end

  test "includes today's active calendar events in the digest" do
    CalendarEvent.create!(
      household: @household,
      title: "Morning standup",
      start_at: Time.zone.parse("#{Date.current} 09:00"),
      end_at:   Time.zone.parse("#{Date.current} 09:30"),
      all_day: false,
      status: "confirmed"
    )

    sent_texts = []
    bot = Object.new
    bot.define_singleton_method(:send_message) { |**kwargs| sent_texts << kwargs[:text] }

    Telegram::BotClient.stub(:new, bot) do
      SendDailyDigestJob.new.perform
    end

    assert sent_texts.any? { |t| t.include?("Morning standup") }
  end

  test "includes today's Google Calendar events in the digest when connected" do
    items = [
      google_event(summary: "Gallery", date_time: Time.zone.parse("#{Date.current} 19:50")),
      google_event(summary: "Birthday", date: Date.current)
    ]

    sent_texts = []
    bot = Object.new
    bot.define_singleton_method(:send_message) { |**kwargs| sent_texts << kwargs[:text] }

    stub_google_client(authorized: true, items: items) do
      Telegram::BotClient.stub(:new, bot) do
        SendDailyDigestJob.new.perform
      end
    end

    assert sent_texts.any? { |t| t.include?("19:50 Gallery") }
    assert sent_texts.any? { |t| t.include?("all day Birthday") }
  end

  test "falls back to local events when Google Calendar read fails" do
    CalendarEvent.create!(
      household: @household,
      title: "Local fallback",
      start_at: Time.zone.parse("#{Date.current} 11:00"),
      end_at:   Time.zone.parse("#{Date.current} 11:30"),
      all_day: false,
      status: "confirmed"
    )

    sent_texts = []
    bot = Object.new
    bot.define_singleton_method(:send_message) { |**kwargs| sent_texts << kwargs[:text] }

    stub_google_client(authorized: true, raises: StandardError.new("Google timeout")) do
      Telegram::BotClient.stub(:new, bot) do
        SendDailyDigestJob.new.perform
      end
    end

    assert sent_texts.any? { |t| t.include?("Local fallback") }
  end

  test "includes today's meals from the current week's menu" do
    menu = WeeklyMenu.create!(household: @household, week_start_date: Date.current.beginning_of_week)
    day  = Date.current.strftime("%A").downcase
    Meal.create!(weekly_menu: menu, dish: @dish, day_of_week: day, meal_type: "dinner")

    sent_texts = []
    bot = Object.new
    bot.define_singleton_method(:send_message) { |**kwargs| sent_texts << kwargs[:text] }

    Telegram::BotClient.stub(:new, bot) do
      SendDailyDigestJob.new.perform
    end

    assert sent_texts.any? { |t| t.include?("Pasta") }
  end
end

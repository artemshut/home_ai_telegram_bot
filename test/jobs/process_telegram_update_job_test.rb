require "test_helper"

class ProcessTelegramUpdateJobTest < ActiveSupport::TestCase
  setup do
    @user = TelegramUser.create!(telegram_id: 7_000_001, first_name: "JobUser")
    @update = {
      "update_id" => 8_000_001,
      "message" => {
        "message_id" => 1,
        "date" => Time.current.to_i,
        "chat" => { "id" => 555 },
        "from" => { "id" => @user.telegram_id, "first_name" => "JobUser" },
        "text" => "what's for dinner?"
      }
    }
  end

  test "calls AiRouter and sends reply via BotClient" do
    fake_router = Object.new
    fake_router.define_singleton_method(:call) { "Here is your menu." }
    fake_router.define_singleton_method(:last_shopping_list) { nil }
    fake_router.define_singleton_method(:last_pending_calendar_event) { nil }
    fake_router.define_singleton_method(:last_pending_note) { nil }

    fake_bot = Object.new
    message_sent = false
    fake_bot.define_singleton_method(:send_message) { |**_kwargs| message_sent = true }

    Ai::AiRouter.stub(:new, fake_router) do
      Telegram::BotClient.stub(:new, fake_bot) do
        ProcessTelegramUpdateJob.new.perform(@update.to_json)
        assert message_sent, "BotClient#send_message should have been called"
      end
    end
  end

  test "sends the router reply to the correct chat" do
    sent_to = nil

    fake_router = Object.new
    fake_router.define_singleton_method(:call) { "Menu reply" }
    fake_router.define_singleton_method(:last_shopping_list) { nil }
    fake_router.define_singleton_method(:last_pending_calendar_event) { nil }
    fake_router.define_singleton_method(:last_pending_note) { nil }

    fake_bot = Object.new
    fake_bot.define_singleton_method(:send_message) { |chat_id:, text:, **| sent_to = chat_id }

    Ai::AiRouter.stub(:new, fake_router) do
      Telegram::BotClient.stub(:new, fake_bot) do
        ProcessTelegramUpdateJob.new.perform(@update.to_json)
      end
    end

    assert_equal 555, sent_to
  end

  test "returns early when update has no message" do
    update = { "update_id" => 8_000_002 }.to_json
    called = false

    fake_router = Object.new
    fake_router.define_singleton_method(:call) { called = true; "reply" }

    Ai::AiRouter.stub(:new, fake_router) do
      ProcessTelegramUpdateJob.new.perform(update)
    end

    assert_not called
  end

  test "processes edited_message when no message key present" do
    update = {
      "update_id" => 8_000_003,
      "edited_message" => {
        "message_id" => 2,
        "date" => Time.current.to_i,
        "chat" => { "id" => 555 },
        "from" => { "id" => @user.telegram_id },
        "text" => "edit"
      }
    }

    called = false
    fake_router = Object.new
    fake_router.define_singleton_method(:call) { called = true; "ok" }
    fake_router.define_singleton_method(:last_shopping_list) { nil }
    fake_router.define_singleton_method(:last_pending_calendar_event) { nil }
    fake_router.define_singleton_method(:last_pending_note) { nil }

    fake_bot = Object.new
    fake_bot.define_singleton_method(:send_message) { |**_| nil }

    Ai::AiRouter.stub(:new, fake_router) do
      Telegram::BotClient.stub(:new, fake_bot) do
        ProcessTelegramUpdateJob.new.perform(update.to_json)
      end
    end

    assert called
  end

  test "/start returns welcome without calling Claude" do
    update = @update.deep_merge("message" => { "text" => "/start" })
    sent_text = nil
    router_called = false

    fake_router = Object.new
    fake_router.define_singleton_method(:call) { router_called = true; "ignored" }

    fake_bot = Object.new
    fake_bot.define_singleton_method(:send_message) { |chat_id:, text:, **| sent_text = text }

    Ai::AiRouter.stub(:new, fake_router) do
      Telegram::BotClient.stub(:new, fake_bot) do
        ProcessTelegramUpdateJob.new.perform(update.to_json)
      end
    end

    assert_not router_called, "/start should not reach AiRouter"
    assert_includes sent_text, "household assistant"
  end

  test "/help returns command list without calling Claude" do
    update = @update.deep_merge("message" => { "text" => "/help" })
    sent_text = nil
    router_called = false

    fake_router = Object.new
    fake_router.define_singleton_method(:call) { router_called = true; "ignored" }

    fake_bot = Object.new
    fake_bot.define_singleton_method(:send_message) { |chat_id:, text:, **| sent_text = text }

    Ai::AiRouter.stub(:new, fake_router) do
      Telegram::BotClient.stub(:new, fake_bot) do
        ProcessTelegramUpdateJob.new.perform(update.to_json)
      end
    end

    assert_not router_called, "/help should not reach AiRouter"
    assert_includes sent_text, "/menu"
  end

  test "/whoami returns user info without calling Claude" do
    update = @update.deep_merge("message" => { "text" => "/whoami" })
    sent_text = nil
    router_called = false

    fake_router = Object.new
    fake_router.define_singleton_method(:call) { router_called = true; "ignored" }

    fake_bot = Object.new
    fake_bot.define_singleton_method(:send_message) { |chat_id:, text:, **| sent_text = text }

    Ai::AiRouter.stub(:new, fake_router) do
      Telegram::BotClient.stub(:new, fake_bot) do
        ProcessTelegramUpdateJob.new.perform(update.to_json)
      end
    end

    assert_not router_called, "/whoami should not reach AiRouter"
    assert_includes sent_text, @user.telegram_id.to_s
  end

  test "/menu with no menu tells user to plan one" do
    update = @update.deep_merge("message" => { "text" => "/menu" })
    sent_text = nil
    router_called = false

    fake_router = Object.new
    fake_router.define_singleton_method(:call) { router_called = true; "ignored" }

    fake_bot = Object.new
    fake_bot.define_singleton_method(:send_message) { |chat_id:, text:, **| sent_text = text }

    Ai::AiRouter.stub(:new, fake_router) do
      Telegram::BotClient.stub(:new, fake_bot) do
        ProcessTelegramUpdateJob.new.perform(update.to_json)
      end
    end

    assert_not router_called
    assert_includes sent_text, "No menu"
  end

  test "passes (no text) when message text is blank" do
    update = @update.deep_merge("message" => { "text" => nil })
    received_text = nil

    fake_bot = Object.new
    fake_bot.define_singleton_method(:send_message) { |**_| nil }

    Ai::AiRouter.stub(:new, ->(**kwargs) {
      received_text = kwargs[:message_text]
      stub_router = Object.new
      stub_router.define_singleton_method(:call) { "ok" }
      stub_router.define_singleton_method(:last_shopping_list) { nil }
      stub_router.define_singleton_method(:last_pending_calendar_event) { nil }
      stub_router.define_singleton_method(:last_pending_note) { nil }
      stub_router
    }) do
      Telegram::BotClient.stub(:new, fake_bot) do
        ProcessTelegramUpdateJob.new.perform(update.to_json)
      end
    end

    assert_equal "(no text)", received_text
  end

  test "sends Google Calendar reconnect button when router requests reauthorization" do
    household = Household.create!(name: "Home")
    @user.update!(household: household)

    fake_router = Object.new
    fake_router.define_singleton_method(:call) { "Calendar fallback reply" }
    fake_router.define_singleton_method(:last_shopping_list) { nil }
    fake_router.define_singleton_method(:last_pending_calendar_event) { nil }
    fake_router.define_singleton_method(:last_pending_note) { nil }
    fake_router.define_singleton_method(:google_calendar_reauth_required?) { true }
    fake_router.define_singleton_method(:google_calendar_reauth_household) { household }

    sent_messages = []
    fake_bot = Object.new
    fake_bot.define_singleton_method(:send_message) { |**kwargs| sent_messages << kwargs }

    Ai::AiRouter.stub(:new, fake_router) do
      Telegram::BotClient.stub(:new, fake_bot) do
        ProcessTelegramUpdateJob.new.perform(@update.to_json)
      end
    end

    assert_equal 2, sent_messages.size
    assert_equal "Calendar fallback reply", sent_messages.first[:text]
    assert_includes sent_messages.second[:text], "Reconnect"
    assert_includes sent_messages.second[:reply_markup], "/google/oauth/start?household_id=#{household.id}"
  end
end

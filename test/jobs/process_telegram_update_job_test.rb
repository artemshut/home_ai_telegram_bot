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

    fake_bot = Object.new
    message_sent = false
    fake_bot.define_singleton_method(:send_message) { |**_kwargs| message_sent = true }

    HomeAiTelegramBot::Ai::AiRouter.stub(:new, fake_router) do
      HomeAiTelegramBot::Telegram::BotClient.stub(:new, fake_bot) do
        ProcessTelegramUpdateJob.new.perform(@update.to_json)
        assert message_sent, "BotClient#send_message should have been called"
      end
    end
  end

  test "sends the router reply to the correct chat" do
    sent_to = nil

    fake_router = Object.new
    fake_router.define_singleton_method(:call) { "Menu reply" }

    fake_bot = Object.new
    fake_bot.define_singleton_method(:send_message) { |chat_id:, text:, **| sent_to = chat_id }

    HomeAiTelegramBot::Ai::AiRouter.stub(:new, fake_router) do
      HomeAiTelegramBot::Telegram::BotClient.stub(:new, fake_bot) do
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

    HomeAiTelegramBot::Ai::AiRouter.stub(:new, fake_router) do
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

    fake_bot = Object.new
    fake_bot.define_singleton_method(:send_message) { |**_| nil }

    HomeAiTelegramBot::Ai::AiRouter.stub(:new, fake_router) do
      HomeAiTelegramBot::Telegram::BotClient.stub(:new, fake_bot) do
        ProcessTelegramUpdateJob.new.perform(update.to_json)
      end
    end

    assert called
  end

  test "passes (no text) when message text is blank" do
    update = @update.deep_merge("message" => { "text" => nil })
    received_text = nil

    fake_bot = Object.new
    fake_bot.define_singleton_method(:send_message) { |**_| nil }

    HomeAiTelegramBot::Ai::AiRouter.stub(:new, ->(**kwargs) {
      received_text = kwargs[:message_text]
      stub_router = Object.new
      stub_router.define_singleton_method(:call) { "ok" }
      stub_router
    }) do
      HomeAiTelegramBot::Telegram::BotClient.stub(:new, fake_bot) do
        ProcessTelegramUpdateJob.new.perform(update.to_json)
      end
    end

    assert_equal "(no text)", received_text
  end
end

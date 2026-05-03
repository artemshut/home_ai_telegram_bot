require "test_helper"

class HomeAiTelegramBot::Telegram::WebhookHandlerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @update = {
      "update_id" => 77001,
      "message" => {
        "message_id" => 1,
        "date" => Time.current.to_i,
        "chat" => { "id" => 100 },
        "from" => { "id" => 300, "first_name" => "Bob" },
        "text" => "hi"
      }
    }
  end

  test "creates telegram user and message on first call" do
    assert_difference("TelegramUser.count") do
      assert_difference("TelegramMessage.count") do
        HomeAiTelegramBot::Telegram::WebhookHandler.new(@update).call
      end
    end
  end

  test "enqueues ProcessTelegramUpdateJob" do
    assert_enqueued_with(job: ProcessTelegramUpdateJob) do
      HomeAiTelegramBot::Telegram::WebhookHandler.new(@update).call
    end
  end

  test "ignores duplicate update_id" do
    HomeAiTelegramBot::Telegram::WebhookHandler.new(@update).call

    assert_no_difference("TelegramMessage.count") do
      HomeAiTelegramBot::Telegram::WebhookHandler.new(@update).call
    end
  end

  test "rejects message from user not in allowlist" do
    Rails.application.credentials.stub(:dig, [ 999 ]) do
      assert_no_difference("TelegramMessage.count") do
        HomeAiTelegramBot::Telegram::WebhookHandler.new(@update).call
      end
    end
  end

  test "allows message when allowlist is blank" do
    Rails.application.credentials.stub(:dig, nil) do
      assert_difference("TelegramMessage.count") do
        HomeAiTelegramBot::Telegram::WebhookHandler.new(@update).call
      end
    end
  end
end

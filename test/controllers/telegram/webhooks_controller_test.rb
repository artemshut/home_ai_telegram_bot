require "test_helper"

class Telegram::WebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @update = {
      "update_id" => 88001,
      "message" => {
        "message_id" => 1,
        "date" => Time.current.to_i,
        "chat" => { "id" => 100 },
        "from" => { "id" => 200, "first_name" => "Alice" },
        "text" => "hello"
      }
    }
  end

  test "returns ok when no secret is configured" do
    Rails.application.credentials.stub(:dig, nil) do
      post telegram_webhook_path, params: @update.to_json, headers: { "CONTENT_TYPE" => "application/json" }
      assert_response :ok
    end
  end

  test "returns ok when secret token matches" do
    Rails.application.credentials.stub(:dig, "correct_secret") do
      post telegram_webhook_path,
        params: @update.to_json,
        headers: {
          "CONTENT_TYPE" => "application/json",
          "HTTP_X_TELEGRAM_BOT_API_SECRET_TOKEN" => "correct_secret"
        }
      assert_response :ok
    end
  end

  test "returns forbidden when secret token does not match" do
    Rails.application.credentials.stub(:dig, "correct_secret") do
      post telegram_webhook_path,
        params: @update.to_json,
        headers: {
          "CONTENT_TYPE" => "application/json",
          "HTTP_X_TELEGRAM_BOT_API_SECRET_TOKEN" => "wrong_secret"
        }
      assert_response :forbidden
    end
  end

  test "returns ok for non-hash body" do
    Rails.application.credentials.stub(:dig, nil) do
      post telegram_webhook_path, params: "[]", headers: { "CONTENT_TYPE" => "application/json" }
      assert_response :ok
    end
  end
end

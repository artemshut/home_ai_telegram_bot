require "test_helper"

class Admin::BaseControllerTest < ActionDispatch::IntegrationTest
  # Falls back to defaults when credentials aren't set: name="admin", password="secret"
  VALID_HEADER = { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials("admin", "secret") }.freeze

  test "requires authentication" do
    Rails.application.credentials.stub(:dig, nil) do
      get admin_ai_runs_path
      assert_response :unauthorized
    end
  end

  test "allows access with valid credentials" do
    Rails.application.credentials.stub(:dig, nil) do
      get admin_ai_runs_path, headers: VALID_HEADER
      assert_response :ok
    end
  end

  test "rejects wrong password" do
    Rails.application.credentials.stub(:dig, nil) do
      bad = { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials("admin", "wrong") }
      get admin_ai_runs_path, headers: bad
      assert_response :unauthorized
    end
  end
end

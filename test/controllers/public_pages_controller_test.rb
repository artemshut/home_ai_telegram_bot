require "test_helper"

class PublicPagesControllerTest < ActionDispatch::IntegrationTest
  test "homepage is publicly available" do
    get root_path

    assert_response :success
    assert_includes response.body, "Home AI Telegram Bot"
    assert_includes response.body, privacy_path
  end

  test "privacy policy is publicly available" do
    get privacy_path

    assert_response :success
    assert_includes response.body, "Privacy Policy"
    assert_includes response.body, "Google Calendar data"
  end
end

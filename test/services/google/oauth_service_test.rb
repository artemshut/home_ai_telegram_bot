require "test_helper"

class Google::OauthServiceTest < ActiveSupport::TestCase
  setup do
    @household = Household.create!(name: "TestHousehold")
    @service   = Google::OauthService.new
  end

  test "credentials_for returns nil when no token exists" do
    assert_nil @service.credentials_for(@household)
  end

  test "credentials_for returns nil when token has no refresh_token" do
    GoogleOauthToken.create!(household: @household, access_token: "tok")
    assert_nil @service.credentials_for(@household)
  end

  test "credentials_for returns credentials object when refresh_token is present" do
    GoogleOauthToken.create!(
      household:     @household,
      access_token:  "access",
      refresh_token: "refresh"
    )
    creds = @service.credentials_for(@household)
    assert_not_nil creds
    assert_respond_to creds, :access_token
  end
end

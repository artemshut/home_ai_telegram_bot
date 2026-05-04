require "test_helper"

class GoogleOauthTokenTest < ActiveSupport::TestCase
  setup do
    @household = Household.create!(name: "TestHousehold")
  end

  test "belongs to household" do
    token = GoogleOauthToken.create!(household: @household, access_token: "tok")
    assert_equal @household, token.household
  end

  test "expired? returns false when expires_at is nil" do
    token = GoogleOauthToken.new(expires_at: nil)
    assert_not token.expired?
  end

  test "expired? returns false when expires_at is in the future" do
    token = GoogleOauthToken.new(expires_at: 1.hour.from_now)
    assert_not token.expired?
  end

  test "expired? returns true when expires_at is in the past" do
    token = GoogleOauthToken.new(expires_at: 1.hour.ago)
    assert token.expired?
  end

  test "household can have at most one google_oauth_token" do
    GoogleOauthToken.create!(household: @household, access_token: "first")
    other = GoogleOauthToken.new(household: @household, access_token: "second")
    assert_raises(ActiveRecord::RecordNotUnique) { other.save!(validate: false) }
  end
end

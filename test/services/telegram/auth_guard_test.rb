require "test_helper"

class Telegram::AuthGuardTest < ActiveSupport::TestCase
  AuthGuard = Telegram::AuthGuard

  test "allowed? returns true when allowlist is nil" do
    Rails.application.credentials.stub(:dig, nil) do
      assert AuthGuard.new(12345).allowed?
    end
  end

  test "allowed? returns true when allowlist is empty" do
    Rails.application.credentials.stub(:dig, []) do
      assert AuthGuard.new(12345).allowed?
    end
  end

  test "allowed? returns true when id is in allowlist" do
    Rails.application.credentials.stub(:dig, [ 12345, 67890 ]) do
      assert AuthGuard.new(12345).allowed?
    end
  end

  test "allowed? returns true when id matches as string" do
    Rails.application.credentials.stub(:dig, [ "12345" ]) do
      assert AuthGuard.new(12345).allowed?
    end
  end

  test "allowed? returns false when id is not in allowlist" do
    Rails.application.credentials.stub(:dig, [ 99999 ]) do
      assert_not AuthGuard.new(12345).allowed?
    end
  end
end

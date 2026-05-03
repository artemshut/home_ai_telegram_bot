require "test_helper"

class TelegramUserTest < ActiveSupport::TestCase
  test "valid with telegram_id" do
    user = TelegramUser.new(telegram_id: 2_000_001)
    assert user.valid?
  end

  test "invalid without telegram_id" do
    user = TelegramUser.new(telegram_id: nil)
    assert_not user.valid?
    assert_includes user.errors[:telegram_id], "can't be blank"
  end

  test "telegram_id must be unique" do
    TelegramUser.create!(telegram_id: 2_000_002)
    duplicate = TelegramUser.new(telegram_id: 2_000_002)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:telegram_id], "has already been taken"
  end

  test "household is optional" do
    user = TelegramUser.new(telegram_id: 2_000_003, household: nil)
    assert user.valid?
  end

  test "display_name returns first_name when present" do
    user = TelegramUser.new(telegram_id: 2_000_004, first_name: "Alice", username: "alice_user")
    assert_equal "Alice", user.display_name
  end

  test "display_name falls back to username when first_name is blank" do
    user = TelegramUser.new(telegram_id: 2_000_005, first_name: "", username: "bob_user")
    assert_equal "bob_user", user.display_name
  end

  test "display_name falls back to User N when both are blank" do
    user = TelegramUser.new(telegram_id: 2_000_006)
    assert_equal "User 2000006", user.display_name
  end

  test "has many telegram_messages" do
    user = TelegramUser.create!(telegram_id: 2_000_007)
    msg = TelegramMessage.create!(
      telegram_user: user,
      update_id: 9_000_100,
      chat_id: 1,
      message_id: 1,
      direction: "inbound"
    )

    assert_includes user.telegram_messages, msg
  end

  test "destroys telegram_messages on destroy" do
    user = TelegramUser.create!(telegram_id: 2_000_008)
    TelegramMessage.create!(
      telegram_user: user,
      update_id: 9_000_101,
      chat_id: 1,
      message_id: 1,
      direction: "inbound"
    )

    assert_difference("TelegramMessage.count", -1) { user.destroy! }
  end
end

require "test_helper"

class TelegramMessageTest < ActiveSupport::TestCase
  def build_message(overrides = {})
    TelegramMessage.new({
      update_id: 9_001_000,
      chat_id: 1,
      message_id: 1,
      direction: "inbound"
    }.merge(overrides))
  end

  test "valid with required fields" do
    assert build_message.valid?
  end

  test "invalid without update_id" do
    msg = build_message(update_id: nil)
    assert_not msg.valid?
    assert_includes msg.errors[:update_id], "can't be blank"
  end

  test "update_id must be unique" do
    TelegramMessage.create!(update_id: 9_001_001, chat_id: 1, message_id: 1, direction: "inbound")
    duplicate = build_message(update_id: 9_001_001)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:update_id], "has already been taken"
  end

  test "invalid without chat_id" do
    msg = build_message(chat_id: nil)
    assert_not msg.valid?
    assert_includes msg.errors[:chat_id], "can't be blank"
  end

  test "invalid without message_id" do
    msg = build_message(message_id: nil)
    assert_not msg.valid?
    assert_includes msg.errors[:message_id], "can't be blank"
  end

  test "invalid without direction" do
    msg = build_message(direction: nil)
    assert_not msg.valid?
    assert_includes msg.errors[:direction], "can't be blank"
  end

  test "invalid with unknown direction" do
    msg = build_message(direction: "sideways")
    assert_not msg.valid?
    assert msg.errors[:direction].any?
  end

  test "valid with inbound direction" do
    assert build_message(direction: "inbound").valid?
  end

  test "valid with outbound direction" do
    assert build_message(direction: "outbound").valid?
  end

  test "telegram_user is optional" do
    assert build_message(telegram_user: nil).valid?
  end
end

require "test_helper"

class HouseholdTest < ActiveSupport::TestCase
  test "valid with name" do
    household = Household.new(name: "Smith Family")
    assert household.valid?
  end

  test "invalid without name" do
    household = Household.new(name: "")
    assert_not household.valid?
    assert_includes household.errors[:name], "can't be blank"
  end

  test "has many telegram_users" do
    household = Household.create!(name: "TestHousehold")
    user = TelegramUser.create!(telegram_id: 1_000_001, household: household)

    assert_includes household.telegram_users, user
  end

  test "nullifies telegram_users on destroy" do
    household = Household.create!(name: "ToDelete")
    user = TelegramUser.create!(telegram_id: 1_000_002, household: household)

    household.destroy!

    assert_nil user.reload.household_id
  end

  test "has many telegram_messages through telegram_users" do
    household = Household.create!(name: "MsgHousehold")
    user = TelegramUser.create!(telegram_id: 1_000_003, household: household)
    msg = TelegramMessage.create!(
      telegram_user: user,
      update_id: 9_000_001,
      chat_id: 1,
      message_id: 1,
      direction: "inbound"
    )

    assert_includes household.telegram_messages, msg
  end
end

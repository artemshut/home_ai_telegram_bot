require "test_helper"

class HomeAiTelegramBot::Ai::Prompts::SystemPromptTest < ActiveSupport::TestCase
  test "includes current date" do
    prompt = HomeAiTelegramBot::Ai::Prompts::SystemPrompt.new(nil).call
    assert_includes prompt, Date.current.strftime("%A, %B %-d, %Y")
  end

  test "uses fallback household name when user is nil" do
    prompt = HomeAiTelegramBot::Ai::Prompts::SystemPrompt.new(nil).call
    assert_includes prompt, "your household"
  end

  test "uses fallback household name when user has no household" do
    user = TelegramUser.create!(telegram_id: 5_000_001)
    prompt = HomeAiTelegramBot::Ai::Prompts::SystemPrompt.new(user).call
    assert_includes prompt, "your household"
  end

  test "uses household name when user belongs to a household" do
    household = Household.create!(name: "Doe Family")
    user = TelegramUser.create!(telegram_id: 5_000_002, household: household)
    prompt = HomeAiTelegramBot::Ai::Prompts::SystemPrompt.new(user).call
    assert_includes prompt, "Doe Family"
  end

  test "lists household members when household is present" do
    household = Household.create!(name: "TheFamily")
    user1 = TelegramUser.create!(telegram_id: 5_000_003, first_name: "Alice", household: household)
    TelegramUser.create!(telegram_id: 5_000_004, first_name: "Bob", household: household)
    prompt = HomeAiTelegramBot::Ai::Prompts::SystemPrompt.new(user1).call
    assert_includes prompt, "Alice"
    assert_includes prompt, "Bob"
  end

  test "omits household members section when user has no household" do
    user = TelegramUser.create!(telegram_id: 5_000_005)
    prompt = HomeAiTelegramBot::Ai::Prompts::SystemPrompt.new(user).call
    assert_not_includes prompt, "Household members:"
  end
end

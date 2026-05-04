require "test_helper"

class Ai::Prompts::SystemPromptTest < ActiveSupport::TestCase
  test "includes current date" do
    prompt = Ai::Prompts::SystemPrompt.new(nil).call
    assert_includes prompt, Date.current.strftime("%A, %B %-d, %Y")
  end

  test "uses fallback household name when user is nil" do
    prompt = Ai::Prompts::SystemPrompt.new(nil).call
    assert_includes prompt, "your household"
  end

  test "uses fallback household name when user has no household" do
    user = TelegramUser.create!(telegram_id: 5_000_001)
    prompt = Ai::Prompts::SystemPrompt.new(user).call
    assert_includes prompt, "your household"
  end

  test "uses household name when user belongs to a household" do
    household = Household.create!(name: "Doe Family")
    user = TelegramUser.create!(telegram_id: 5_000_002, household: household)
    prompt = Ai::Prompts::SystemPrompt.new(user).call
    assert_includes prompt, "Doe Family"
  end

  test "lists household members when household is present" do
    household = Household.create!(name: "TheFamily")
    user1 = TelegramUser.create!(telegram_id: 5_000_003, first_name: "Alice", household: household)
    TelegramUser.create!(telegram_id: 5_000_004, first_name: "Bob", household: household)
    prompt = Ai::Prompts::SystemPrompt.new(user1).call
    assert_includes prompt, "Alice"
    assert_includes prompt, "Bob"
  end

  test "omits household members section when user has no household" do
    user = TelegramUser.create!(telegram_id: 5_000_005)
    prompt = Ai::Prompts::SystemPrompt.new(user).call
    assert_not_includes prompt, "Household members:"
  end

  test "includes dish library when household has dishes" do
    household = Household.create!(name: "FoodFamily")
    user = TelegramUser.create!(telegram_id: 5_000_006, household: household)
    Dish.create!(household: household, name: "Pasta")
    prompt = Ai::Prompts::SystemPrompt.new(user).call
    assert_includes prompt, "Pasta"
    assert_includes prompt, "Dish library:"
  end

  test "shows empty dish library when household has no dishes" do
    household = Household.create!(name: "EmptyKitchen")
    user = TelegramUser.create!(telegram_id: 5_000_007, household: household)
    prompt = Ai::Prompts::SystemPrompt.new(user).call
    assert_includes prompt, "Dish library: (empty)"
  end

  test "omits dish library section when user has no household" do
    user = TelegramUser.create!(telegram_id: 5_000_008)
    prompt = Ai::Prompts::SystemPrompt.new(user).call
    assert_not_includes prompt, "Dish library:"
  end
end

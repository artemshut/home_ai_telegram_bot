module HomeAiTelegramBot
  module Ai
    module Prompts
      class SystemPrompt
        def initialize(telegram_user)
          @telegram_user = telegram_user
        end

        def call
          parts = [
            "You are a home assistant bot for #{household_name}.",
            "Today is #{Date.current.strftime("%A, %B %-d, %Y")}.",
            household_section,
            "",
            "You help manage household tasks: weekly menus, shopping lists, and other home organisation.",
            "Always use the available tools to take actions — don't just describe what you would do.",
            "Keep responses short and suited for Telegram."
          ]

          parts.compact.join("\n")
        end

        private

        def household_name
          @telegram_user&.household&.name || "your household"
        end

        def household_section
          return nil unless @telegram_user&.household

          members = @telegram_user.household.telegram_users.map(&:display_name).join(", ")
          "Household members: #{members}"
        end
      end
    end
  end
end

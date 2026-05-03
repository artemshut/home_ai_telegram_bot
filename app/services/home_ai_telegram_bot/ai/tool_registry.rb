module HomeAiTelegramBot
  module Ai
    class ToolRegistry
      @tools = {}

      class << self
        def register(tool_class)
          @tools[tool_class.tool_name] = tool_class
        end

        def find(name)
          tool_class = @tools[name] or raise KeyError, "Unknown tool: #{name}"
          tool_class.new
        end

        def tool_definitions
          @tools.values.map(&:definition)
        end
      end
    end
  end
end

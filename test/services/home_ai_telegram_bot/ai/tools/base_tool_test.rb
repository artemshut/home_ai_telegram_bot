require "test_helper"

class HomeAiTelegramBot::Ai::Tools::BaseToolTest < ActiveSupport::TestCase
  # Concrete subclass used only within these tests
  class EchoTool < HomeAiTelegramBot::Ai::Tools::BaseTool
    def self.tool_name = "echo"
    def self.description = "Echoes the input"
    def self.schema
      {
        "type" => "object",
        "properties" => { "text" => { "type" => "string" } },
        "required" => ["text"]
      }
    end

    private

    def call(arguments, _context)
      HomeAiTelegramBot::Ai::ToolResult.ok(arguments["text"])
    end
  end

  test "definition returns name, description, and input_schema" do
    defn = EchoTool.definition
    assert_equal "echo", defn[:name]
    assert_equal "Echoes the input", defn[:description]
    assert_equal EchoTool.schema, defn[:input_schema]
  end

  test "execute calls tool when arguments are valid" do
    result = EchoTool.new.execute({ "text" => "hello" }, nil)
    assert_equal "hello", result.to_s
  end

  test "execute raises ArgumentError when required argument is missing" do
    assert_raises(ArgumentError) do
      EchoTool.new.execute({}, nil)
    end
  end

  test "tool_name raises NotImplementedError on base class" do
    assert_raises(NotImplementedError) { HomeAiTelegramBot::Ai::Tools::BaseTool.tool_name }
  end

  test "description raises NotImplementedError on base class" do
    assert_raises(NotImplementedError) { HomeAiTelegramBot::Ai::Tools::BaseTool.description }
  end

  test "schema raises NotImplementedError on base class" do
    assert_raises(NotImplementedError) { HomeAiTelegramBot::Ai::Tools::BaseTool.schema }
  end

  test "call raises NotImplementedError on base class" do
    assert_raises(NotImplementedError) { HomeAiTelegramBot::Ai::Tools::BaseTool.new.send(:call, {}, nil) }
  end
end

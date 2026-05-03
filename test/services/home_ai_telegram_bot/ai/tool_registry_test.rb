require "test_helper"

class HomeAiTelegramBot::Ai::ToolRegistryTest < ActiveSupport::TestCase
  Registry = HomeAiTelegramBot::Ai::ToolRegistry

  # Minimal tool class for registration tests
  class PingTool < HomeAiTelegramBot::Ai::Tools::BaseTool
    def self.tool_name = "ping_test_tool"
    def self.description = "Ping"
    def self.schema = { "type" => "object", "properties" => {} }
  end

  setup do
    Registry.register(PingTool)
  end

  teardown do
    # Remove the test tool from the registry so it doesn't bleed across tests
    Registry.instance_variable_get(:@tools).delete("ping_test_tool")
  end

  test "find returns a new instance of the registered tool" do
    tool = Registry.find("ping_test_tool")
    assert_instance_of PingTool, tool
  end

  test "find raises KeyError for unknown tool" do
    assert_raises(KeyError) { Registry.find("nonexistent_tool_xyz") }
  end

  test "tool_definitions includes the registered tool" do
    defns = Registry.tool_definitions
    names = defns.map { |d| d[:name] }
    assert_includes names, "ping_test_tool"
  end

  test "tool_definitions entry has required keys" do
    defn = Registry.tool_definitions.find { |d| d[:name] == "ping_test_tool" }
    assert defn.key?(:name)
    assert defn.key?(:description)
    assert defn.key?(:input_schema)
  end
end

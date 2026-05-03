require "test_helper"

class HomeAiTelegramBot::Ai::AiRouterTest < ActiveSupport::TestCase
  setup do
    @user = TelegramUser.create!(telegram_id: 66001, first_name: "Test")
  end

  test "returns text on end_turn response" do
    fake_response = {
      "content"     => [ { "type" => "text", "text" => "Hello from Claude!" } ],
      "stop_reason" => "end_turn",
      "usage"       => { "input_tokens" => 10, "output_tokens" => 5,
                         "cache_creation_input_tokens" => 0, "cache_read_input_tokens" => 0 }
    }

    fake_client = build_fake_client([ fake_response ])

    HomeAiTelegramBot::Ai::ClaudeClient.stub(:new, fake_client) do
      result = HomeAiTelegramBot::Ai::AiRouter.new(
        telegram_user: @user, message_text: "hello", chat_id: 123
      ).call

      assert_equal "Hello from Claude!", result
    end
  end

  test "creates AiRun record" do
    fake_response = {
      "content"     => [ { "type" => "text", "text" => "Hi!" } ],
      "stop_reason" => "end_turn",
      "usage"       => { "input_tokens" => 5, "output_tokens" => 3,
                         "cache_creation_input_tokens" => 0, "cache_read_input_tokens" => 0 }
    }

    fake_client = build_fake_client([ fake_response ])

    HomeAiTelegramBot::Ai::ClaudeClient.stub(:new, fake_client) do
      assert_difference("AiRun.count") do
        HomeAiTelegramBot::Ai::AiRouter.new(
          telegram_user: @user, message_text: "hello", chat_id: 123
        ).call
      end
    end
  end

  test "executes tool call and continues to end_turn" do
    tool_use_response = {
      "content"     => [
        { "type" => "tool_use", "id" => "toolu_01", "name" => "stub_tool", "input" => { "x" => 1 } }
      ],
      "stop_reason" => "tool_use",
      "usage"       => { "input_tokens" => 10, "output_tokens" => 8,
                         "cache_creation_input_tokens" => 0, "cache_read_input_tokens" => 0 }
    }

    end_turn_response = {
      "content"     => [ { "type" => "text", "text" => "Done!" } ],
      "stop_reason" => "end_turn",
      "usage"       => { "input_tokens" => 15, "output_tokens" => 5,
                         "cache_creation_input_tokens" => 0, "cache_read_input_tokens" => 0 }
    }

    fake_client = build_fake_client([ tool_use_response, end_turn_response ])

    fake_tool = Object.new
    fake_tool.define_singleton_method(:execute) { |_args, _ctx| "tool result" }

    HomeAiTelegramBot::Ai::ClaudeClient.stub(:new, fake_client) do
      HomeAiTelegramBot::Ai::ToolRegistry.stub(:find, fake_tool) do
        result = HomeAiTelegramBot::Ai::AiRouter.new(
          telegram_user: @user, message_text: "do something", chat_id: 123
        ).call

        assert_equal "Done!", result
        assert_equal 1, ToolCall.count
        assert ToolCall.last.completed?
      end
    end
  end

  test "returns fallback message when max depth exceeded" do
    tool_use_response = {
      "content"     => [
        { "type" => "tool_use", "id" => "toolu_loop", "name" => "stub_tool", "input" => {} }
      ],
      "stop_reason" => "tool_use",
      "usage"       => { "input_tokens" => 5, "output_tokens" => 5,
                         "cache_creation_input_tokens" => 0, "cache_read_input_tokens" => 0 }
    }

    fake_client = build_fake_client(Array.new(HomeAiTelegramBot::Ai::AiRouter::MAX_DEPTH, tool_use_response))

    fake_tool = Object.new
    fake_tool.define_singleton_method(:execute) { |_args, _ctx| "ok" }

    HomeAiTelegramBot::Ai::ClaudeClient.stub(:new, fake_client) do
      HomeAiTelegramBot::Ai::ToolRegistry.stub(:find, fake_tool) do
        result = HomeAiTelegramBot::Ai::AiRouter.new(
          telegram_user: @user, message_text: "loop", chat_id: 123
        ).call

        assert_equal "I'm sorry, I couldn't complete that request.", result
      end
    end
  end

  test "records failed tool call on tool error" do
    tool_use_response = {
      "content"     => [
        { "type" => "tool_use", "id" => "toolu_err", "name" => "bad_tool", "input" => {} }
      ],
      "stop_reason" => "tool_use",
      "usage"       => { "input_tokens" => 5, "output_tokens" => 5,
                         "cache_creation_input_tokens" => 0, "cache_read_input_tokens" => 0 }
    }

    end_turn_response = {
      "content"     => [ { "type" => "text", "text" => "Sorry about that." } ],
      "stop_reason" => "end_turn",
      "usage"       => { "input_tokens" => 10, "output_tokens" => 5,
                         "cache_creation_input_tokens" => 0, "cache_read_input_tokens" => 0 }
    }

    fake_client = build_fake_client([ tool_use_response, end_turn_response ])

    exploding_tool = Object.new
    exploding_tool.define_singleton_method(:execute) { |_args, _ctx| raise "boom" }

    HomeAiTelegramBot::Ai::ClaudeClient.stub(:new, fake_client) do
      HomeAiTelegramBot::Ai::ToolRegistry.stub(:find, exploding_tool) do
        HomeAiTelegramBot::Ai::AiRouter.new(
          telegram_user: @user, message_text: "break things", chat_id: 123
        ).call

        assert ToolCall.last.failed?
        assert_equal "boom", ToolCall.last.error
      end
    end
  end

  private

  def build_fake_client(responses)
    index = 0
    fake_client = Object.new
    fake_client.define_singleton_method(:call) do |**_kwargs|
      response = responses[index]
      index += 1
      response
    end
    fake_client
  end
end

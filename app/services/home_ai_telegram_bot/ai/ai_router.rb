module HomeAiTelegramBot
  module Ai
    class AiRouter
      MAX_DEPTH = 5

      def initialize(telegram_user:, message_text:, chat_id:, telegram_message: nil)
        @telegram_user    = telegram_user
        @message_text     = message_text
        @chat_id          = chat_id
        @telegram_message = telegram_message
      end

      def call
        ai_run = AiRun.create!(
          telegram_user:    @telegram_user,
          telegram_message: @telegram_message,
          status:           :pending,
          model:            ClaudeClient::MODEL,
          system_prompt:    system_prompt
        )

        messages = [ { role: "user", content: @message_text } ]
        tools    = ToolRegistry.tool_definitions
        client   = ClaudeClient.new

        MAX_DEPTH.times do
          response   = client.call(messages: messages, system: system_prompt, tools: tools, ai_run: ai_run)
          content    = response.fetch("content", [])
          stop_reason = response["stop_reason"]

          if stop_reason == "tool_use"
            messages << { role: "assistant", content: content }

            tool_results = content.select { |b| b["type"] == "tool_use" }.map do |block|
              execute_tool(block, ai_run)
            end

            messages << { role: "user", content: tool_results }
          else
            return content.find { |b| b["type"] == "text" }&.dig("text") || ""
          end
        end

        "I'm sorry, I couldn't complete that request."
      end

      private

      def system_prompt
        @system_prompt ||= Prompts::SystemPrompt.new(@telegram_user).call
      end

      def execute_tool(block, ai_run)
        tool_call = ToolCall.create!(
          ai_run:    ai_run,
          tool_name: block["name"],
          arguments: block["input"] || {},
          status:    :pending
        )

        started_at = Time.current

        begin
          result     = ToolRegistry.find(block["name"]).execute(block["input"] || {}, tool_context)
          elapsed    = ((Time.current - started_at) * 1000).to_i
          tool_call.update!(status: :completed, result: { data: result.to_s }, duration_ms: elapsed)

          { type: "tool_result", tool_use_id: block["id"], content: result.to_s }
        rescue => e
          elapsed = ((Time.current - started_at) * 1000).to_i
          tool_call.update!(status: :failed, error: e.message, duration_ms: elapsed)

          { type: "tool_result", tool_use_id: block["id"], is_error: true, content: e.message }
        end
      end

      def tool_context
        ToolContext.new(telegram_user: @telegram_user, chat_id: @chat_id)
      end
    end
  end
end

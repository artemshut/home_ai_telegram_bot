module HomeAiTelegramBot
  module Ai
    class ClaudeClient
      MODEL = "claude-haiku-4-5-20251001"
      MAX_TOKENS = 4096

      def initialize
        @client = Anthropic::Client.new(
          api_key: Rails.application.credentials.dig(:anthropic, :api_key)
        )
      end

      def call(messages:, system:, tools: [], ai_run:)
        started_at = Time.current
        ai_run.update!(status: :running, messages: messages)

        params = {
          model: MODEL,
          max_tokens: MAX_TOKENS,
          system: [ { type: "text", text: system, cache_control: { type: "ephemeral" } } ],
          messages: messages
        }
        params[:tools] = tools if tools.any?

        response = @client.messages(**params)
        duration_ms = ((Time.current - started_at) * 1000).to_i

        usage = response.fetch("usage", {})
        ai_run.update!(
          status: :completed,
          response: response,
          input_tokens:          (ai_run.input_tokens.to_i  + usage["input_tokens"].to_i),
          output_tokens:         (ai_run.output_tokens.to_i + usage["output_tokens"].to_i),
          cache_creation_tokens: (ai_run.cache_creation_tokens.to_i + usage["cache_creation_input_tokens"].to_i),
          cache_read_tokens:     (ai_run.cache_read_tokens.to_i     + usage["cache_read_input_tokens"].to_i),
          duration_ms:           (ai_run.duration_ms.to_i + duration_ms)
        )

        response
      rescue => e
        ai_run.update!(status: :failed, error: e.message)
        raise
      end
    end
  end
end

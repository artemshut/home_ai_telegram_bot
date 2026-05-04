class Admin::ToolCallsController < Admin::BaseController
  def index
    @tool_calls = ToolCall.includes(:ai_run)
                          .order(created_at: :desc)
                          .limit(100)
  end
end

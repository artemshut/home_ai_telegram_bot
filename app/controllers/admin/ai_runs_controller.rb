class Admin::AiRunsController < Admin::BaseController
  def index
    @ai_runs = AiRun.includes(:telegram_user, :tool_calls)
                    .order(created_at: :desc)
                    .limit(100)
  end

  def show
    @ai_run = AiRun.includes(:telegram_user, tool_calls: []).find(params[:id])
  end
end

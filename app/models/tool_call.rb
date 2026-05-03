class ToolCall < ApplicationRecord
  belongs_to :ai_run

  enum :status, { pending: "pending", running: "running", completed: "completed", failed: "failed" }

  validates :tool_name, presence: true
  validates :status, presence: true
end

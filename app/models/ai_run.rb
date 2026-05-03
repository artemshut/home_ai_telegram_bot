class AiRun < ApplicationRecord
  belongs_to :telegram_user, optional: true
  belongs_to :telegram_message, optional: true
  has_many :tool_calls, dependent: :destroy

  enum :status, { pending: "pending", running: "running", completed: "completed", failed: "failed" }

  validates :model, presence: true
  validates :status, presence: true
end

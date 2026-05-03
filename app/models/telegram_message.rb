class TelegramMessage < ApplicationRecord
  belongs_to :telegram_user, optional: true

  validates :update_id, presence: true, uniqueness: true
  validates :chat_id, :message_id, :direction, presence: true

  DIRECTIONS = %w[inbound outbound].freeze
  validates :direction, inclusion: { in: DIRECTIONS }
end

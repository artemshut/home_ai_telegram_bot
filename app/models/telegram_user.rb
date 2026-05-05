class TelegramUser < ApplicationRecord
  belongs_to :household, optional: true
  has_many :telegram_messages, dependent: :destroy
  has_many :notes, dependent: :destroy

  validates :telegram_id, presence: true, uniqueness: true

  def display_name
    first_name.presence || username.presence || "User #{telegram_id}"
  end
end

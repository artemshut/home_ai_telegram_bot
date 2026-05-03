class Household < ApplicationRecord
  has_many :telegram_users, dependent: :nullify
  has_many :telegram_messages, through: :telegram_users

  validates :name, presence: true
end

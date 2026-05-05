class Household < ApplicationRecord
  has_many :telegram_users, dependent: :nullify
  has_many :telegram_messages, through: :telegram_users
  has_many :dishes, dependent: :destroy
  has_many :weekly_menus, dependent: :destroy
  has_many :shopping_lists, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :calendar_events, dependent: :destroy
  has_one :google_oauth_token, dependent: :destroy
  has_many :note_categories, dependent: :destroy
  has_many :notes, dependent: :destroy

  validates :name, presence: true
end

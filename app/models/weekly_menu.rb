class WeeklyMenu < ApplicationRecord
  belongs_to :household
  has_many :meals, dependent: :destroy
  has_many :dishes, through: :meals

  validates :week_start_date, presence: true, uniqueness: { scope: :household_id }

  DAYS = %w[monday tuesday wednesday thursday friday saturday sunday].freeze
  MEAL_TYPES = %w[breakfast lunch dinner].freeze

  scope :for_week_of, ->(date) { where(week_start_date: date.beginning_of_week) }
end

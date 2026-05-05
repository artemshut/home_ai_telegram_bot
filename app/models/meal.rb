class Meal < ApplicationRecord
  belongs_to :weekly_menu
  belongs_to :dish

  validates :day_of_week, presence: true, inclusion: { in: WeeklyMenu::DAYS }
  validates :meal_type, presence: true, inclusion: { in: WeeklyMenu::MEAL_TYPES }
  validates :day_of_week, uniqueness: { scope: [ :weekly_menu_id, :meal_type ] }

  scope :for_day, ->(day) { where(day_of_week: day) }
end

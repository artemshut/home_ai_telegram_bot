class Dish < ApplicationRecord
  belongs_to :household
  has_many :meals, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :household_id, case_sensitive: false }
end

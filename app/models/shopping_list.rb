class ShoppingList < ApplicationRecord
  belongs_to :household
  belongs_to :weekly_menu, optional: true
  has_many :shopping_items, dependent: :destroy

  validates :name, presence: true
end

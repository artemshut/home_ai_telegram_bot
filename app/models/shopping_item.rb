class ShoppingItem < ApplicationRecord
  belongs_to :shopping_list

  validates :name, presence: true
  validates :name, uniqueness: { scope: :shopping_list_id, case_sensitive: false }
end

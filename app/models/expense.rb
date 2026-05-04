class Expense < ApplicationRecord
  belongs_to :household
  belongs_to :expense_category
  belongs_to :telegram_user, optional: true

  validates :amount,      presence: true, numericality: { greater_than: 0 }
  validates :description, presence: true
  validates :currency,    presence: true
  validates :spent_on,    presence: true
end

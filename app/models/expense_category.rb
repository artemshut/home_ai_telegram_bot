class ExpenseCategory < ApplicationRecord
  has_many :expenses, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true

  DEFAULT_NAMES = %w[Groceries Dining Transport Utilities Health Entertainment Clothing Other].freeze
end

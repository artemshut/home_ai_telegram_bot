class CalendarEvent < ApplicationRecord
  belongs_to :household

  STATUSES = %w[pending confirmed synced cancelled].freeze

  validates :title, presence: true
  validates :start_at, :end_at, presence: true
  validates :status, inclusion: { in: STATUSES }

  STATUSES.each do |s|
    define_method(:"#{s}?") { status == s }
  end

  scope :upcoming, -> { where("start_at >= ?", Time.current).order(:start_at) }
  scope :active,   -> { where(status: %w[confirmed synced]) }
  scope :today,    -> { where(start_at: Date.current.all_day) }
end

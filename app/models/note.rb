class Note < ApplicationRecord
  belongs_to :telegram_user
  belongs_to :household
  belongs_to :note_category, optional: true

  scope :pending,           -> { where(status: "pending") }
  scope :confirmed,         -> { where(status: "confirmed") }
  scope :awaiting_category, -> { where.not(visibility: nil).where(note_category_id: nil) }
  scope :visible_to,        ->(user) { confirmed.where("visibility = 'public' OR telegram_user_id = ?", user.id) }

  validates :content, presence: true
  validates :visibility, inclusion: { in: %w[private public] }, allow_nil: true
  validates :status, inclusion: { in: %w[pending confirmed] }
  validates :visibility, presence: true, if: -> { confirmed? }

  def confirmed? = status == "confirmed"
  def pending?   = status == "pending"
  def awaiting_visibility? = pending? && visibility.nil?
  def awaiting_category?   = pending? && visibility.present? && note_category_id.nil?
end

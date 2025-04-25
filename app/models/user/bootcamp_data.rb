class User::BootcampData < ApplicationRecord
  serialize :utm, JSON

  belongs_to :user, optional: true

  scope :enrolled, -> { where.not(enrolled_at: nil) }
  scope :paid, -> { where.not(paid_at: nil) }
  scope :not_enrolled, -> { where(enrolled_at: nil) }
  scope :not_paid, -> { where(paid_at: nil) }

  before_create do
    self.level_idx = 1
  end

  def enrolled? = enrolled_at.present?
  def paid? = paid_at.present?
end

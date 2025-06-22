class User::BootcampData < ApplicationRecord
  serialize :utm, coder: JSON

  belongs_to :user, optional: true

  scope :enrolled, -> { where.not(enrolled_at: nil) }
  scope :paid, -> { where.not(paid_at: nil) }
  scope :not_enrolled, -> { where(enrolled_at: nil) }
  scope :not_paid, -> { where(paid_at: nil) }

  before_create do
    self.part_1_level_idx = 1
    self.part_2_level_idx = 11
  end

  def level_idx
    active_part == 1 ? part_1_level_idx : part_2_level_idx
  end

  def enrolled_in_both_parts?
    enrolled_on_part_1? && enrolled_on_part_2?
  end

  def enrolled_on_part_1? = super || user.bootcamp_mentor?
  def enrolled_on_part_2? = super || user.bootcamp_mentor?
end

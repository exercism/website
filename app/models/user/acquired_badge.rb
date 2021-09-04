class User::AcquiredBadge < ApplicationRecord
  belongs_to :badge, counter_cache: :num_awardees
  belongs_to :user

  scope :unrevealed, -> { where(revealed: false) }
  scope :revealed, -> { where(revealed: true) }
  delegate :name, :rarity, to: :badge

  before_create do
    self.uuid = SecureRandom.compact_uuid
  end
end

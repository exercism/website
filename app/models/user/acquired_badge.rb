class User::AcquiredBadge < ApplicationRecord
  belongs_to :badge
  belongs_to :user

  scope :unrevealed, -> { where(revealed: false) }
  delegate :name, :rarity, to: :badge

  before_create do
    self.uuid = SecureRandom.compact_uuid
  end
end

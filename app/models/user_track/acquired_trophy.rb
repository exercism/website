class UserTrack::AcquiredTrophy < ApplicationRecord
  belongs_to :trophy
  belongs_to :user
  belongs_to :track

  delegate :name, to: :trophy

  before_create do
    self.uuid = SecureRandom.compact_uuid
  end
end

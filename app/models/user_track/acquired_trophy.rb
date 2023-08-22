class UserTrack::AcquiredTrophy < ApplicationRecord
  belongs_to :trophy, class_name: 'Track::Trophy', counter_cache: :num_awardees
  belongs_to :user
  belongs_to :track

  before_create do
    self.uuid = SecureRandom.compact_uuid
  end
end

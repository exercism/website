class UserTrack::AcquiredTrophy < ApplicationRecord
  belongs_to :trophy, class_name: 'Track::Trophy'
  belongs_to :user
  belongs_to :track

  delegate :name, to: :trophy

  before_create do
    self.uuid = SecureRandom.compact_uuid
  end
end

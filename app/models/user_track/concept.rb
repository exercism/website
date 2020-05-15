class UserTrack::Concept < ApplicationRecord
  belongs_to :user_track
  belongs_to :track_concept, class_name: "Track::Concept"
end

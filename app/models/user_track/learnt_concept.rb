class UserTrack::LearntConcept < ApplicationRecord
  belongs_to :user_track
  belongs_to :track_concept, class_name: "Track::Concept"
end

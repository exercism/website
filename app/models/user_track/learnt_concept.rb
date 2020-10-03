class UserTrack::LearntConcept < ApplicationRecord
  belongs_to :user_track
  belongs_to :concept,  # rubocop:disable Rails/InverseOf
    class_name: "Track::Concept",
    foreign_key: "track_concept_id"
end

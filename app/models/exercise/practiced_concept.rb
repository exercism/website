class Exercise::PracticedConcept < ApplicationRecord
  belongs_to :exercise
  belongs_to :concept, # rubocop:disable Rails/InverseOf
    class_name: "Track::Concept",
    foreign_key: :track_concept_id
end

class Exercise::PracticedConcept < ApplicationRecord
  belongs_to :exercise
  belongs_to :concept, foreign_key: :track_concept_id # rubocop:disable Rails/InverseOf
end

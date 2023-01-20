class Exercise::TaughtConcept < ApplicationRecord
  belongs_to :exercise
  belongs_to :concept, foreign_key: :track_concept_id # rubocop:disable Rails/InverseOf

  after_save_commit do
    Track::UpdateNumConcepts.(exercise.track)
  end
end

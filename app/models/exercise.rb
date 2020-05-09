class Exercise < ApplicationRecord
  belongs_to :track
  has_many :exercise_prerequisites
  has_many :prerequisites, through: :exercise_prerequisites, source: :track_concept

  scope :without_prerequisites, -> {
    where.not(id: ExercisePrerequisite.select(:exercise_id))
  }

end

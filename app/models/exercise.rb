class Exercise < ApplicationRecord
  belongs_to :track
  has_many :exercise_prerequisites, class_name: "Exercise::Prerequisite"
  has_many :prerequisites, through: :exercise_prerequisites, source: :track_concept

  scope :without_prerequisites, -> {
    where.not(id: Exercise::Prerequisite.select(:exercise_id))
  }

end

class Exercise < ApplicationRecord
  belongs_to :track
  has_many :exercise_prerequisites,
    class_name: "Exercise::Prerequisite",
    inverse_of: :exercise,
    dependent: :destroy

  has_many :prerequisites,
    through: :exercise_prerequisites,
    source: :concept

  scope :without_prerequisites, lambda {
    where.not(id: Exercise::Prerequisite.select(:exercise_id))
  }
end

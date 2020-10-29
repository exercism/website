class Exercise < ApplicationRecord
  extend FriendlyId
  extend Mandate::Memoize

  friendly_id :slug, use: [:history]

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

  def concept_exercise?
    is_a?(ConceptExercise)
  end

  def practice_exercise?
    is_a?(PracticeExercise)
  end

  memoize
  def instructions
    Git::Exercise.new(track.slug, slug, :HEAD).data.instructions
  end

  def prerequisite_exercises
    ConceptExercise.that_teach(prerequisites).distinct
  end
end

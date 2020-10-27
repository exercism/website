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
    # TOOD: Change to "HEAD" when supported downstream
    # instructions(slug, :HEAD)
    # ex = Git::Exercise.new(track.slug, slug, :HEAD)
    ex = Git::Exercise.new(track.slug, slug, "ea8898137ec9ae768cadb983e5e9ba1f9a9f3c5b")
    ex.data.instructions
  end
end

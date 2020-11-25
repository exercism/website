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

  delegate :editor_solution_files,
    :cli_solution_filepaths,
    :all_solution_files,
    to: :git

  def git_type
    self.class.name.sub("Exercise", "").downcase
  end

  def concept_exercise?
    is_a?(ConceptExercise)
  end

  def practice_exercise?
    is_a?(PracticeExercise)
  end

  # TODO: Implement this properly
  def icon_name
    suffix = title[0].ord < 78 ? "butterflies" : "rocket"
    "sample-exercise-#{suffix}"
  end

  def prerequisite_exercises
    ConceptExercise.that_teach(prerequisites).distinct
  end

  memoize
  def git
    Git::Exercise.new(track.slug, slug, git_type, git_sha, repo_url: track.repo_url)
  end
end

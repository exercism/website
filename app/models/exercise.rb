class Exercise < ApplicationRecord
  extend FriendlyId

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

  def head_instructions
    instructions(slug, :HEAD)
  end

  def instructions(git_slug, git_sha)
    git_data(git_slug, git_sha).instructions
  end

  private
  def git_data(git_slug, git_sha)
    iv_key = "@git_data_#{git_slug}_#{git_sha}"
    return instance_variable_get(iv_key) if instance_variable_defined?(iv_key)

    data = Git::Exercise.new(track.slug, git_slug, git_sha).data
    instance_variable_set(iv_key, data)
  end
end

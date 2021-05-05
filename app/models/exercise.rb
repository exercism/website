class Exercise < ApplicationRecord
  extend FriendlyId
  extend Mandate::Memoize

  friendly_id :slug, use: [:history]

  enum status: {
    wip: 0,
    beta: 1,
    active: 2,
    deprecated: 3
  }

  belongs_to :track, counter_cache: :num_exercises

  # TODO: Pre-launch: Remove this dependent: :destroy  - exercises should never be destroyed
  has_many :solutions, dependent: :destroy
  has_many :submissions, through: :solutions

  # TODO: Pre-launch: Remove this dependent: :destroy - exercises should never be destroyed
  has_many :exercise_prerequisites,
    class_name: "Exercise::Prerequisite",
    inverse_of: :exercise,
    dependent: :destroy
  has_many :prerequisites,
    through: :exercise_prerequisites,
    source: :concept

  # TODO: Pre-launch: Remove this dependent: :destroy - exercises should never be destroyed
  has_many :authorships,
    class_name: "Exercise::Authorship",
    inverse_of: :exercise,
    dependent: :destroy
  has_many :authors,
    through: :authorships,
    source: :author

  # TODO: Pre-launch: Remove this dependent: :destroy - exercises should never be destroyed
  has_many :contributorships,
    class_name: "Exercise::Contributorship",
    inverse_of: :exercise,
    dependent: :destroy
  has_many :contributors,
    through: :contributorships,
    source: :contributor

  scope :sorted, -> { order(:position) }

  scope :without_prerequisites, lambda {
    where.not(id: Exercise::Prerequisite.select(:exercise_id))
  }

  delegate :solution_files, :introduction, :instructions, :source, :source_url, to: :git

  before_create do
    self.synced_to_git_sha = git_sha unless self.synced_to_git_sha
  end

  def status
    super.to_sym
  end

  def git_type
    self.class.name.sub("Exercise", "").downcase
  end

  def concept_exercise?
    is_a?(ConceptExercise)
  end

  def practice_exercise?
    is_a?(PracticeExercise)
  end

  def tutorial?
    slug == "hello-world"
  end

  def to_param
    slug
  end

  # TODO
  def download_cmd
    "exercism download --exercise=#{slug} --track=#{track.slug}".freeze
  end

  def difficulty_description
    case difficulty
    when 1..3
      "easy"
    when 4..7
      "medium"
    else
      "hard"
    end
  end

  def icon_url
    # TOOD: Read correct s3 bucket
    "https://exercism-icons-staging.s3.eu-west-2.amazonaws.com/exercises/#{git.icon_name.presence || slug}.svg"
  end

  def prerequisite_exercises
    ConceptExercise.that_teach(prerequisites).distinct
  end

  memoize
  def git
    Git::Exercise.new(slug, git_type, git_sha, repo_url: track.repo_url)
  end
end

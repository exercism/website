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

  has_many :solutions, dependent: :destroy
  has_many :submissions, through: :solutions

  has_many :exercise_prerequisites,
    class_name: "Exercise::Prerequisite",
    inverse_of: :exercise,
    dependent: :destroy
  has_many :prerequisites,
    through: :exercise_prerequisites,
    source: :concept

  has_many :authorships,
    class_name: "Exercise::Authorship",
    inverse_of: :exercise,
    dependent: :destroy
  has_many :authors,
    through: :authorships,
    source: :author

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

  def self.for(track_slug, exercise_slug)
    joins(:track).find_by('tracks.slug': track_slug, slug: exercise_slug)
  end

  delegate :files_for_editor, :exemplar_files, :introduction, :instructions, :source, :source_url, to: :git
  delegate :content, :edit_url, to: :mentoring_notes, prefix: :mentoring_notes

  before_create do
    self.synced_to_git_sha = git_sha unless self.synced_to_git_sha
    self.git_important_files_hash = Git::GenerateHashForImportantExerciseFiles.(self) if self.git_important_files_hash.blank?
  end

  before_update do
    self.git_important_files_hash = Git::GenerateHashForImportantExerciseFiles.(self) if git_sha_changed?
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

  def has_test_runner?
    super && track.has_test_runner?
  end

  def to_param
    slug
  end

  def download_cmd
    "exercism download --exercise=#{slug} --track=#{track.slug}".freeze
  end

  def difficulty_category
    case difficulty
    when 1..3
      :easy
    when 4..7
      :medium
    else
      :hard
    end
  end

  def icon_url
    "#{Exercism.config.website_icons_host}/exercises/#{icon_name}.svg"
  end

  memoize
  def mentoring_notes
    Git::Exercise::MentorNotes.new(track.slug, slug)
  end

  def prerequisite_exercises
    ConceptExercise.that_teach(prerequisites).distinct
  end

  # TODO: (Optional): This was memoized but because git_sha can change
  # this can actually end up being incorrectly memoized. How do we
  # deal with this?
  def git
    Git::Exercise.new(slug, git_type, git_sha, repo_url: track.repo_url)
  end
end

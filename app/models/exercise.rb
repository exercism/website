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

  belongs_to :track, touch: true

  has_many :solutions, dependent: :destroy
  has_many :iterations, through: :solutions
  has_many :submissions, through: :solutions
  has_many :representations, dependent: :destroy
  has_many :community_videos, dependent: :destroy
  has_many :site_updates, dependent: :destroy
  has_many :tags, dependent: :destroy

  has_many :approaches,
    class_name: "Exercise::Approach",
    inverse_of: :exercise,
    dependent: :destroy

  has_many :articles,
    class_name: "Exercise::Article",
    inverse_of: :exercise,
    dependent: :destroy

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

  has_many :approach_introduction_authorships,
    class_name: "Exercise::Approach::Introduction::Authorship",
    inverse_of: :exercise,
    dependent: :destroy
  has_many :approach_introduction_authors,
    through: :approach_introduction_authorships,
    source: :author

  has_many :approach_introduction_contributorships,
    class_name: "Exercise::Approach::Introduction::Contributorship",
    inverse_of: :exercise,
    dependent: :destroy
  has_many :approach_introduction_contributors,
    through: :approach_introduction_contributorships,
    source: :contributor

  scope :sorted, -> { order(:position) }
  scope :available, -> { where(status: %i[beta active]) }

  scope :without_prerequisites, lambda {
    where.not(id: Exercise::Prerequisite.select(:exercise_id))
  }

  def self.for(track_slug, exercise_slug)
    joins(:track).find_by('tracks.slug': track_slug, slug: exercise_slug)
  end

  delegate :files_for_editor, :exemplar_files, :introduction, :instructions, :source, :source_url,
    :approaches_introduction, :approaches_introduction_last_modified_at, :approaches_introduction_exists?,
    :approaches_introduction_edit_url, to: :git
  delegate :dir, :no_important_files_changed?, to: :git, prefix: true
  delegate :content, :edit_url, to: :mentoring_notes, prefix: :mentoring_notes
  delegate :deep_dive_youtube_id, :deep_dive_blurb, to: :generic_exercise, allow_nil: true
  delegate :has_analyzer?, :has_representer?, to: :track

  before_create do
    self.synced_to_git_sha = git_sha unless self.synced_to_git_sha
    self.git_important_files_hash = Git::GenerateHashForImportantExerciseFiles.(self) if self.git_important_files_hash.blank?
  end

  before_update do
    self.git_important_files_hash = Git::GenerateHashForImportantExerciseFiles.(self) if git_sha_changed?
  end

  after_update_commit do
    if saved_changes.include?('git_important_files_hash')
      Exercise::ProcessGitImportantFilesChanged.defer(
        self,
        previous_changes['git_important_files_hash'][0],
        (previous_changes.dig('git_sha', 0) || git_sha),
        (previous_changes.dig('slug', 0) || slug)
      )
    end

    Submission::Representation::TriggerRerunsForExercise.defer(self) if saved_changes.key?("representer_version")
  end

  after_commit do
    if (saved_changes.keys & %w[id status]).present?
      Track::UpdateNumExercises.(track)
      Track::UpdateNumConcepts.(track)
    end
  end

  def status = super.to_sym

  def git_type
    self.class.name.sub("Exercise", "").downcase
  end

  def concept_exercise? = is_a?(ConceptExercise)
  def practice_exercise? = is_a?(PracticeExercise)
  def approaches? = approaches.exists?
  def tutorial? = slug == "hello-world"
  def has_test_runner? = super && track.has_test_runner?

  memoize
  def generic_exercise = GenericExercise.for(slug)

  delegate :has_representer?, to: :track

  def to_param = slug
  def download_cmd = "exercism download --track=#{track.slug} --exercise=#{slug}".freeze

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

  def icon_url = "#{Exercism.config.website_icons_host}/exercises/#{icon_name}.svg"

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

class Track < ApplicationRecord
  extend FriendlyId
  extend Mandate::Memoize
  include Track::BuildStatus
  include CachedFind

  friendly_id :slug, use: [:history]

  # TODO: Pre-launch: remove dependent: :destroy
  has_many :concepts, class_name: "::Concept", dependent: :destroy
  has_many :exercises, dependent: :destroy
  has_many :solutions, through: :exercises
  has_many :submissions, dependent: :destroy
  has_many :representations, class_name: "Exercise::Representation", dependent: :destroy
  has_many :user_tracks, dependent: :destroy
  has_many :mentor_discussions, through: :solutions
  has_many :mentor_requests, class_name: "Mentor::Request", dependent: :destroy
  has_many :reputation_tokens, class_name: "User::ReputationToken", dependent: :destroy

  has_many :analyzer_tags, class_name: "Track::Tag", dependent: :destroy
  has_many :exercise_tags, class_name: "Exercise::Tag", dependent: :destroy
  has_many :solution_tags, class_name: "Solution::Tag", dependent: :destroy

  has_many :concept_exercises # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :practice_exercises # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :documents # rubocop:disable Rails/HasManyOrHasOneDependent

  # TODO: Pre-launch: remove dependent: :destroy
  has_many :tasks, class_name: "Github::Task", dependent: :destroy

  has_many :github_team_members, class_name: "Github::TeamMember", dependent: :destroy

  scope :active, -> { where(active: true) }

  delegate :key_features, :about, :snippet,
    :indent_style, :indent_size, :foregone_exercises,
    to: :git

  delegate :head_sha, to: :git, prefix: :git
  delegate :representations, to: :git, prefix: :mentoring
  delegate :debugging_instructions, :representer_normalizations, to: :git
  delegate :content, :edit_url, to: :mentoring_notes, prefix: :mentoring_notes

  after_save_commit { Rails.cache.delete(CACHE_KEY_NUM_ACTIVE) }

  def self.for!(param)
    return param if param.is_a?(Track)
    return find_by!(id: param) if param.is_a?(Numeric)

    find_by!(slug: param)
  end

  def self.for_repo(repo) = find_by(slug: slug_from_repo(repo))
  def self.id_for_repo(repo) = where(slug: slug_from_repo(repo)).pick(:id)

  def self.slug_from_repo(repo)
    name = repo.split('/').last
    TRACK_HELPER_REPOS[name] || name.gsub(TRACK_REPO_PREFIXES, '').gsub(TRACK_REPO_SUFFIXES, '')
  end

  def self.num_active
    Rails.cache.fetch(CACHE_KEY_NUM_ACTIVE, expires_in: 1.hour) do
      Track.active.count
    end
  end

  def to_param = slug

  memoize
  def git
    Git::Track.new(synced_to_git_sha, repo_url:)
  end

  memoize
  def tutorial_exercise
    exercises.find_by(slug: "hello-world")
  end

  memoize
  def num_contributors
    User::ReputationPeriod.where(
      period: :forever,
      category: :any,
      about: :track,
      track_id: id
    ).count
  end

  memoize
  def top_contributors
    User::ReputationPeriod::Search.(track_id: id)
  end

  memoize
  def num_code_contributors
    User::ReputationPeriod.where(
      period: :forever,
      category: %i[building maintaining authoring],
      about: :track,
      track_id: id
    ).select(:user_id).distinct.count
  end

  memoize
  def num_mentors
    User::TrackMentorship.
      where(track_id: id).
      select(:user_id).
      distinct.
      count
  end

  memoize
  def trophies
    Track::Trophy.for_track(self)
  end

  def icon_url = "#{Exercism.config.website_icons_host}/tracks/#{slug}.svg"

  def highlightjs_language
    super || slug
  end

  def average_test_duration
    git.average_test_duration.round + INFRASTRUCTURE_DURATION_S
  end

  def accessible_by?(user)
    active || user&.maintainer? || user&.admin?
  end

  memoize
  def mentoring_notes = Git::Track::MentorNotes.new(slug)

  memoize
  def representer = Git::Representer.new(repo_url: representer_repo_url)

  def test_runner_repo_url = "#{repo_url}-test-runner"
  def representer_repo_url = "#{repo_url}-representer"
  def analyzer_repo_url = "#{repo_url}-analyzer"

  def github_team_name = slug

  CATGEORIES = {
    paradigm: "Paradigm",
    typing: "Typing",
    execution_mode: "Execution mode",
    platform: "Platform",
    runtime: "Runtime",
    used_for: "Used for"
  }.with_indifferent_access.freeze

  TAGS = {
    paradigm: {
      declarative: "Declarative",
      functional: "Functional",
      imperative: "Imperative",
      logic: "Logic",
      object_oriented: "Object-oriented",
      procedural: "Procedural"
    },
    typing: {
      static: "Static",
      dynamic: "Dynamic",
      gradual: "Gradual",
      strong: "Strong",
      weak: "Weak"
    },
    execution_mode: {
      compiled: "Compiled",
      interpreted: "Interpreted"
    },
    platform: {
      windows: "Windows",
      mac: "macOS",
      linux: "Linux",
      ios: "iOS",
      android: "Android",
      web: "Web Browser"
    },
    runtime: {
      standalone_executable: "Standalone executable",
      language_specific: "Language-specific runtime",
      clr: "Common Language Runtime (.NET)",
      jvm: "JVM (Java)",
      beam: "BEAM (Erlang)"
    },
    used_for: {
      artificial_intelligence: "Artificial Intelligence",
      backends: "Backends",
      cross_platform_development: "Cross-platform development",
      embedded_systems: "Embedded systems",
      financial_systems: "Financial systems",
      frontends: "Frontends",
      games: "Games",
      guis: "GUIs",
      mobile: "Mobile",
      robotics: "Robotics",
      scientific_calculations: "Scientific calculations",
      scripts: "Scripts",
      web_development: "Web development"
    }
  }.with_indifferent_access.freeze

  INFRASTRUCTURE_DURATION_S = 1

  TRACK_REPO_PREFIXES = /^(codemirror-lang|eslint-config|babel-preset|highlightjs)-/i
  TRACK_REPO_SUFFIXES = /-(test-runner|analyzer|representer|lib-jest-extensions|lib-static-analysis|docker-base)$/i

  TRACK_HELPER_REPOS = {
    "dotnet-tests" => "csharp",
    "eslint-config-tooling" => "typescript"
  }.freeze
end

CACHE_KEY_NUM_ACTIVE = "track:num_active".freeze
